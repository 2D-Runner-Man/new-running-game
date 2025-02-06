require('dotenv').config({ path: __dirname + '/.env' }); // Load .env from server directory
const path = require('path');

// Ensure paths are correct relative to the project root
const migrationsDirectory = path.join(__dirname, 'db', 'migrations');
const seedsDirectory = path.join(__dirname, 'db', 'seeds');

console.log("Migrations Directory:", migrationsDirectory);
console.log("Seeds Directory:", seedsDirectory);

module.exports = {
  development: {
    client: 'pg',
    connection: process.env.PG_CONNECTION_STRING || {
      host: process.env.PG_HOST || '127.0.0.1',
      port: process.env.PG_PORT || 5432,
      user: process.env.PG_USER || 'jahmari',
      password: process.env.PG_PASS || '1234',
      database: process.env.PG_DB || 'running_game_database',
    },
    migrations: {
      directory: migrationsDirectory,
    },
    seeds: {
      directory: seedsDirectory,
    },
  },
  production: {
    client: 'pg',
    connection: process.env.PG_CONNECTION_STRING,
    migrations: {
      directory: migrationsDirectory,
    },
    seeds: {
      directory: seedsDirectory,
    },
  },
};
