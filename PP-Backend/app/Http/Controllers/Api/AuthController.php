<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\RateLimiter;
use Throwable;

class AuthController extends Controller
{
    private const MIN_PASSWORD_LENGTH = 6;

    // bcrypt ignores everything past 72 bytes, so a longer new password would only seem stronger
    private const MAX_NEW_PASSWORD_BYTES = 72;

    // sign-in stays lenient for passwords set before the limit existed
    private const MAX_PASSWORD_LENGTH = 128;

    // users table column sizes
    private const MAX_NAME_LENGTH = 100;
    private const MAX_EMAIL_LENGTH = 150;
    private const MAX_LOCATION_LENGTH = 100;

    /** Wrong reset codes allowed per email before the code is thrown away. */
    private const RESET_ATTEMPTS = 5;

    /** Shape the client expects inside the `user` key. */
    private function userPayload(User $user): array
    {
        return [
            'id'       => (int) $user->id,
            'name'     => $user->name,
            'email'    => $user->email,
            'location' => $user->location ?? '',
            'avatar'   => filled($user->avatar)
                ? url('uploads/avatars/'.rawurlencode($user->avatar))
                : '',
        ];
    }

    private function signedIn(User $user, string $message)
    {
        return response()->json([
            'success' => true,
            'message' => $message,
            'user'    => $this->userPayload($user),
            'token'   => $user->createToken('ios-app')->plainTextToken,
        ]);
    }

    private function fail(string $message, int $status = 422)
    {
        return response()->json(['success' => false, 'message' => $message], $status);
    }

    private function newPasswordProblem(string $password): ?string
    {
        if (mb_strlen($password) < self::MIN_PASSWORD_LENGTH) {
            return 'Use at least '.self::MIN_PASSWORD_LENGTH.' characters.';
        }

        if (strlen($password) > self::MAX_NEW_PASSWORD_BYTES) {
            return 'That password is too long.';
        }

        return null;
    }

    public function register(Request $request)
    {
        $name     = trim($request->input('name', ''));
        $email    = trim($request->input('email', ''));
        $password = trim($request->input('password', ''));
        $location = trim($request->input('location', ''));

        if ($name === '' || $email === '' || $password === '') {
            return $this->fail('Name, email and password are required.');
        }

        if (mb_strlen($name) > self::MAX_NAME_LENGTH
            || mb_strlen($email) > self::MAX_EMAIL_LENGTH
            || mb_strlen($location) > self::MAX_LOCATION_LENGTH) {
            return $this->fail('Name, email or city is too long.');
        }

        if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return $this->fail('Invalid email format.');
        }

        if ($problem = $this->newPasswordProblem($password)) {
            return $this->fail($problem);
        }

        if (User::where('email', $email)->exists()) {
            return $this->fail('Email already registered.');
        }

        $user = User::create([
            'name'     => $name,
            'email'    => $email,
            'password' => $password,   // hashed by the model cast
            'location' => $location,
        ]);

