<?php

namespace App\Filament\Resources\Reviews\Tables;

use App\Models\Review;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Filters\Filter;
use Filament\Tables\Filters\SelectFilter;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ReviewsTable
{
    public static function configure(Table $table): Table
    {
        return $table
            ->columns([
                TextColumn::make('plant.name')
                    ->label('Plant')
                    ->searchable()
                    ->sortable(),

                TextColumn::make('user.name')
                    ->label('Customer')
                    ->searchable()
                    ->placeholder('—'),

                TextColumn::make('rating')
                    ->badge()
                    ->formatStateUsing(fn (int $state) => str_repeat('★', $state))
                    ->color(fn (int $state) => match (true) {
                        $state >= 4 => 'success',
                        $state == 3 => 'warning',
                        default     => 'danger',
                    })
                    ->sortable(),

                TextColumn::make('body')
                    ->label('Review')
                    ->limit(60)
                    ->wrap()
                    ->placeholder('— no text —'),

                TextColumn::make('hidden_at')
                    ->label('Status')
                    ->badge()
                    ->formatStateUsing(fn ($state) => $state ? 'Hidden' : 'Visible')
                    ->color(fn ($state) => $state ? 'danger' : 'success')
                    ->default(null),

                TextColumn::make('created_at')
                    ->label('Posted')
                    ->dateTime('M j, Y')
                    ->sortable(),
            ])
            ->defaultSort('created_at', 'desc')
            ->filters([
                SelectFilter::make('rating')
                    ->options([5 => '5 star', 4 => '4 star', 3 => '3 star', 2 => '2 star', 1 => '1 star']),

                Filter::make('hidden')
                    ->label('Hidden only')
                    ->query(fn (Builder $query) => $query->whereNotNull('hidden_at')),
            ])
            ->recordActions([
                // Moderation only — admins never author or edit review text.
                Action::make('toggleVisibility')
                    ->label(fn (Review $record) => $record->isHidden() ? 'Unhide' : 'Hide')
                    ->icon(fn (Review $record) => $record->isHidden() ? 'heroicon-o-eye' : 'heroicon-o-eye-slash')
                    ->color(fn (Review $record) => $record->isHidden() ? 'success' : 'warning')
                    ->requiresConfirmation()
                    ->modalDescription(fn (Review $record) => $record->isHidden()
                        ? 'This review will appear in the app again and count toward the rating.'
                        : 'This review will be removed from the app and stop counting toward the rating. The text is kept.')
                    ->action(function (Review $record) {
                        // save() (not a mass update) so the model hook refreshes
                        // the plant's cached rating
                        $record->hidden_at = $record->isHidden() ? null : now();
                        $record->save();
                    }),

                DeleteAction::make(),
            ]);
    }
}
