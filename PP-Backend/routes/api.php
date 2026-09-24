<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\MyPlantController;
use App\Http\Controllers\Api\NotificationController;
use App\Http\Controllers\Api\OrderController;
use App\Http\Controllers\Api\PlantController;
use App\Http\Controllers\Api\ReviewController;
use Illuminate\Support\Facades\Route;

/*
| Clean REST-ish routes. Each is also aliased to the old "<name>.php" path the
| plain-PHP backend used, so an un-updated client keeps working.
*/

$routes = function () {
    // auth
    Route::post('register', [AuthController::class, 'register']);
    Route::post('login', [AuthController::class, 'login']);
    Route::post('forgot_password', [AuthController::class, 'forgotPassword']);
    Route::put('update_profile', [AuthController::class, 'updateProfile']);
    Route::post('upload_avatar', [AuthController::class, 'uploadAvatar']);

    // catalog
    Route::get('plants', [PlantController::class, 'index']);

    // reviews
    Route::get('reviews', [ReviewController::class, 'index']);
    Route::post('reviews', [ReviewController::class, 'store']);
    Route::delete('reviews', [ReviewController::class, 'destroy']);

    // personal plant tracker
    Route::get('my_plants', [MyPlantController::class, 'index']);
    Route::post('my_plants', [MyPlantController::class, 'store']);
    Route::delete('my_plants', [MyPlantController::class, 'destroy']);

    // orders
    Route::get('orders', [OrderController::class, 'index']);
    Route::post('orders', [OrderController::class, 'store']);
    Route::put('orders', [OrderController::class, 'updateStatus']);

    // notifications (the legacy backend spelled this "notifactions")
    Route::get('notifications', [NotificationController::class, 'index']);
    Route::put('notifications', [NotificationController::class, 'markRead']);
    Route::delete('notifications', [NotificationController::class, 'destroy']);
    Route::get('notifactions', [NotificationController::class, 'index']);
    Route::put('notifactions', [NotificationController::class, 'markRead']);
    Route::delete('notifactions', [NotificationController::class, 'destroy']);
};

$routes();

// legacy ".php" aliases so the previous URLs keep resolving
Route::group([], function () use ($routes) {
    Route::name('legacy.')->group(function () use ($routes) {
        foreach ([
            'register.php'        => ['post', [AuthController::class, 'register']],
            'login.php'           => ['post', [AuthController::class, 'login']],
            'forgot_password.php' => ['post', [AuthController::class, 'forgotPassword']],
            'update_profile.php'  => ['put', [AuthController::class, 'updateProfile']],
            'upload_avatar.php'   => ['post', [AuthController::class, 'uploadAvatar']],
            'plants.php'          => ['get', [PlantController::class, 'index']],
        ] as $uri => [$verb, $action]) {
            Route::{$verb}($uri, $action);
        }

        Route::match(['get'], 'my_plants.php', [MyPlantController::class, 'index']);
        Route::match(['post'], 'my_plants.php', [MyPlantController::class, 'store']);
        Route::match(['delete'], 'my_plants.php', [MyPlantController::class, 'destroy']);

        Route::match(['get'], 'orders.php', [OrderController::class, 'index']);
        Route::match(['post'], 'orders.php', [OrderController::class, 'store']);
        Route::match(['put'], 'orders.php', [OrderController::class, 'updateStatus']);

        Route::match(['get'], 'notifactions.php', [NotificationController::class, 'index']);
        Route::match(['put'], 'notifactions.php', [NotificationController::class, 'markRead']);
        Route::match(['delete'], 'notifactions.php', [NotificationController::class, 'destroy']);
    });
});
