const express = require('express');
const router = express.Router();
const { v4: uuidv4 } = require('uuid');
const db = require('../config/database');
const authMiddleware = require('../middleware/auth');

// Get user's orders
router.get('/', authMiddleware, async (req, res) => {
    try {
        const [orders] = await db.query(`
      SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image
      FROM orders o
      JOIN restaurants r ON o.restaurant_id = r.id
      WHERE o.user_id = ?
      ORDER BY o.created_at DESC
    `, [req.userId]);

        res.json(orders);
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Get order details by ID
router.get('/:id', authMiddleware, async (req, res) => {
    try {
        const { id } = req.params;

        const [orders] = await db.query(`
      SELECT o.*, r.name as restaurant_name, r.image_url as restaurant_image,
             a.house_number, a.street, a.locality, a.city, a.state, a.pincode
      FROM orders o
      JOIN restaurants r ON o.restaurant_id = r.id
      JOIN addresses a ON o.address_id = a.id
      WHERE o.id = ? AND o.user_id = ?
    `, [id, req.userId]);

        if (orders.length === 0) {
            return res.status(404).json({ error: 'Order not found' });
        }

        const [orderItems] = await db.query(`
      SELECT oi.*, mi.name, mi.image_url
      FROM order_items oi
      JOIN menu_items mi ON oi.menu_item_id = mi.id
      WHERE oi.order_id = ?
    `, [id]);

        res.json({
            ...orders[0],
            items: orderItems
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    }
});

// Create new order
router.post('/', authMiddleware, async (req, res) => {
    const connection = await db.getConnection();

    try {
        await connection.beginTransaction();

        const { restaurantId, addressId, items, totalAmount } = req.body;

        // Create order
        const orderId = uuidv4();
        await connection.query(
            'INSERT INTO orders (id, user_id, restaurant_id, address_id, total_amount, status) VALUES (?, ?, ?, ?, ?, ?)',
            [orderId, req.userId, restaurantId, addressId, totalAmount, 'pending']
        );

        // Create order items
        for (const item of items) {
            const orderItemId = uuidv4();
            await connection.query(
                'INSERT INTO order_items (id, order_id, menu_item_id, quantity, price) VALUES (?, ?, ?, ?, ?)',
                [orderItemId, orderId, item.menuItemId, item.quantity, item.price]
            );
        }

        await connection.commit();

        const [newOrder] = await db.query('SELECT * FROM orders WHERE id = ?', [orderId]);
        res.status(201).json(newOrder[0]);
    } catch (error) {
        await connection.rollback();
        console.error(error);
        res.status(500).json({ error: 'Server error' });
    } finally {
        connection.release();
    }
});

module.exports = router;
