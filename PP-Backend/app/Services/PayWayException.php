<?php

namespace App\Services;

use RuntimeException;

class PayWayException extends RuntimeException
{
    public function __construct(string $message, public readonly string $payWayCode = '')
    {
        parent::__construct($message);
    }
}
