<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Plant;

class PlantController extends Controller
{
    public function index()
    {
        $plants = Plant::orderBy('id')->get()->map(fn (Plant $plant) => [
            'id'             => (int) $plant->id,
            'image'          => $plant->imageUrl(),
            'name'           => $plant->name,
            'type'           => $plant->type,
            'type_plant'     => $plant->type_plant,
            'price'          => (float) $plant->price,
            'description'    => $plant->description,
            'rating'         => (float) $plant->rating,
            'counting'       => (int) $plant->counting,
            'is_popular'     => (bool) $plant->is_popular,
            'discount_price' => $plant->discount_price !== null ? (float) $plant->discount_price : null,
        ]);

        return response()->json([
            'success' => true,
            'plants'  => $plants,
        ]);
    }
}
