<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Plant Farm domain tables, mirroring the original plain-PHP schema so existing
 * data survives the move to Laravel.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasTable('plants')) {
            Schema::create('plants', function (Blueprint $table) {
                $table->increments('id');
                $table->string('image');
                $table->string('name');
                $table->string('type', 100);
                $table->string('type_plant', 50);
                $table->decimal('price', 10, 2);
                $table->text('description');
                $table->decimal('rating', 2, 1)->default(0);
                $table->integer('counting')->default(0);
                $table->boolean('is_popular')->default(false);
                $table->decimal('discount_price', 10, 2)->nullable();
            });
        }

        if (! Schema::hasTable('orders')) {
            Schema::create('orders', function (Blueprint $table) {
                $table->increments('id');
                $table->unsignedInteger('user_id');
                $table->string('order_number', 50)->unique();
                $table->enum('status', [
                    'pending', 'confirmed', 'preparing',
                    'inTransit', 'delivered', 'cancelled', 'rejected',
                ])->default('pending');
                $table->decimal('total', 10, 2);
                $table->string('delivery_address');
                $table->dateTime('created_at')->useCurrent();

                $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            });
        }

        if (! Schema::hasTable('order_items')) {
            Schema::create('order_items', function (Blueprint $table) {
                $table->increments('id');
                $table->unsignedInteger('order_id');
                $table->integer('plant_id');
                $table->string('plant_name', 100);
                $table->decimal('price', 10, 2);
                $table->integer('quantity');

                $table->foreign('order_id')->references('id')->on('orders')->cascadeOnDelete();
            });
        }

        // the original schema typed plant_id as VARCHAR, which broke JSON decoding
        // in the iOS client — normalise it wherever the old column is still around
        if (Schema::hasTable('order_items')) {
            $type = Schema::getColumnType('order_items', 'plant_id');
            if (! in_array($type, ['integer', 'int', 'bigint'], true)) {
                DB::statement('ALTER TABLE order_items MODIFY plant_id INT NOT NULL');
            }
        }

        if (! Schema::hasTable('my_plants')) {
            Schema::create('my_plants', function (Blueprint $table) {
                $table->increments('id');
                $table->unsignedInteger('user_id');
                $table->string('image')->default('');
                $table->string('name');
                $table->string('species')->default('');
                $table->enum('care_level', ['easy', 'moderate', 'expert'])->default('easy');
                $table->string('next_watering', 100)->default('');
                $table->string('sunlight', 100)->default('');
                $table->timestamp('added_date')->useCurrent();

                $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            });
        }

        if (! Schema::hasTable('notifications')) {
            Schema::create('notifications', function (Blueprint $table) {
                $table->increments('id');
                $table->unsignedInteger('user_id');
                $table->string('title', 150);
                $table->string('message');
                $table->string('type', 50);
                $table->boolean('is_read')->default(false);
                $table->dateTime('created_at')->useCurrent();

                $table->foreign('user_id')->references('id')->on('users')->cascadeOnDelete();
            });
        }
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
        Schema::dropIfExists('my_plants');
        Schema::dropIfExists('order_items');
        Schema::dropIfExists('orders');
        Schema::dropIfExists('plants');
    }
};
