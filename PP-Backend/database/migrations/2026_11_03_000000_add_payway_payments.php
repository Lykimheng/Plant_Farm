<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Online payment through ABA PayWay. Each attempt to pay an order is a
 * `payments` row with its own PayWay transaction id, and the order only
 * becomes paid when PayWay itself reports one of them approved.
 */
return new class extends Migration
{
    public function up(): void
    {
        if (! Schema::hasColumn('orders', 'payment_status')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->string('payment_method', 10)->default('cod');
                $table->string('payment_status', 10)->default('unpaid');
                $table->dateTime('paid_at')->nullable();
            });
        }

        if (Schema::hasTable('payments')) {
            return;
        }

        $unsigned = $this->ordersHaveUnsignedIds();

        Schema::create('payments', function (Blueprint $table) use ($unsigned) {
            $table->increments('id');

            if ($unsigned) {
                $table->unsignedInteger('order_id');
            } else {
                $table->integer('order_id');
            }

            $table->string('tran_id', 20)->unique();
            $table->string('method', 10);
            $table->decimal('amount', 10, 2);
            $table->string('currency', 3);
            $table->string('status', 10)->default('pending');
            $table->string('apv', 20)->nullable();
            $table->text('deeplink')->nullable();
            $table->text('qr_string')->nullable();
            $table->dateTime('expires_at');
            $table->dateTime('paid_at')->nullable();
            $table->timestamps();

            $table->foreign('order_id')->references('id')->on('orders')->cascadeOnDelete();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('payments');

        if (Schema::hasColumn('orders', 'payment_status')) {
            Schema::table('orders', function (Blueprint $table) {
                $table->dropColumn(['payment_method', 'payment_status', 'paid_at']);
            });
        }
    }

    /** Same check as the reviews migration: carried-over databases have signed ids. */
    private function ordersHaveUnsignedIds(): bool
    {
        if (! in_array(DB::getDriverName(), ['mysql', 'mariadb'], true)) {
            return true;
        }

        $column = DB::selectOne(
            'SELECT COLUMN_TYPE AS type FROM information_schema.COLUMNS
             WHERE TABLE_SCHEMA = DATABASE() AND TABLE_NAME = ? AND COLUMN_NAME = ?',
            ['orders', 'id']
        );

        return $column !== null && str_contains(strtolower($column->type), 'unsigned');
    }
};
