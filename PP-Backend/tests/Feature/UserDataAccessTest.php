<?php

namespace Tests\Feature;

use App\Models\AppNotification;
use App\Models\MyPlant;
use App\Models\Order;
use App\Models\Plant;
use App\Models\Review;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

/** Every user-owned record is reachable only with its owner's token, whatever user_id is sent. */
class UserDataAccessTest extends TestCase
{
    use RefreshDatabase;

    private User $alice;
    private User $bob;
    private Order $aliceOrder;

    protected function setUp(): void
    {
        parent::setUp();

        $this->alice = User::forceCreate(['name' => 'Alice', 'email' => 'alice@example.test', 'password' => 'secret123']);
        $this->bob = User::forceCreate(['name' => 'Bob', 'email' => 'bob@example.test', 'password' => 'secret123']);

        // OrderObserver also gives Alice an "Order Placed" notification
        $this->aliceOrder = Order::create([
            'user_id' => $this->alice->id,
            'order_number' => 'PF-ALICE-1',
            'status' => 'pending',
            'total' => 19.50,
            'delivery_address' => 'Alice St.',
        ]);
    }

    public function test_another_users_orders_are_not_visible(): void
    {
        Sanctum::actingAs($this->bob);

        $this->getJson('/api/orders')->assertOk()->assertJson(['success' => true, 'orders' => []]);
        $this->getJson('/api/orders?user_id='.$this->alice->id)->assertOk()->assertJson(['orders' => []]);

        Sanctum::actingAs($this->alice);

        $this->getJson('/api/orders?user_id='.$this->bob->id)
            ->assertOk()
            ->assertJsonPath('orders.0.order_number', 'PF-ALICE-1');
    }

    public function test_customer_cancels_their_own_pending_order(): void
    {
        Sanctum::actingAs($this->alice);

        $this->postJson("/api/orders/{$this->aliceOrder->id}/cancel")
            ->assertOk()
            ->assertJson(['success' => true]);

        $this->assertSame('cancelled', $this->aliceOrder->fresh()->status);
        $this->assertTrue($this->alice->appNotifications()->where('type', 'orderCancelled')->exists());

        // a retry is harmless
        $this->postJson("/api/orders/{$this->aliceOrder->id}/cancel")->assertOk();
    }

    public function test_customer_cannot_cancel_someone_elses_order(): void
    {
        Sanctum::actingAs($this->bob);

        $this->postJson("/api/orders/{$this->aliceOrder->id}/cancel", ['user_id' => $this->alice->id])
            ->assertNotFound()
            ->assertJson(['success' => false]);

        $this->assertSame('pending', $this->aliceOrder->fresh()->status);
    }

    public function test_customer_cannot_set_status_to_delivered(): void
    {
        Sanctum::actingAs($this->alice);

        // the old open status endpoint is gone
        $this->putJson('/api/orders', ['order_id' => $this->aliceOrder->id, 'status' => 'delivered'])
            ->assertMethodNotAllowed()
            ->assertJson(['success' => false]);

        // and cancel only ever cancels
        $this->postJson("/api/orders/{$this->aliceOrder->id}/cancel", ['status' => 'delivered'])->assertOk();

        $this->assertSame('cancelled', $this->aliceOrder->fresh()->status);
    }

    public function test_an_order_already_being_processed_cannot_be_cancelled(): void
    {
        $this->aliceOrder->update(['status' => 'confirmed']);
        Sanctum::actingAs($this->alice);

        $this->postJson("/api/orders/{$this->aliceOrder->id}/cancel")
            ->assertStatus(422)
            ->assertJson(['success' => false]);

        $this->assertSame('confirmed', $this->aliceOrder->fresh()->status);
    }

