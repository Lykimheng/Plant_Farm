<?php

namespace App\Filament\Resources\Users\Pages;

use App\Filament\Resources\Users\UserResource;
use App\Models\User;
use Filament\Actions\DeleteAction;
use Filament\Resources\Pages\EditRecord;

class EditUser extends EditRecord
{
    protected static string $resource = UserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            DeleteAction::make()
                // deleting a customer now cascades to their orders, notifications,
                // saved plants and reviews, so spell that out before confirming
                ->modalDescription(fn (User $record) => $this->deletionSummary($record)),
        ];
    }

    private function deletionSummary(User $record): string
    {
        $counts = array_filter([
            'order' => $record->orders()->count(),
            'saved plant' => $record->myPlants()->count(),
            'notification' => $record->appNotifications()->count(),
        ]);

        if ($counts === []) {
            return "Delete {$record->name}? This can't be undone.";
        }

        $parts = [];
        foreach ($counts as $label => $count) {
            $parts[] = $count.' '.$label.($count === 1 ? '' : 's');
        }

        $last = array_pop($parts);
        $list = $parts ? implode(', ', $parts).' and '.$last : $last;

        return "Deleting {$record->name} also removes their {$list}. This can't be undone.";
    }
}