        return $this->signedIn($user, 'Registration successful.');
    }

    public function login(Request $request)
    {
        $email    = trim($request->input('email', ''));
        $password = trim($request->input('password', ''));

        if ($email === '' || $password === '') {
            return $this->fail('Email and password are required.');
        }

        // no account can match, so don't spend a hash check on it
        if (mb_strlen($email) > self::MAX_EMAIL_LENGTH || mb_strlen($password) > self::MAX_PASSWORD_LENGTH) {
            return $this->fail('Invalid email or password.');
        }

        $user = User::where('email', $email)->first();

        // bcrypt hashes written by the old PHP backend verify fine here.
        // 422 rather than 401: the app treats 401 as "your saved session expired"
        if (! $user || ! Hash::check($password, $user->password)) {
            return $this->fail('Invalid email or password.');
        }

        return $this->signedIn($user, 'Login successful.');
    }

    public function me(Request $request)
    {
        return response()->json([
            'success' => true,
            'user'    => $this->userPayload($request->user()),
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Signed out.',
        ]);
    }

    /**
     * Emails a 6-digit code (stored hashed in password_reset_tokens). The answer
     * is the same whether or not the account exists, so this can't be used to
     * find out who has one.
     */
    public function forgotPassword(Request $request)
    {
        $email = trim((string) $request->input('email', ''));

        if (mb_strlen($email) > self::MAX_EMAIL_LENGTH || ! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return $this->fail('Invalid email format.');
        }

        $sent = response()->json([
            'success' => true,
            'message' => "If an account uses that email, we've sent it a reset code.",
        ]);

        $user = User::where('email', $email)->first();

        if (! $user) {
            return $sent;
        }

        $code    = (string) random_int(100000, 999999);
        $minutes = $this->resetMinutes();

        DB::table('password_reset_tokens')->updateOrInsert(
            ['email' => $user->email],
            ['token' => Hash::make($code), 'created_at' => now()]
        );

        try {
            Mail::raw(
                "Your Plant Farm password reset code is {$code}. It expires in {$minutes} minutes.\n\n"
                ."If you didn't ask to reset your password, you can ignore this email.",
                fn ($message) => $message->to($user->email)->subject('Your Plant Farm reset code')
            );
        } catch (Throwable $e) {
            Log::error('Password reset email failed', ['exception' => $e]);
            DB::table('password_reset_tokens')->where('email', $user->email)->delete();

            return $this->fail("We couldn't send the reset email right now. Please try again later.", 503);
        }

        return $sent;
    }

    public function resetPassword(Request $request)
    {
        $email    = trim((string) $request->input('email', ''));
        $code     = trim((string) $request->input('code', ''));
        $password = trim((string) $request->input('password', ''));

        if ($email === '' || $code === '' || $password === '') {
            return $this->fail('Email, code and new password are required.');
        }

        if (mb_strlen($email) > self::MAX_EMAIL_LENGTH || strlen($code) > 6) {
            return $this->fail('That code is wrong or has expired.');
        }

        if ($problem = $this->newPasswordProblem($password)) {
            return $this->fail($problem);
        }

        $attempts = 'password-reset:'.mb_strtolower($email);

        if (RateLimiter::tooManyAttempts($attempts, self::RESET_ATTEMPTS)) {
            return $this->fail('Too many wrong codes. Request a new code later.', 429);
        }

        $row  = DB::table('password_reset_tokens')->where('email', $email)->first();
        $user = User::where('email', $email)->first();

        $valid = $row && $user
            && Carbon::parse($row->created_at)->addMinutes($this->resetMinutes())->isFuture()
            && Hash::check($code, $row->token);

        if (! $valid) {
            RateLimiter::hit($attempts, $this->resetMinutes() * 60);

            if (RateLimiter::tooManyAttempts($attempts, self::RESET_ATTEMPTS)) {
                DB::table('password_reset_tokens')->where('email', $email)->delete();
            }

            return $this->fail('That code is wrong or has expired.');
        }

        $user->password = $password;   // hashed by the model cast
        $user->save();

        // a reset signs every device out
        $user->tokens()->delete();
        DB::table('password_reset_tokens')->where('email', $email)->delete();
        RateLimiter::clear($attempts);

        return response()->json([
            'success' => true,
            'message' => 'Password updated. You can sign in with it now.',
        ]);
    }

    public function updateProfile(Request $request)
    {
        $name = trim($request->input('name', ''));

        if ($name === '') {
            return $this->fail('Name is required.');
        }

        if (mb_strlen($name) > self::MAX_NAME_LENGTH) {
            return $this->fail('That name is too long.');
        }

        $request->user()->update(['name' => $name]);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated.',
            'name'    => $name,
        ]);
    }

    public function uploadAvatar(Request $request)
    {
        $user        = $request->user();
        $imageBase64 = $request->input('image_base64', '');

        if ($imageBase64 === '') {
            return $this->fail('Missing image.');
        }

        $imageData = base64_decode($imageBase64, true);

        if ($imageData === false) {
            return $this->fail('Invalid image data.');
        }

        $filename  = "user{$user->id}_".time().'.jpg';
        $directory = public_path('uploads/avatars');

        if (! is_dir($directory)) {
            mkdir($directory, 0755, true);
        }

        if (file_put_contents($directory.'/'.$filename, $imageData) === false) {
            return $this->fail('Failed to save image.', 500);
        }

        $user->update(['avatar' => $filename]);

        return response()->json([
            'success'    => true,
            'message'    => 'Avatar updated.',
            'avatar_url' => url('uploads/avatars/'.rawurlencode($filename)),
        ]);
    }

    private function resetMinutes(): int
    {
        return (int) config('auth.passwords.users.expire', 60);
    }
}
