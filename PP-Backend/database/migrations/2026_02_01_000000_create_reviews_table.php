<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * MySQL only accepts a foreign key when the child column's type matches the
     * parent's exactly, including signedness. A database carried over from the
     * original PHP backend has signed `int` ids, while a fresh Laravel install
     * creates unsigned ones — so mirror whatever is actually there.
     */
    private function referencesUnsignedIds(): bool
    {
        $column = DB::selectOne(
            'SELECT COLUMN_TYPE AS type FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
            ['plants', 'id']
        );

        return $column !== null && str_contains(strtolower($column->type), 'unsigned');
    }

    public function up(): void
    {
        if (Schema::hasTable('reviews')) {
            return;
        }

        $unsigned = $this->referencesUnsignedIds();

        Schema::create('reviews', function (Blueprint $table) use ($unsigned) {
            $table->increments('id');

            if ($unsigned) {
                $table->unsignedInteger('plant_id');
                $table->unsignedInteger('user_id');
            } else {
                $table->integer('plant_id');
                $table->integer('user_id');
            }

            $table->unsignedTinyInteger('rating');
            $table->text('body')->nullable();
            // Lets an admin pull a review from the app without destroying it.
            // Hidden reviews stop counting toward the plant's average.
            $table->timestamp('hidden_at')->nullable();
            $table->timestamps();

            $table->foreign('plant_id')->references('id')->on('plants')->cascadeOnDelete();
            $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();

            // one review per person per plant — posting again edits it
            $table->unique(['plant_id', 'user_id']);
            $table->index(['plant_id', 'hidden_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('reviews');
    }
};
