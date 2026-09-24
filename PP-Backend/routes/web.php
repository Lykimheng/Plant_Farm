<?php

use Illuminate\Support\Facades\Route;

// The admin panel is the only web UI here — the mobile app talks to /api.
// Send the root straight to it instead of Laravel's default welcome page.
Route::redirect('/', '/admin');
