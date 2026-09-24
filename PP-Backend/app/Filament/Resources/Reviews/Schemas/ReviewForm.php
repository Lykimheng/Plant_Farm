<?php

namespace App\Filament\Resources\Reviews\Schemas;

use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class ReviewForm
{
    public static function configure(Schema $schema): Schema
    {
        // Read-only: reviews belong to customers. Admins moderate from the list.
        return $schema
            ->components([
                Section::make('Review')
                    ->columns(2)
                    ->schema([
                        TextEntry::make('plant.name')->label('Plant'),
                        TextEntry::make('user.name')->label('Customer'),
                        TextEntry::make('rating')
                            ->formatStateUsing(fn (int $state) => str_repeat('★', $state)." ($state/5)"),
                        TextEntry::make('created_at')->label('Posted')->dateTime('M j, Y g:i A'),
                        TextEntry::make('body')
                            ->label('Review text')
                            ->placeholder('— no text —')
                            ->columnSpanFull(),
                    ]),
            ]);
    }
}
