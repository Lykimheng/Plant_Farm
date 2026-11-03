<?php

return [

    /*
    |--------------------------------------------------------------------------
    | Third Party Services
    |--------------------------------------------------------------------------
    |
    | This file is for storing the credentials for third party services such
    | as Mailgun, Postmark, AWS and more. This file provides the de facto
    | location for this type of information, allowing packages to have
    | a conventional file to locate the various service credentials.
    |
    */

    'postmark' => [
        'key' => env('POSTMARK_API_KEY'),
    ],

    'resend' => [
        'key' => env('RESEND_API_KEY'),
    ],

    'ses' => [
        'key' => env('AWS_ACCESS_KEY_ID'),
        'secret' => env('AWS_SECRET_ACCESS_KEY'),
        'region' => env('AWS_DEFAULT_REGION', 'us-east-1'),
    ],

    'slack' => [
        'notifications' => [
            'bot_user_oauth_token' => env('SLACK_BOT_USER_OAUTH_TOKEN'),
            'channel' => env('SLACK_BOT_USER_DEFAULT_CHANNEL'),
        ],
    ],

    // the API key signs every PayWay request, so it stays on the server
    'payway' => [
        'base_url' => env('PAYWAY_BASE_URL', 'https://checkout-sandbox.payway.com.kh'),
        'merchant_id' => env('PAYWAY_MERCHANT_ID'),
        'api_key' => env('PAYWAY_API_KEY'),
        'return_url' => env('PAYWAY_RETURN_URL'),
        'lifetime' => (int) env('PAYWAY_LIFETIME', 15),
    ],

];
