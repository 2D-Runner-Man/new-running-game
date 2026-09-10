/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = function(knex) {
    return knex('players').del()
        .then(() => {
            return knex('players')
        });
};
