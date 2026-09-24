<?php

namespace App\Filament\Resources\Orders\Schemas;

use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\TextEntry;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;

class OrderForm
{
    public const STATUSES = [
        'pending'   => 'Pending',
        'confirmed' => 'Confirmed',
        'preparing' => 'Preparing',
        'inTransit' => 'In Transit',
        'delivered' => 'Delivered',
        'cancelled' => 'Cancelled',
        'rejected'  => 'Rejected',
    ];

    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Order')
                    ->columns(2)
                    ->schema([
                        TextInput::make('order_number')
                            ->disabled(),

                        Select::make('status')
                            ->options(self::STATUSES)
                            ->required()
                            ->native(false)
                            ->helperText('Confirmed / Cancelled / Rejected / Delivered notify the customer in-app.'),

                        TextInput::make('total')
                            ->numeric()
                            ->prefix('$')
                            ->disabled(),

                        TextInput::make('delivery_address')
                            ->disabled()
                            ->columnSpanFull(),
                    ]),

                Section::make('Items')
                    ->schema([
                        RepeatableEntry::make('items')
                            ->hiddenLabel()
                            ->columns(3)
                            ->schema([
                                TextEntry::make('plant_name')->label('Plant'),
                                TextEntry::make('quantity')->label('Qty'),
                                TextEntry::make('price')->money('USD'),
                            ]),
                    ]),
            ]);
    }
}
