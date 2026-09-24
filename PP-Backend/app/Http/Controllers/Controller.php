<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

abstract class Controller
{
    /**
     * A trimmed string from the request.
     *
     * Laravel's ConvertEmptyStringsToNull middleware rewrites `""` to `null`,
     * and `input($key, $default)` only falls back when the key is *absent* —
     * so an optional field the client left blank arrived as null and hit a
     * NOT NULL column. Reading optional strings through here instead.
     */
    protected function stringInput(Request $request, string $key, string $default = ''): string
    {
        $value = $request->input($key);

        if ($value === null || $value === '') {
            return $default;
        }

        return trim((string) $value);
    }
}
