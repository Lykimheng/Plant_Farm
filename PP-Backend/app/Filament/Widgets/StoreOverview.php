<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use App\Models\Plant;
use App\Models\Review;
use App\Models\User;
use Filament\Widgets\StatsOverviewWidget;
use Filament\Widgets\StatsOverviewWidget\Stat;
use Illuminate\Support\Carbon;

class StoreOverview extends StatsOverviewWidget
{
    protected ?string $pollingInterval = null;

    protected function getStats(): array
    {
        // Cancelled and rejected orders never became money, so they're excluded
        // from revenue but still counted as orders placed.
        $earned = Order::whereNotIn('status', ['cancelled', 'rejected']);

        $revenue = (float) (clone $earned)->sum('total');
        $thisMonth = (float) (clone $earned)
            ->where('created_at', '>=', Carbon::now()->startOfMonth())
            ->sum('total');

        $orderCount = Order::count();
        $pending = Order::where('status', 'pending')->count();

        $customers = User::where('is_admin', false)->count();
        $newCustomers = User::where('is_admin', false)
            ->where('created_at', '>=', Carbon::now()->startOfMonth())
            ->count();

        $reviewCount = Review::whereNull('hidden_at')->count();
        $averageRating = (float) Review::whereNull('hidden_at')->avg('rating');

        return [
            Stat::make('Revenue', '$'.number_format($revenue, 2))
                ->description('$'.number_format($thisMonth, 2).' this month')
                ->descriptionIcon('heroicon-m-banknotes')
                ->color('success'),

            Stat::make('Orders', (string) $orderCount)
                ->description($pending.' awaiting confirmation')
                ->descriptionIcon('heroicon-m-clock')
                ->color($pending > 0 ? 'warning' : 'gray'),

            Stat::make('Customers', (string) $customers)
                ->description($newCustomers.' joined this month')
                ->descriptionIcon('heroicon-m-user-plus')
                ->color('info'),

            Stat::make('Plants', (string) Plant::count())
                ->description($reviewCount > 0
                    ? number_format($averageRating, 1).'★ from '.$reviewCount.' reviews'
                    : 'No reviews yet')
                ->descriptionIcon('heroicon-m-star')
                ->color('primary'),
        ];
    }
}
