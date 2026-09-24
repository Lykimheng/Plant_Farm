<?php

namespace App\Filament\Resources\Orders\Tables;

use App\Filament\Resources\Orders\Schemas\OrderForm;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;

class OrdersTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('order_number')
                    ->label('Order #')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('user.name')
                    ->label('Customer')
                    ->searchable()
                    ->placeholder('—'),

                TextColumn::make('status')
                    ->badge()
                    ->formatStateUsing(fn (string $state) => OrderForm::STATUSES[$state] ?? $state)
                    ->color(fn (string $state) => match ($state) {
                        'delivered', 'confirmed' => 'success',
                        'cancelled', 'rejected'  => 'danger',
                        'inTransit', 'preparing' => 'info',
                        default                  => 'warning',
                    })
                    ->sortable(),

                TextColumn::make('items_count')
                    ->counts('items')
                    ->label('Items'),

                TextColumn::make('total')
                    ->money('USD')
                    ->sortable(),

                TextColumn::make('created_at')
                    ->label('Placed')
                    ->dateTime('M j, Y g:i A')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('status')->options(OrderForm::STATUSES),
            ])
            ->recordActions([
                EditAction::make(),
            ]);
    }
}
