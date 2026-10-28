<?php

namespace Tests\Feature;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Tests\TestCase;

class PasswordResetTest extends TestCase
{
    use RefreshDatabase;

    private User $user;

    protected function setUp(): void
    {
        parent::setUp();

        $this->user = User::forceCreate([
            'name' => 'Test Customer',
            'email' => 'customer@example.test',
            'password' => 'old-secret',
        ]);
    }

    public function test_an_email_alone_no_longer_changes_the_password(): void
    {
        // what the old endpoint accepted
        $this->postJson('/api/forgot_password', ['email' => 'customer@example.test', 'newPassword' => 'taken-over'])
            ->assertOk();

        $this->assertPasswordIs('old-secret');
    }

    public function test_unknown_email_gets_the_same_answer_and_no_mail(): void
    {
        $known = $this->postJson('/api/forgot_password', ['email' => 'customer@example.test'])->assertOk()->json();
        $unknown = $this->postJson('/api/forgot_password', ['email' => 'nobody@example.test'])->assertOk()->json();

        $this->assertSame($known, $unknown);
        $this->assertCount(1, $this->sentMail());
    }

    public function test_reset_without_a_requested_code_fails(): void
    {
        $this->postJson('/api/reset_password', [
            'email' => 'customer@example.test', 'code' => '123456', 'password' => 'new-secret',
        ])->assertStatus(422)->assertJson(['success' => false]);

        $this->assertPasswordIs('old-secret');
    }

    public function test_reset_with_a_wrong_code_fails(): void
    {
        $code = $this->requestCode();

        $this->postJson('/api/reset_password', [
            'email' => 'customer@example.test', 'code' => $this->otherThan($code), 'password' => 'new-secret',
        ])->assertStatus(422)->assertJson(['success' => false]);

        $this->assertPasswordIs('old-secret');
    }

    public function test_reset_with_an_expired_code_fails(): void
    {
        $code = $this->requestCode();

        $this->travel(61)->minutes();

        $this->postJson('/api/reset_password', [
            'email' => 'customer@example.test', 'code' => $code, 'password' => 'new-secret',
        ])->assertStatus(422);

        $this->assertPasswordIs('old-secret');
    }

    public function test_a_valid_code_resets_the_password_once_and_signs_out_everywhere(): void
    {
        $this->user->createToken('ios-app');
        $code = $this->requestCode();

        $this->postJson('/api/reset_password', [
            'email' => 'customer@example.test', 'code' => $code, 'password' => 'new-secret',
        ])->assertOk()->assertJson(['success' => true]);

        $this->assertPasswordIs('new-secret');
        $this->assertSame(0, $this->user->tokens()->count());

        $this->postJson('/api/reset_password', [
            'email' => 'customer@example.test', 'code' => $code, 'password' => 'again-secret',
        ])->assertStatus(422);

        $this->postJson('/api/login', ['email' => 'customer@example.test', 'password' => 'new-secret'])->assertOk();
    }

    public function test_too_many_wrong_codes_throw_the_code_away(): void
    {
        $code = $this->requestCode();

        for ($i = 0; $i < 5; $i++) {
            $this->postJson('/api/reset_password', [
                'email' => 'customer@example.test', 'code' => $this->otherThan($code), 'password' => 'new-secret',
            ])->assertStatus(422);
        }

        $this->postJson('/api/reset_password', [
            'email' => 'customer@example.test', 'code' => $code, 'password' => 'new-secret',
        ])->assertStatus(429)->assertJson(['success' => false]);

        $this->assertPasswordIs('old-secret');
        $this->assertFalse(DB::table('password_reset_tokens')->where('email', 'customer@example.test')->exists());
    }

    private function requestCode(): string
    {
        $this->postJson('/api/forgot_password', ['email' => 'customer@example.test'])->assertOk();

        preg_match('/\b(\d{6})\b/', $this->sentMail()->last()->getOriginalMessage()->getTextBody(), $match);

        return $match[1];
    }

    private function sentMail()
    {
        return app('mailer')->getSymfonyTransport()->messages();
    }

    private function otherThan(string $code): string
    {
        return $code === '000000' ? '111111' : '000000';
    }

    private function assertPasswordIs(string $password): void
    {
        $this->assertTrue(Hash::check($password, $this->user->fresh()->password));
    }
}