    public function test_another_users_notifications_are_out_of_reach(): void
    {
        $notification = $this->alice->appNotifications()->sole();
        Sanctum::actingAs($this->bob);

        $this->getJson('/api/notifications?user_id='.$this->alice->id)->assertJson(['notifications' => []]);

        $this->putJson('/api/notifications', ['user_id' => $this->alice->id, 'notification_id' => $notification->id])
            ->assertNotFound();
        $this->deleteJson('/api/notifications', ['user_id' => $this->alice->id, 'notification_id' => $notification->id])
            ->assertNotFound();
        // "all of mine" means Bob's, not the user_id he sent
        $this->deleteJson('/api/notifications', ['user_id' => $this->alice->id])->assertOk();

        $notification->refresh();
        $this->assertFalse($notification->is_read);
        $this->assertTrue(AppNotification::whereKey($notification->id)->exists());
    }

    public function test_notifications_can_be_read_and_cleared_by_their_owner(): void
    {
        $notification = $this->alice->appNotifications()->sole();
        Sanctum::actingAs($this->alice);

        $this->getJson('/api/notifications')->assertJsonPath('notifications.0.id', $notification->id);
        $this->putJson('/api/notifications', ['notification_id' => $notification->id])->assertOk();
        $this->assertTrue($notification->fresh()->is_read);

        $this->deleteJson('/api/notifications')->assertOk();
        $this->assertSame(0, $this->alice->appNotifications()->count());
    }

    public function test_another_users_plants_are_out_of_reach(): void
    {
        $plant = MyPlant::create(['user_id' => $this->alice->id, 'name' => "Alice's fern"]);
        Sanctum::actingAs($this->bob);

        $this->getJson('/api/my_plants?user_id='.$this->alice->id)->assertJson(['plants' => []]);
        $this->deleteJson('/api/my_plants', ['plant_id' => $plant->id, 'user_id' => $this->alice->id])->assertNotFound();
        $this->postJson('/api/my_plants', ['name' => 'Planted on Alice', 'user_id' => $this->alice->id])->assertOk();

        $this->assertTrue(MyPlant::whereKey($plant->id)->exists());
        $this->assertSame(1, MyPlant::where('user_id', $this->bob->id)->count());
    }

    public function test_reviews_are_written_as_the_token_user(): void
    {
        $plant = $this->catalogPlant();
        $alices = Review::create(['plant_id' => $plant->id, 'user_id' => $this->alice->id, 'rating' => 5]);

        Sanctum::actingAs($this->bob);

        $this->postJson('/api/reviews', ['plant_id' => $plant->id, 'user_id' => $this->alice->id, 'rating' => 1])
            ->assertOk()
            ->assertJsonPath('my_review.rating', 1);
        $this->deleteJson('/api/reviews', ['plant_id' => $plant->id, 'user_id' => $this->alice->id, 'review_id' => $alices->id])
            ->assertNotFound();

        $this->assertSame(5, $alices->fresh()->rating);
        $this->assertSame(1, Review::where('user_id', $this->bob->id)->sole()->rating);
    }

    public function test_reviews_need_a_token_to_write_but_not_to_read(): void
    {
        $plant = $this->catalogPlant();

        $this->getJson('/api/reviews?plant_id='.$plant->id)->assertOk()->assertJson(['can_review' => false]);
        $this->postJson('/api/reviews', ['plant_id' => $plant->id, 'user_id' => $this->alice->id, 'rating' => 5])
            ->assertUnauthorized();

        $token = $this->alice->createToken('ios-app')->plainTextToken;
        $this->withToken($token)->getJson('/api/reviews?plant_id='.$plant->id)->assertJson(['can_review' => true]);
    }

    public function test_profile_changes_apply_to_the_token_user(): void
    {
        Sanctum::actingAs($this->bob);

        $this->putJson('/api/update_profile', ['user_id' => $this->alice->id, 'name' => 'Renamed'])->assertOk();

        $this->assertSame('Alice', $this->alice->fresh()->name);
        $this->assertSame('Renamed', $this->bob->fresh()->name);
    }

    private function catalogPlant(): Plant
    {
        return Plant::create([
            'image' => 'test.png', 'name' => 'Monstera', 'type' => 'Indoor',
            'type_plant' => 'indoorPlant', 'price' => 18, 'description' => 'Test plant.',
        ]);
    }
}
