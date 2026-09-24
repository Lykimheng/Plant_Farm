<?php

namespace App\Filament\Widgets;

use App\Models\Order;
use Filament\Widgets\ChartWidget;

class OrderStatusChart extends ChartWidget
{
    protected ?string $heading = 'Orders by status';

    protected function getData(): array
    {
        $labels = [
            'pending'   => 'Pending',
            'confirmed' => 'Confirmed',
            'preparing' => 'Preparing',
            'inTransit' => 'In Transit',
            'delivered' => 'Delivered',
            'cancelled' => 'Cancelled',
            'rejected'  => 'Rejected',
        ];

        $counts = Order::selectRaw('status, COUNT(*) as total')
            ->groupBy('status')
            ->pluck('total', 'status');

        // Only show statuses that actually occur, so the chart isn't mostly zeros
        $present = array_filter($labels, fn ($_, $key) => ($counts[$key] ?? 0) > 0, ARRAY_FILTER_USE_BOTH);

        return [
            'datasets' => [[
                'label' => 'Orders',
                'data' => array_map(fn ($key) => $counts[$key] ?? 0, array_keys($present)),
                'backgroundColor' => [
                    '#F5B54A', '#3FD397', '#4A9DF5',
                    '#8B87FF', '#17696E', '#FF6B6B', '#D03A3A',
                ],
            ]],
            'labels' => array_values($present),
        ];
    }

    protected function getType(): string
    {
        return 'doughnut';
    }
}
