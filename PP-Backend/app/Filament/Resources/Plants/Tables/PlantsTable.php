<?php

namespace App\Filament\Resources\Plants\Tables;

use App\Filament\Resources\Plants\Schemas\PlantForm;
use Filament\Actions\BulkActionGroup;
use Filament\Actions\DeleteBulkAction;
use Filament\Actions\EditAction;
use Filament\Tables\Columns\IconColumn;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Filters\TernaryFilter;
use Filament\Tables\Table;

class PlantsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                ImageColumn::make('image')
                    ->disk('plants')
                    ->square()
                    ->size(56),

                TextColumn::make('name')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('type')
                    ->label('Category')
                    ->badge()
                    ->sortable(),

                TextColumn::make('price')
                    ->money('USD')
                    ->sortable(),

                TextColumn::make('discount_price')
                    ->label('Discount')
                    ->money('USD')
                    ->placeholder('—')
                    ->sortable(),

                IconColumn::make('is_popular')
                    ->label('Popular')
                    ->boolean()
                    ->sortable(),

                TextColumn::make('rating')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),

                TextColumn::make('counting')
                    ->label('Reviews')
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->defaultSort('id')
            ->filters([
                SelectFilter::make('type_plant')
                    ->label('Category')
                    ->options(PlantForm::CATEGORIES),

                TernaryFilter::make('is_popular')
                    ->label('Popular'),

                TernaryFilter::make('discount_price')
                    ->label('On offer')
                    ->nullable(),
            ])
            ->recordActions([
                EditAction::make(),
            ])
            ->toolbarActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}
