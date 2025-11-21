const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../config/database');
const authMiddleware = require('../middleware/auth');

// Get user's addresses
router.get('/', authMiddleware, async (req, res) => {
    try {
        const [addresses] = await db.query('SELECT * FROM addresses WHERE user_id = ?', [req.userId]);
        res.json(addresses);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create new address
router.post('/', authMiddleware, async (req, res) => {
    try {
        const { houseNumber, street, locality, city, state, pincode, landmark, latitude, longitude } = req.body;

        const addressId = uuidv4();
        await db.query(
            'INSERT INTO addresses (id, user_id, house_number, street, locality, city, state, pincode, landmark, latitude, longitude) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)',
            [addressId, req.userId, houseNumber, street, locality, city, state, pincode, landmark, latitude, longitude]
        );

        const [newAddress] = await db.query('SELECT * FROM addresses WHERE id = ?', [addressId]);
        res.status(201).json(newAddress[0]);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Delete address
router.delete('/:id', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;

        const result = await db.query('DELETE FROM addresses WHERE id = ? AND user_id = ?', [id, req.userId]);
        if (result[0].affectedRows === 0) {
            return res.status(404).json({ error: 'Address not found' });
        }

        res.json({ message: 'Address deleted successfully' });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
