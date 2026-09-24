<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;

/**
 * Deleting a customer used to fail with a foreign key violation: `orders` and
 * `notifications` referenced `users` with no delete rule, so MySQL refused to
 * remove the parent row. `my_plants` had no constraint at all, which left
 * orphaned rows behind instead.
 *
 * This makes a user's own records go with them, matching `reviews`, which
 * already cascaded.
 */
return new class extends Migration
{
    /** [table, column, referenced table] */
    private array $links = [
        ['orders', 'user_id', 'users'],
        ['notifications', 'user_id', 'users'],
        ['my_plants', 'user_id', 'users'],
    ];

    public function up(): void
    {
        foreach ($this->links as [$table, $column, $parent]) {
            if (! Schema::hasTable($table)) {
                continue;
            }

            $this->dropForeignKey($table, $column);

            // a constraint can't be added while rows point at a user that no
            // longer exists, which is exactly what the missing my_plants key
            // allowed to happen
            $this->deleteOrphans($table, $column, $parent);

            Schema::table($table, function ($blueprint) use ($column, $parent) {
                $blueprint->foreign($column)->references('id')->on($parent)->cascadeOnDelete();
            });
        }
    }

    public function down(): void
    {
        foreach ($this->links as [$table, $column, $parent]) {
            if (! Schema::hasTable($table)) {
                continue;
            }

            $this->dropForeignKey($table, $column);

            // my_plants had no constraint before this migration
            if ($table === 'my_plants') {
                continue;
            }

            Schema::table($table, function ($blueprint) use ($column, $parent) {
                $blueprint->foreign($column)->references('id')->on($parent);
            });
        }
    }

    /**
     * The original schema was hand-written, so constraints carry MySQL's
     * generated names (`notifications_ibfk_1`) rather than Laravel's. Look the
     * real name up instead of guessing it.
     */
    private function dropForeignKey(string $table, string $column): void
    {
        $names = DB::select(
            'SELECT CONSTRAINT_NAME AS name
             FROM information_schema.KEY_COLUMN_USAGE
             WHERE CONSTRAINT_SCHEMA = DATABASE()
               AND TABLE_NAME = ?
               AND COLUMN_NAME = ?
               AND REFERENCED_TABLE_NAME IS NOT NULL',
            [$table, $column]
        );

        foreach ($names as $constraint) {
            DB::statement("ALTER TABLE `{$table}` DROP FOREIGN KEY `{$constraint->name}`");
        }
    }

    private function deleteOrphans(string $table, string $column, string $parent): void
    {
        DB::table($table)
            ->whereNotIn($column, DB::table($parent)->select('id'))
            ->delete();
    }
};
