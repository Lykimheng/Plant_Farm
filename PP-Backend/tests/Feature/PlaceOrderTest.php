<?php

namespace Tests\Feature;

use App\Models\Order;
use App\Models\Plant;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class PlaceOrderTest extends TestCase
{
    use RefreshDatabase;

    private User $user;
    private Plant $monstera;
    private Plant $fig;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::forceCreate([
            'name' => 'Test Customer',
            'email' => 'customer@example.test',
            'password' => 'secret123',
        ]);

        // 2 × $18.00 + 1 × $47.50 (discounted from $50.00) = $83.50
        $this->monstera = $this->plant('Monstera', 18.00);
        $this->fig = $this->plant('Fiddle Leaf Fig', 50.00, discount: 47.50);
    }

    // TC-1: the charge equals the server's own total
    public function test_tc1_order_total_is_database_prices_plus_delivery(): void
    {
        $response = $this->placeOrder(total: 85.00, monsteraPrice: 18.00, figPrice: 47.50);

        $response->assertJson(['success' => true, 'total' => 85.00]);
        $this->assertSame(85.00, (float) Order::sole()->total);
    }

    // TC-3: a tampered request claims $1.00
    public function test_tc3_tampered_total_and_prices_are_ignored(): void
    {
        $response = $this->placeOrder(total: 1.00, monsteraPrice: 0.01, figPrice: 0.01);

        $response->assertJson(['success' => true, 'total' => 85.00]);

        $order = Order::sole();
        $this->assertSame(85.00, (float) $order->total);
        $this->assertSame(18.00, (float) $order->items->firstWhere('plant_id', $this->monstera->id)->price);
        $this->assertSame(47.50, (float) $order->items->firstWhere('plant_id', $this->fig->id)->price);
    }

    public function test_express_delivery_adds_its_own_fee(): void
    {
        $this->placeOrder(total: 1.00, monsteraPrice: 18.00, figPrice: 47.50, delivery: 'express');

        $this->assertSame(85.50, (float) Order::sole()->total);
    }

    public function test_unknown_plant_is_rejected(): void
    {
        $this->postJson('/api/orders', [
            'user_id' => $this->user->id,
            'order_number' => 'PF-TEST-0002',
            'delivery_address' => 'No. 42, St. 271, Phnom Penh',
            'items' => [['plant_id' => 9999, 'plant_name' => 'Fake', 'price' => 0.01, 'quantity' => 1]],
        ])->assertJson(['success' => false]);

        $this->assertSame(0, Order::count());
    }

    private function placeOrder(float $total, float $monsteraPrice, float $figPrice, string $delivery = 'standard')
    {
        return $this->postJson('/api/orders', [
            'user_id' => $this->user->id,
            'order_number' => 'PF-TEST-0001',
            'delivery_address' => 'No. 42, St. 271, Phnom Penh',
            'delivery_option' => $delivery,
            'total' => $total,
            'items' => [
                ['plant_id' => $this->monstera->id, 'plant_name' => 'Monstera', 'price' => $monsteraPrice, 'quantity' => 2],
                ['plant_id' => $this->fig->id, 'plant_name' => 'Fiddle Leaf Fig', 'price' => $figPrice, 'quantity' => 1],
            ],
        ]);
    }

    private function plant(string $name, float $price, ?float $discount = null): Plant
    {
        return Plant::create([
            'image' => 'test.png',
            'name' => $name,
            'type' => 'Indoor',
            'type_plant' => 'indoorPlant',
            'price' => $price,
            'description' => 'Test plant.',
            'discount_price' => $discount,
        ]);
    }
}
