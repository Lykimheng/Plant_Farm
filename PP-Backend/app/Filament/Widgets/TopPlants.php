<?php

namespace App\Filament\Widgets;

use App\Models\Plant;
use Filament\Tables\Columns\ImageColumn;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Filament\Widgets\TableWidget;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Support\Facades\DB;

class TopPlants extends TableWidget
{
    protected static ?string $heading = 'Best sellers';

    protected int|string|array $columnSpan = 'full';

    public function table(Table $table): Table
    {
        return $table
            ->query(
                Plant::query()
                    // units sold and money earned, ignoring orders that fell through
                    ->withSum(['orderItems as units_sold' => fn (Builder $q) => $q
                        ->whereHas('order', fn (Builder $o) => $o->whereNotIn('status', ['cancelled', 'rejected'])),
                    ], 'quantity')
                    // revenue is price × quantity — summing `price` alone would
                    // only add up unit prices and undercount every multi-item line
                    ->withSum(['orderItems as revenue' => fn (Builder $q) => $q
                        ->whereHas('order', fn (Builder $o) => $o->whereNotIn('status', ['cancelled', 'rejected'])),
                    ], DB::raw('price * quantity'))
                    ->having('units_sold', '>', 0)
                    ->orderByDesc('units_sold')
                    ->limit(5)
            )
            ->paginated(false)
            ->columns([
                ImageColumn::make('image')->disk('plants')->square()->size(40)->label(''),
                TextColumn::make('name')->searchable(),
                TextColumn::make('type')->label('Category')->badge(),
                TextColumn::make('units_sold')->label('Units sold')->sortable(),
                TextColumn::make('revenue')->money('USD')->label('Revenue'),
            ])
            ->emptyStateHeading('No sales yet')
            ->emptyStateDescription('Best sellers appear here once customers start ordering.');
    }
}
