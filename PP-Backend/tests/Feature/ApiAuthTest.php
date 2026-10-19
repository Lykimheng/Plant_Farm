<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class ApiAuthTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::forceCreate([
            'name' => 'Test Customer',
            'email' => 'customer@example.test',
            'password' => 'secret123',
        ]);
    }

    public function test_login_returns_a_token_that_identifies_the_user(): void
    {
        $token = $this->postJson('/api/login', ['email' => 'customer@example.test', 'password' => 'secret123'])
            ->assertOk()
            ->assertJson(['success' => true, 'user' => ['id' => $this->user->id]])
            ->json('token');

        $this->assertNotEmpty($token);

        $this->withToken($token)->getJson('/api/user')
            ->assertOk()
            ->assertJson(['success' => true, 'user' => ['email' => 'customer@example.test']]);
    }

    public function test_register_returns_a_token(): void
    {
        $token = $this->postJson('/api/register', [
            'name' => 'New Customer',
            'email' => 'new@example.test',
            'password' => 'secret123',
        ])->assertOk()->json('token');

        $this->withToken($token)->getJson('/api/user')->assertJson(['user' => ['email' => 'new@example.test']]);
    }

    public function test_wrong_password_is_422_with_the_usual_shape(): void
    {
        $this->postJson('/api/login', ['email' => 'customer@example.test', 'password' => 'wrong'])
            ->assertStatus(422)
            ->assertExactJson(['success' => false, 'message' => 'Invalid email or password.']);
    }

    public function test_duplicate_registration_is_422(): void
    {
        $this->postJson('/api/register', [
            'name' => 'Again',
            'email' => 'customer@example.test',
            'password' => 'secret123',
        ])->assertStatus(422)->assertJson(['success' => false]);
    }

    public function test_protected_routes_need_a_token(): void
    {
        foreach (['/api/orders', '/api/notifications', '/api/my_plants', '/api/user'] as $uri) {
            $this->getJson($uri)
                ->assertUnauthorized()
                ->assertExactJson(['success' => false, 'message' => 'Please sign in again.']);
        }

        // without an Accept header too, rather than a redirect to a missing login page
        $this->get('/api/orders')->assertUnauthorized()->assertJson(['success' => false]);
    }

    public function test_a_made_up_token_is_rejected(): void
    {
        $this->withToken('1|not-a-real-token')->getJson('/api/orders')->assertUnauthorized();
    }

    public function test_logout_revokes_the_token(): void
    {
        $token = $this->user->createToken('ios-app')->plainTextToken;

        $this->withToken($token)->postJson('/api/logout')->assertOk();
        $this->app['auth']->forgetGuards();

        $this->withToken($token)->getJson('/api/user')->assertUnauthorized();
    }

    public function test_tokens_expire(): void
    {
        $token = $this->user->createToken('ios-app')->plainTextToken;

        $this->travel(31)->days();

        $this->withToken($token)->getJson('/api/user')->assertUnauthorized();
    }

    public function test_unknown_routes_are_404_with_the_usual_shape(): void
    {
        $this->getJson('/api/nothing_here')->assertNotFound()->assertJson(['success' => false]);
    }
}
