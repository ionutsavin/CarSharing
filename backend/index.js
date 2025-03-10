const express = require('express');
const cors = require('cors');
const bcrypt = require('bcryptjs');
const { Pool } = require('pg');
const dotenv = require('dotenv');
const app = express();
const port = 3000;


app.use(express.json());
app.use(cors({
    origin: 'http://localhost:63520',
}));
dotenv.config();

const pool = new Pool({
    user: process.env.DB_USER,
    host: process.env.DB_HOST,
    database: process.env.DB_NAME,
    password: process.env.DB_PASS,
    port: process.env.DB_PORT
});

app.post('/register', async (req, res) => {
    const { username, password, repeatPassword, hasDrivingLicense } = req.body;

    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password are required' });
    }
    if (password !== repeatPassword) {
        return res.status(400).json({ error: 'Passwords do not match' });
    }
    try {
        const existingUser = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
        if (existingUser.rows.length > 0) {
            return res.status(400).json({ error: 'Username already exists' });
        }
    } catch (error) {
        console.error('Error checking for existing user:', error);
        return res.status(500).json({ error: 'An unexpected error occurred while checking for existing user' });
    }

    const hashedPassword = bcrypt.hashSync(password, 10);
    try {
        await pool.query('INSERT INTO users (username, password, driving_license) VALUES ($1, $2, $3)', 
            [username, hashedPassword, hasDrivingLicense]);

        res.status(200).json({ message: 'Registration successful' });
    } catch (error) {
        console.error('Error inserting user into database:', error);
        res.status(500).json({ error: 'An unexpected error occurred during registration' });
    }
});

const jwt = require('jsonwebtoken');

app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    console.log(req.body);

    if (!username || !password) {
        return res.status(400).json({ error: 'Username and password are required' });
    }

    try {
        const userResult = await pool.query('SELECT * FROM users WHERE username = $1', [username]);
        if (userResult.rows.length === 0) {
            return res.status(400).json({ error: 'User not found' });
        }
        const user = userResult.rows[0];
        const isPasswordValid = bcrypt.compareSync(password, user.password);
        if (!isPasswordValid) {
            return res.status(400).json({ error: 'Incorrect password' });
        }
        const token = jwt.sign(
            { userId: user.id, username: user.username }, 
            process.env.JWT_SECRET, 
            { expiresIn: process.env.JWT_EXPIRATION }
        );
        res.status(200).json({ message: 'Login successful', token });
    } catch (error) {
        console.error('Error during login:', error);
        return res.status(500).json({ error: 'An unexpected error occurred during login' });
    }
});

app.get('/cars/:location', async (req, res) => {
    const { location } = req.params;
    try {
        const result = await pool.query(
            'SELECT brand, full_name, vin FROM cars WHERE location = $1 AND status = $2',
            [location, 'available']
        );
        res.status(200).json(result.rows);
    } catch (error) {
        console.error('Error fetching cars:', error);
        res.status(500).json({ error: 'An unexpected error occurred' });
    }
});

app.post('/reserve/:location/:vin', async (req, res) => {
    const { vin, location } = req.params;
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) {
        return res.status(400).json({ error: 'Authorization token is required' });
    }
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        const username = decoded.username;
        console.log(`Reservation request for ${vin} by ${username}`);

        const userResult = await pool.query('SELECT driving_license FROM users WHERE username = $1', [username]);
        if (!userResult.rows[0].driving_license) {
            return res.status(400).json({ error: 'User does not have a valid driving license' });
        }
        const updateResult = await pool.query(
            `UPDATE cars 
            SET status = $1 
            WHERE vin = $2 AND location = $3 AND status = $4 
            RETURNING *`,
            ['reserved', vin, location, 'available']
        );
        if (updateResult.rowCount === 0) {
            return res.status(400).json({ error: 'Car is no longer available' });
        }
        const reservedCar = updateResult.rows[0];
        console.log(`${username} has reserved ${reservedCar.full_name}`);

        res.status(200).json({
            message: 'Car reserved successfully',
            car: reservedCar
        });
    } catch (error) {
        console.error('Error reserving car:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

app.post('/cancel-reservation/:vin', async (req, res) => {
    const { vin } = req.params;
    try {
        const updateResult = await pool.query(
            `UPDATE cars 
            SET status = $1 
            WHERE vin = $2 AND status = $3
            RETURNING *`,
            ['available', vin, 'reserved']
        );

        if (updateResult.rowCount === 0) {
            return res.status(400).json({ error: 'Car is not reserved or doesn\'t exist' });
        }
        console.log(`Reservation canceled for car VIN: ${vin}`);
        res.status(200).json({ message: 'Reservation canceled', car: updateResult.rows[0] });
    } catch (error) {
        console.error('Error canceling reservation:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

app.listen(port, () => {
    console.log(`Server listening at http://localhost:${port}`);
});
