<?php

namespace App\Filament\Resources\Plants\Schemas;

use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\Toggle;
use Filament\Schemas\Components\Section;
use Filament\Schemas\Schema;
use Illuminate\Support\Str;

class PlantForm
{
    /**
     * The mobile app filters the catalog on these exact `type_plant` values and
     * builds its category icon URL from them, so they must stay a fixed set.
     */
    public const CATEGORIES = [
        'indoorPlant'  => 'Indoor Plant',
        'outdoorPlant' => 'Outdoor Plant',
        'aquaticPlant' => 'Aquatic Plant',
        'bigTree'      => 'Big Tree',
    ];

    public static function configure(Schema $schema): Schema
    {
        return $schema
            ->components([
                Section::make('Plant Details')
                    ->columns(2)
                    ->schema([
                        TextInput::make('name')
                            ->required()
                            ->maxLength(255),

                        Select::make('type_plant')
                            ->label('Category')
                            ->options(self::CATEGORIES)
                            ->required()
                            ->live()
                            // keep the display label in sync with the category key
                            ->afterStateUpdated(fn ($state, callable $set) => $set(
                                'type',
                                self::CATEGORIES[$state] ?? null
                            ))
                            ->helperText('Controls which Home tab the plant appears under.'),

                        TextInput::make('type')
                            ->label('Category label')
                            ->required()
                            ->maxLength(100)
                            ->helperText('Shown on the plant card. Auto-filled from the category.'),

                        Textarea::make('description')
                            ->required()
                            ->rows(3)
                            ->columnSpanFull(),
                    ]),

                Section::make('Pricing')
                    ->columns(2)
                    ->schema([
                        TextInput::make('price')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->prefix('$'),

                        TextInput::make('discount_price')
                            ->numeric()
                            ->minValue(0)
                            ->prefix('$')
                            ->helperText('Leave empty for no discount. Setting this puts the plant in "Special Offer".'),
                    ]),

                Section::make('Image')
                    ->schema([
                        FileUpload::make('image')
                            ->image()
                            ->required()
                            ->disk('plants')          // stores the bare filename
                            ->visibility('public')
                            ->imagePreviewHeight('180')
                            ->maxSize(5120)
                            ->getUploadedFileNameForStorageUsing(
                                fn ($file) => Str::slug(
                                    pathinfo($file->getClientOriginalName(), PATHINFO_FILENAME)
                                ).'-'.Str::random(6).'.'.$file->getClientOriginalExtension()
                            )
                            ->helperText('Served to the app from /uploads/plants.'),
                    ]),

                Section::make('Display')
                    ->columns(3)
                    ->schema([
                        Toggle::make('is_popular')
                            ->label('Show in Popular')
                            ->inline(false),

                        TextInput::make('rating')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->maxValue(5)
                            ->step(0.1)
                            ->default(5.0),

                        TextInput::make('counting')
                            ->label('Review count')
                            ->required()
                            ->numeric()
                            ->minValue(0)
                            ->default(0),
                    ]),
            ]);
    }
}
