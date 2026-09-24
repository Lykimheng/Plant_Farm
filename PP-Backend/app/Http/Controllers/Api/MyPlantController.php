<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\MyPlant;
use Illuminate\Http\Request;

class MyPlantController extends Controller
{
    /**
     * Older clients send a full image URL while newer data stores just the
     * filename. Normalise on write so the stored value never hardcodes a host.
     */
    private function toFilename(string $image): string
    {
        if ($image === '') {
            return '';
        }

        return rawurldecode(basename(parse_url($image, PHP_URL_PATH) ?: $image));
    }

    private function toUrl(string $image): string
    {
        if ($image === '') {
            return '';
        }

        return url('uploads/plants/'.rawurlencode($this->toFilename($image)));
    }

    public function index(Request $request)
    {
        $userId = (int) $request->query('user_id', 0);

        $plants = MyPlant::where('user_id', $userId)
            ->orderByDesc('added_date')
            ->get()
            ->map(fn (MyPlant $plant) => [
                'id'            => (int) $plant->id,
                'user_id'       => (int) $plant->user_id,
                'image'         => $this->toUrl((string) $plant->image),
                'name'          => $plant->name,
                'species'       => $plant->species,
                'care_level'    => $plant->care_level,
                'next_watering' => $plant->next_watering,
                'sunlight'      => $plant->sunlight,
                'added_date'    => optional($plant->added_date)->format('Y-m-d H:i:s'),
            ]);

        return response()->json([
            'success' => true,
            'plants'  => $plants,
        ]);
    }

    public function store(Request $request)
    {
        $userId = (int) $request->input('user_id', 0);
        $name   = $this->stringInput($request, 'name');

        if ($userId === 0 || $name === '') {
            return response()->json([
                'success' => false,
                'message' => 'Missing required fields.',
            ]);
        }

        $plant = MyPlant::create([
            'user_id'       => $userId,
            'image'         => $this->toFilename($this->stringInput($request, 'image')),
            'name'          => $name,
            // species is optional in the app, so a blank one must save cleanly
            'species'       => $this->stringInput($request, 'species'),
            'care_level'    => $this->stringInput($request, 'care_level', 'easy'),
            'next_watering' => $this->stringInput($request, 'next_watering'),
            'sunlight'      => $this->stringInput($request, 'sunlight'),
        ]);

        return response()->json([
            'success'  => true,
            'message'  => 'Plant added.',
            'plant_id' => (int) $plant->id,
        ]);
    }

    public function destroy(Request $request)
    {
        $plantId = (int) $request->input('plant_id', 0);
        $userId  = (int) $request->input('user_id', 0);

        MyPlant::where('id', $plantId)->where('user_id', $userId)->delete();

        return response()->json([
            'success' => true,
            'message' => 'Plant removed.',
        ]);
    }
}
