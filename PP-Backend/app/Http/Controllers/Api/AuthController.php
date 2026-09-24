<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
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

    public function register(Request $request)
    {
        $name     = trim($request->input('name', ''));
        $email    = trim($request->input('email', ''));
        $password = trim($request->input('password', ''));
        $location = trim($request->input('location', ''));

        if ($name === '' || $email === '' || $password === '') {
            return response()->json([
                'success' => false,
                'message' => 'Name, email and password are required.',
            ]);
        }

        if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email format.',
            ]);
        }

        if (User::where('email', $email)->exists()) {
            return response()->json([
                'success' => false,
                'message' => 'Email already registered.',
            ]);
        }

        $user = User::create([
            'name'     => $name,
            'email'    => $email,
            'password' => $password,   // hashed by the model cast
            'location' => $location,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Registration successful.',
            'user'    => $this->userPayload($user),
        ]);
    }

    public function login(Request $request)
    {
        $email    = trim($request->input('email', ''));
        $password = trim($request->input('password', ''));

        if ($email === '' || $password === '') {
            return response()->json([
                'success' => false,
                'message' => 'Email and password are required.',
            ]);
        }

        $user = User::where('email', $email)->first();

        // bcrypt hashes written by the old PHP backend verify fine here
        if (! $user || ! Hash::check($password, $user->password)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email or password.',
            ]);
        }

        return response()->json([
            'success' => true,
            'message' => 'Login successful.',
            'user'    => $this->userPayload($user),
        ]);
    }

    public function forgotPassword(Request $request)
    {
        $email       = trim($request->input('email', ''));
        $newPassword = trim($request->input('newPassword', ''));

        if ($email === '' || $newPassword === '') {
            return response()->json([
                'success' => false,
                'message' => 'Email and new password are required.',
            ]);
        }

        if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid email format.',
            ]);
        }

        $user = User::where('email', $email)->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => 'No account found with this email.',
            ]);
        }

        $user->password = $newPassword;   // hashed by the model cast
        $user->save();

        return response()->json([
            'success' => true,
            'message' => 'Password updated successfully.',
        ]);
    }

    public function updateProfile(Request $request)
    {
        $userId = (int) $request->input('user_id', 0);
        $name   = trim($request->input('name', ''));

        if ($userId === 0 || $name === '') {
            return response()->json([
                'success' => false,
                'message' => 'Name is required.',
            ]);
        }

        User::where('id', $userId)->update(['name' => $name]);

        return response()->json([
            'success' => true,
            'message' => 'Profile updated.',
            'name'    => $name,
        ]);
    }

    public function uploadAvatar(Request $request)
    {
        $userId      = (int) $request->input('user_id', 0);
        $imageBase64 = $request->input('image_base64', '');

        if ($userId === 0 || $imageBase64 === '') {
            return response()->json([
                'success' => false,
                'message' => 'Missing user_id or image.',
            ]);
        }

        $imageData = base64_decode($imageBase64, true);

        if ($imageData === false) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid image data.',
            ]);
        }

        $filename  = "user{$userId}_".time().'.jpg';
        $directory = public_path('uploads/avatars');

        if (! is_dir($directory)) {
            mkdir($directory, 0755, true);
        }

        if (file_put_contents($directory.'/'.$filename, $imageData) === false) {
            return response()->json([
                'success' => false,
                'message' => 'Failed to save image.',
            ]);
        }

        User::where('id', $userId)->update(['avatar' => $filename]);

        return response()->json([
            'success'    => true,
            'message'    => 'Avatar updated.',
            'avatar_url' => url('uploads/avatars/'.rawurlencode($filename)),
        ]);
    }
}
