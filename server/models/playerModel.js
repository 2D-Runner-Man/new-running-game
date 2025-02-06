const knex = require('../knex');

class Player {
    static getAll() {
        return knex('players').select('*');
    }

    static getById(id) {
        return knex('players').where({ id }).first();
    }

    static create(player) {
        return knex('players').insert(player).returning('*');
    }

    static update(id, updates) {
        return knex('players').where({ id }).update(updates).returning('*');
    }

    static delete(id) {
        return knex('players').where({ id }).del();
    }
}

module.exports = Player;
