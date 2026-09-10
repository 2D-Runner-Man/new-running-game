/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
    return knex.schema.createTable('players', function(table) {
      table.increments('id').primary();
      table.string('name').notNullable();
      table.integer('score').defaultTo(0);
    });
  };

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
  exports.down = function(knex) {
    return knex.schema.dropTableIfExists('players');
  };
