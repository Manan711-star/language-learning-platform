const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const fs = require('fs');
const path = require('path');
const pool = require('../config/db');
const { authMiddleware, JWT_SECRET } = require('../middleware/auth');
const upload = require('../middleware/upload');

const router = express.Router();

router.post('/register', async (req, res) => {
  try {
    const username = req.body.username || req.query.username;
    const email = req.body.email || req.query.email;
    const password = req.body.password || req.query.password;
    const full_name = req.body.full_name || req.query.full_name;
    const target_language = req.body.target_language || req.query.target_language;

    if (!username || !email || !password) {
      return res.status(400).json({ error: 'Username, email, and password are required.' });
    }

    if (password.length < 6) {
      return res.status(400).json({ error: 'Password must be at least 6 characters.' });
    }

    const existing = await pool.query(
      'SELECT id FROM users WHERE email = $1 OR username = $2',
      [email, username]
    );
    if (existing.rows.length > 0) {
      return res.status(409).json({ error: 'Email or username already exists.' });
    }

    const password_hash = await bcrypt.hash(password, 10);
    const result = await pool.query(
      `INSERT INTO users (username, email, password_hash, full_name, target_language, last_login)
       VALUES ($1, $2, $3, $4, $5, CURRENT_DATE) RETURNING id, username, email, full_name, target_language, xp_points, streak_days, avatar_url`,
      [username, email, password_hash, full_name || username, target_language || 'Spanish']
    );

    const user = result.rows[0];
    const token = jwt.sign({ id: user.id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });

    res.status(201).json({ message: 'Registration successful!', token, user });
  } catch (err) {
    console.error('Register error:', err);
    res.status(500).json({ error: 'Server error during registration.' });
  }
});

router.post('/login', async (req, res) => {
  try {
    const email = req.body.email || req.query.email;
    const password = req.body.password || req.query.password;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required.' });
    }

    const result = await pool.query(
      'SELECT * FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    const user = result.rows[0];
    const valid = await bcrypt.compare(password, user.password_hash);
    if (!valid) {
      return res.status(401).json({ error: 'Invalid email or password.' });
    }

    // Only record the login date — streak is earned by completing a daily challenge, not by logging in
    await pool.query(
      'UPDATE users SET last_login = CURRENT_DATE WHERE id = $1',
      [user.id]
    );

    const token = jwt.sign({ id: user.id, username: user.username }, JWT_SECRET, { expiresIn: '7d' });

    const { password_hash, ...safeUser } = user;

    res.json({ message: 'Login successful!', token, user: safeUser });
  } catch (err) {
    console.error('Login error:', err);
    res.status(500).json({ error: 'Server error during login.' });
  }
});

router.get('/profile', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT id, username, email, full_name, avatar_url, native_language, target_language,
              xp_points, streak_days, max_streak_days, last_login, created_at
       FROM users WHERE id = $1`,
      [req.user.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'User not found.' });
    }

    res.json(result.rows[0]);
  } catch (err) {
    console.error('Profile error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

router.put('/profile', authMiddleware, async (req, res) => {
  try {
    const full_name = req.body.full_name || req.query.full_name;
    const target_language = req.body.target_language || req.query.target_language;
    const native_language = req.body.native_language || req.query.native_language;
    const result = await pool.query(
      `UPDATE users SET full_name = COALESCE($1, full_name),
              target_language = COALESCE($2, target_language),
              native_language = COALESCE($3, native_language)
       WHERE id = $4
       RETURNING id, username, email, full_name, avatar_url, native_language,
                 target_language, xp_points, streak_days, max_streak_days`,
      [full_name, target_language, native_language, req.user.id]
    );
    res.json(result.rows[0]);
  } catch (err) {
    console.error('Update profile error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

function deleteAvatarFile(avatarUrl) {
  if (!avatarUrl || !avatarUrl.startsWith('uploads/avatars/')) return;
  const filePath = path.join(__dirname, '..', '..', 'frontend', avatarUrl);
  if (fs.existsSync(filePath)) fs.unlinkSync(filePath);
}

router.post('/profile/avatar', authMiddleware, (req, res, next) => {
  upload.single('avatar')(req, res, (err) => {
    if (err) {
      if (err.code === 'LIMIT_FILE_SIZE') {
        return res.status(400).json({ error: 'Image must be smaller than 2MB.' });
      }
      return res.status(400).json({ error: err.message });
    }
    next();
  });
}, async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({ error: 'No image file provided.' });
    }

    const avatarUrl = `uploads/avatars/${req.file.filename}`;

    const oldResult = await pool.query(
      'SELECT avatar_url FROM users WHERE id = $1',
      [req.user.id]
    );
    const oldAvatar = oldResult.rows[0]?.avatar_url;

    const result = await pool.query(
      `UPDATE users SET avatar_url = $1 WHERE id = $2
       RETURNING id, username, email, full_name, avatar_url, native_language,
                 target_language, xp_points, streak_days, max_streak_days`,
      [avatarUrl, req.user.id]
    );

    deleteAvatarFile(oldAvatar);

    res.json(result.rows[0]);
  } catch (err) {
    if (req.file) fs.unlinkSync(req.file.path);
    console.error('Avatar upload error:', err);
    res.status(500).json({ error: 'Server error during avatar upload.' });
  }
});

module.exports = router;
