const express = require('express');
const router = express.Router();
const db = require('../config/database');

// Get all restaurants (with optional cuisine filter)
router.get('/', async (req, res) => {
    try {
        const { cuisine } = req.query;

        let query = 'SELECT * FROM restaurants';
        let params = [];

        if (cuisine && cuisine !== 'All') {
            query += ' WHERE cuisine = ?';
            params.push(cuisine);
        }

        const [restaurants] = await db.query(query, params);
        res.json(restaurants);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get restaurant by ID with menu items
router.get('/:id', async (req, res) => {
    try {
        const { id } = req.params;

        const [restaurants] = await db.query('SELECT * FROM restaurants WHERE id = ?', [id]);
        if (restaurants.length === 0) {
            return res.status(404).json({ error: 'Restaurant not found' });
        }

        const [menuItems] = await db.query('SELECT * FROM menu_items WHERE restaurant_id = ?', [id]);

        res.json({
            ...restaurants[0],
            menuItems
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get menu items for a restaurant
router.get('/:id/menu', async (req, res) => {
    try {
        const { id } = req.params;
        const [menuItems] = await db.query('SELECT * FROM menu_items WHERE restaurant_id = ?', [id]);
        res.json(menuItems);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
