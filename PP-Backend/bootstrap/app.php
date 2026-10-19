<?php

use Illuminate\Auth\AuthenticationException;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Illuminate\Http\Request;
use Illuminate\Validation\ValidationException;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\HttpExceptionInterface;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        apiPrefix: 'api',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware): void {
        // there's no web login page to send an unauthenticated API call to
        $middleware->redirectGuestsTo(fn (Request $request) => $request->is('api/*') ? null : '/admin/login');
    })
    ->withExceptions(function (Exceptions $exceptions): void {
        $exceptions->shouldRenderJsonWhen(
            fn (Request $request) => $request->is('api/*'),
        );

        // API errors keep the { success, message } shape the app decodes
        $exceptions->render(function (Throwable $e, Request $request) {
            if (! $request->is('api/*')) {
                return null;
            }

            [$status, $message, $headers] = match (true) {
                $e instanceof AuthenticationException => [401, 'Please sign in again.', []],
                $e instanceof ValidationException     => [422, $e->validator->errors()->first(), []],
                $e instanceof HttpExceptionInterface  => [$e->getStatusCode(), match ($e->getStatusCode()) {
                    403     => "You don't have permission to do that.",
                    404     => 'Not found.',
                    429     => 'Too many attempts. Please wait a minute and try again.',
                    default => Response::$statusTexts[$e->getStatusCode()] ?? 'Request failed.',
                }, $e->getHeaders()],
                default => [null, null, []],
            };

            return $status === null
                ? null
                : response()->json(['success' => false, 'message' => $message], $status, $headers);
        });
    })->create();
