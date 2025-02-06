// require('dotenv').config({ path: __dirname + '/.env' }); // Load .env from server directory
const path = require('path');

// Ensure paths are correct relative to the project root
const migrationsDirectory = path.join(__dirname, 'db', 'migrations');
const seedsDirectory = path.join(__dirname, 'db', 'seeds');

console.log("Migrations Directory:", migrationsDirectory);
console.log("Seeds Directory:", seedsDirectory);

module.exports = {
  development: {
    client: 'pg',
    connection: {
      host:'127.0.0.1',
      port: 5432,
      user:'jahmari',
      password: '1234',
      database: 'running_game_database',
    },
    migrations: {
      directory: migrationsDirectory,
    },
    seeds: {
      directory: seedsDirectory,
    },
  },
};
