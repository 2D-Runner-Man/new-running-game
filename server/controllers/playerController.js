const Player = require('../models/playerModel');

exports.getAllPlayers = async (req, res) => {
    const players = await Player.getAll();
    res.json(players);
};

exports.getPlayerById = async (req, res) => {
    const player = await Player.getById(req.params.id);
    player ? res.json(player) : res.status(404).json({ error: 'Player not found' });
};

exports.createPlayer = async (req, res) => {
    const newPlayer = await Player.create(req.body);
    res.status(201).json(newPlayer);
};

exports.updatePlayer = async (req, res) => {
    const updatedPlayer = await Player.update(req.params.id, req.body);
    res.json(updatedPlayer);
};

exports.deletePlayer = async (req, res) => {
    await Player.delete(req.params.id);
    res.status(204).end();
};
