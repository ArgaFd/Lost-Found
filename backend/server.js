const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

// In-memory storage
let users = [];
let items = [];

// Root Route
app.get('/', (req, res) => {
    res.send('Lost & Found API is running!');
});

// Helper to generate ID
const generateId = () => Math.random().toString(36).substr(2, 9);

// AUTH ROUTES
app.post('/auth/register', (req, res) => {
    const { name, email, password } = req.body;
    if (users.find(u => u.email === email)) {
        return res.status(400).json({ message: 'Email already registered' });
    }
    const newUser = { id: generateId(), name, email, password };
    users.push(newUser);
    console.log('User Registered:', newUser);
    res.status(201).json({ success: true, user: newUser });
});

app.post('/auth/login', (req, res) => {
    const { email, password } = req.body;
    const user = users.find(u => u.email === email && u.password === password);
    if (!user) {
        return res.status(401).json({ message: 'Invalid credentials' });
    }
    console.log('User Logged In:', user);
    res.json({ success: true, id: user.id, name: user.name });
});

// ITEMS ROUTES
app.get('/items', (req, res) => {
    // Optional: filter by category or user via query params if needed
    res.json(items);
});

app.post('/items', (req, res) => {
    const { name, description, location, category, whatsapp, imageUrl, userId } = req.body;
    const newItem = {
        id: generateId(),
        name,
        description,
        location,
        category,
        whatsapp,
        imageUrl,
        userId,
        status: 'Active'
    };
    items.push(newItem);
    console.log('Item Created:', newItem);
    res.status(201).json(newItem);
});

app.put('/items/:id', (req, res) => {
    const { id } = req.params;
    const index = items.findIndex(i => i.id === id);
    if (index !== -1) {
        items[index] = { ...items[index], ...req.body };
        console.log('Item Updated:', items[index]);
        res.json(items[index]);
    } else {
        res.status(404).json({ message: 'Item not found' });
    }
});

app.delete('/items/:id', (req, res) => {
    const { id } = req.params;
    const initialLength = items.length;
    items = items.filter(i => i.id !== id);
    if (items.length < initialLength) {
        console.log('Item Deleted:', id);
        res.json({ success: true });
    } else {
        res.status(404).json({ message: 'Item not found' });
    }
});

// Start Server
app.listen(PORT, () => {
    console.log(`Server running on http://localhost:${PORT}`);
    console.log(`For Android Emulator, use http://10.0.2.2:${PORT}`);
});
