<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MyPlantController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PaymentController;
use App\Http\Controllers\Api\PlantController;
use App\Http\Controllers\Api\ReviewController;
use Illuminate\Support\Facades\Route;

/*
| The app signs in with a Sanctum token (`Authorization: Bearer …`) and every
| user-owned record is looked up from that token, never from a `user_id` the
| client sends. The old "<name>.php" aliases are gone: clients that old never
| received a token, so they couldn't use the protected routes anyway.
*/

// auth, rate limited per IP (the third argument keeps the two counters apart)
Route::middleware('throttle:10,1,auth')->group(function () {
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
});

Route::middleware('throttle:10,1,password-reset')->group(function () {
    Route::post('forgot_password', [AuthController::class, 'forgotPassword']);
    Route::post('reset_password', [AuthController::class, 'resetPassword']);
});

// public
Route::get('plants', [PlantController::class, 'index']);
Route::get('reviews', [ReviewController::class, 'index']);

// ABA PayWay's pushback; the controller re-checks every claim with PayWay itself
Route::post('payway/callback', [PaymentController::class, 'callback'])->middleware('throttle:60,1,payway');

Route::middleware('auth:sanctum')->group(function () {
    Route::get('user', [AuthController::class, 'me']);
    Route::post('logout', [AuthController::class, 'logout']);
    Route::put('update_profile', [AuthController::class, 'updateProfile']);
    Route::post('upload_avatar', [AuthController::class, 'uploadAvatar']);

    // reviews
    Route::post('reviews', [ReviewController::class, 'store']);
    Route::delete('reviews', [ReviewController::class, 'destroy']);

    // personal plant tracker
    Route::get('my_plants', [MyPlantController::class, 'index']);
    Route::post('my_plants', [MyPlantController::class, 'store']);
    Route::delete('my_plants', [MyPlantController::class, 'destroy']);

    // orders — any other status change is made by an admin in the Filament panel
    Route::get('orders', [OrderController::class, 'index']);
    Route::post('orders', [OrderController::class, 'store']);
    Route::post('orders/{order}/cancel', [OrderController::class, 'cancel'])->whereNumber('order');

    // paying with ABA PayWay; the app polls the status while the customer pays
    Route::middleware('throttle:60,1,payments')->group(function () {
        Route::post('orders/{order}/payments', [PaymentController::class, 'store'])->whereNumber('order');
        Route::get('orders/{order}/payment', [PaymentController::class, 'show'])->whereNumber('order');
        Route::post('orders/{order}/payment/cancel', [PaymentController::class, 'cancel'])->whereNumber('order');
    });

    // notifications
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::put('notifications', [NotificationController::class, 'markRead']);
    Route::delete('notifications', [NotificationController::class, 'destroy']);
});
