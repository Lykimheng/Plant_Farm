<?php

namespace App\Filament\Resources\Users\Schemas;

use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Schema;

class UserForm
{
    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->columns(2)
            ->components([
                TextInput::make('name')
                    ->required()
                    ->maxLength(100),

                TextInput::make('email')
                    ->email()
                    ->required()
                    ->unique(ignoreRecord: true)
                    ->maxLength(150),

                TextInput::make('password')
                    ->password()
                    ->revealable()
                    // only overwrite the stored hash when a new value is typed
                    ->dehydrated(fn (?string $state) => filled($state))
                    ->required(fn (string $operation) => $operation === 'create')
                    ->helperText('Leave blank to keep the current password.'),

                TextInput::make('location')
                    ->maxLength(100),

                Toggle::make('is_admin')
                    ->label('Admin access')
                    ->helperText('Allows signing in to this dashboard.')
                    ->inline(false),
            ]);
    }
}
