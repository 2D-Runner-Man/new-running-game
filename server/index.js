const express = require('express');
const { saveScore, getHighScores } = require('./scoreService');

const app = express();
app.use(express.json());

// Endpoint to save a player's score
app.post('/save-score', async (req, res) => {
    const { name, score } = req.body;
    if (!name || typeof score !== 'number') {
        return res.status(400).json({ error: "Invalid data" });
    }

    try {
        await saveScore(name, score);
        res.json({ message: "Score saved successfully" });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Endpoint to get high scores
app.get('/high-scores', async (req, res) => {
    try {
        const scores = await getHighScores();
        res.json(scores);
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

// Start the server
const PORT = 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
