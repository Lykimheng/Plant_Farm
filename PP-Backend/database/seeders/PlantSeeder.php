<?php

namespace Database\Seeders;

use App\Models\Plant;
use Illuminate\Database\Seeder;

/**
 * Starter catalog. Safe to re-run: it does nothing once plants exist.
 */
class PlantSeeder extends Seeder
{
    public function run(): void
    {
        if (Plant::exists()) {
            $this->command->info('Plants already seeded — skipping.');

            return;
        }

        $catalog = [
            [
                'image' => 'Cactus.png', 'name' => 'Cactus',
                'type' => 'Indoor Plant', 'type_plant' => 'indoorPlant',
                'price' => 5.00, 'rating' => 5.0, 'counting' => 39,
                'description' => 'Adapted to arid environments, this low-maintenance succulent thrives on bright light and very little water.',
                'variants' => [
                    ['is_popular' => true,  'discount_price' => 3.50],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                ],
            ],
            [
                'image' => 'Showy Spindletree Euonymus japonicus.png',
                'name' => 'Showy Spindletree Euonymus japonicus',
                'type' => 'Outdoor Plant', 'type_plant' => 'outdoorPlant',
                'price' => 7.00, 'rating' => 4.9, 'counting' => 45,
                'description' => 'An aromatic flowering shrub with glossy evergreen leaves, well suited to borders and hedging.',
                'variants' => [
                    ['is_popular' => true,  'discount_price' => 5.00],
                    ['is_popular' => false, 'discount_price' => 6.00],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                ],
            ],
            [
                'image' => 'Maianthemum.png', 'name' => 'Maianthemum',
                'type' => 'Aquatic Plant', 'type_plant' => 'aquaticPlant',
                'price' => 9.00, 'rating' => 4.9, 'counting' => 22,
                'description' => 'A sacred aquatic flower prized for its delicate blooms and calm, water-loving nature.',
                'variants' => [
                    ['is_popular' => true,  'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => 5.00],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                ],
            ],
            [
                'image' => 'Mango.png', 'name' => 'Mango',
                'type' => 'Big Tree', 'type_plant' => 'bigTree',
                'price' => 45.00, 'rating' => 5.0, 'counting' => 12,
                'description' => 'A majestic fruiting tree that rewards patience with generous shade and a heavy seasonal harvest.',
                'variants' => [
                    ['is_popular' => true,  'discount_price' => 10.00],
                    ['is_popular' => false, 'discount_price' => 12.00],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                    ['is_popular' => false, 'discount_price' => null],
                ],
            ],
        ];

        foreach ($catalog as $entry) {
            $variants = $entry['variants'];
            unset($entry['variants']);

            foreach ($variants as $variant) {
                Plant::create($entry + $variant);
            }
        }

        $this->command->info('Seeded '.Plant::count().' plants.');
    }
}
