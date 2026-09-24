<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Widgets\ChartWidget;
use Illuminate\Support\Carbon;

class RevenueChart extends ChartWidget
{
    protected ?string $heading = 'Revenue — last 30 days';

    protected int|string|array $columnSpan = 'full';

    protected function getData(): array
    {
        $start = Carbon::now()->subDays(29)->startOfDay();

        // One grouped query, then fill the gaps — days with no orders still need
        // a zero point or the line would skip them and misrepresent the trend.
        $totals = Order::whereNotIn('status', ['cancelled', 'rejected'])
            ->where('created_at', '>=', $start)
            ->selectRaw('DATE(created_at) as day, SUM(total) as revenue')
            ->groupBy('day')
            ->pluck('revenue', 'day');

        $labels = [];
        $values = [];

        for ($i = 0; $i < 30; $i++) {
            $date = $start->copy()->addDays($i);
            $key = $date->format('Y-m-d');

            $labels[] = $date->format('M j');
            $values[] = round((float) ($totals[$key] ?? 0), 2);
        }

        return [
            'datasets' => [[
                'label' => 'Revenue ($)',
                'data' => $values,
                'borderColor' => '#17696E',
                'backgroundColor' => 'rgba(23, 105, 110, 0.12)',
                'fill' => true,
                'tension' => 0.3,
            ]],
            'labels' => $labels,
        ];
    }

    protected function getType(): string
    {
        return 'line';
    }
}
