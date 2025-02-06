/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */

exports.seed = function(knex) {
    return knex('players').del()
        .then(() => {
            return knex('players').insert([
                { name: 'Player1', score: 10, lives: 3 },
                { name: 'Player2', score: 20, lives: 4 },
            ]);
        });
};
