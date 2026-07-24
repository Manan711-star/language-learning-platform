const express = require('express');
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const crypto = require('crypto');
const fs = require('fs');
const path = require('path');
const nodemailer = require('nodemailer');
const pool = require('../config/db');
const { authMiddleware, JWT_SECRET } = require('../middleware/auth');
const upload = require('../middleware/upload');

// ---------------------------------------------------------------------------
// Nodemailer transporter — reads SMTP config from environment variables.
// Supports any SMTP provider (Gmail, Outlook, Mailgun, etc.).
// Returns null if SMTP env vars are not configured.
// ---------------------------------------------------------------------------
function createTransporter() {
  if (!process.env.SMTP_HOST || !process.env.SMTP_USER || !process.env.SMTP_PASS) {
    return null;
  }
  return nodemailer.createTransport({
    host: process.env.SMTP_HOST,
    port: parseInt(process.env.SMTP_PORT || '587'),
    secure: process.env.SMTP_SECURE === 'true',   // true for port 465
    auth: {
      user: process.env.SMTP_USER,
      pass: process.env.SMTP_PASS,
    },
  });
}

// ---------------------------------------------------------------------------
// Password policy: min 8 chars, 1 uppercase, 1 number, 1 special character.
// Used in register and reset-password routes.
// ---------------------------------------------------------------------------
function validatePassword(password) {
  if (!password || password.length < 8) {
    return 'Password must be at least 8 characters.';
  }
  if (!/[A-Z]/.test(password)) {
    return 'Password must contain at least one uppercase letter.';
  }
  if (!/[0-9]/.test(password)) {
    return 'Password must contain at least one number.';
  }
  if (!/[^A-Za-z0-9]/.test(password)) {
    return 'Password must contain at least one special character (e.g. @, #, $, !).';
  }
  return null; // valid
}

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

    const pwError = validatePassword(password);
    if (pwError) return res.status(400).json({ error: pwError });

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

// ---------------------------------------------------------------------------
// POST /api/auth/forgot-password
//
// Flow:
//   1. Look up the user by email.
//   2. Generate a cryptographically random token.
//   3. Store a bcrypt hash of the token in the DB (never store raw tokens).
//   4. Set a 1-hour expiry.
//   5. Email the raw token as a link to the user.
//
// Always returns 200 — even if the email is not found — to prevent user
// enumeration attacks (an attacker shouldn't be able to tell which emails
// are registered).
// ---------------------------------------------------------------------------
router.post('/forgot-password', async (req, res) => {
  try {
    const email = req.body.email || req.query.email;

    if (!email) {
      return res.status(400).json({ error: 'Email is required.' });
    }

    const result = await pool.query('SELECT id, full_name FROM users WHERE email = $1', [email]);

    // Always respond with success to prevent email enumeration
    if (result.rows.length === 0) {
      return res.json({ message: 'If that email exists, a reset link has been sent.' });
    }

    const user = result.rows[0];

    // Generate a secure random 32-byte token
    const rawToken = crypto.randomBytes(32).toString('hex');

    // Hash it before storing — so a DB leak doesn't expose usable tokens
    const tokenHash = await bcrypt.hash(rawToken, 10);
    const expiresAt = new Date(Date.now() + 60 * 60 * 1000); // 1 hour from now

    await pool.query(
      'UPDATE users SET password_reset_token = $1, password_reset_expires = $2 WHERE id = $3',
      [tokenHash, expiresAt, user.id]
    );

    // Build the reset link — uses APP_URL env var (falls back to localhost)
    const appUrl = process.env.APP_URL || 'http://localhost:3000';
    const resetLink = `${appUrl}/reset-password.html?token=${rawToken}&email=${encodeURIComponent(email)}`;

    // Send the email
    const transporter = createTransporter();
    if (!transporter) {
      console.error('Forgot password: SMTP not configured. Set SMTP_HOST, SMTP_USER, SMTP_PASS env vars.');
      return res.status(500).json({ error: 'Email service is not configured. Please contact support.' });
    }
    await transporter.sendMail({
      from: `"LinguaVerse" <${process.env.SMTP_USER}>`,
      to: email,
      subject: 'Reset your LinguaVerse password',
      html: `
        <div style="font-family: 'Segoe UI', sans-serif; max-width: 480px; margin: auto; padding: 32px; background: #f8fafc; border-radius: 16px;">
          <h2 style="color: #1e1b4b; margin-bottom: 8px;">Password Reset Request</h2>
          <p style="color: #4b5563;">Hi ${user.full_name || 'there'},</p>
          <p style="color: #4b5563;">We received a request to reset your password. Click the button below to choose a new one. This link expires in <strong>1 hour</strong>.</p>
          <div style="text-align: center; margin: 32px 0;">
            <a href="${resetLink}"
               style="background: linear-gradient(135deg, #6366f1, #8b5cf6); color: white; padding: 14px 32px;
                      border-radius: 10px; text-decoration: none; font-weight: 600; font-size: 16px;">
              Reset Password
            </a>
          </div>
          <p style="color: #6b7280; font-size: 13px;">Or copy this link into your browser:<br>
            <a href="${resetLink}" style="color: #6366f1; word-break: break-all;">${resetLink}</a>
          </p>
          <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;">
          <p style="color: #9ca3af; font-size: 12px;">If you didn't request this, you can safely ignore this email. Your password won't change.</p>
        </div>
      `,
    });

    res.json({ message: 'If that email exists, a reset link has been sent.' });
  } catch (err) {
    console.error('Forgot password error:', err);
    res.status(500).json({ error: 'Server error. Please try again.' });
  }
});

// ---------------------------------------------------------------------------
// POST /api/auth/reset-password
//
// Flow:
//   1. Find the user by email.
//   2. Check that a reset token exists and hasn't expired.
//   3. Compare the raw token from the request against the stored hash.
//   4. Hash the new password and update the user.
//   5. Clear the reset token fields so the link can't be reused.
// ---------------------------------------------------------------------------
router.post('/reset-password', async (req, res) => {
  try {
    const email    = req.body.email    || req.query.email;
    const token    = req.body.token    || req.query.token;
    const password = req.body.password || req.query.password;

    if (!email || !token || !password) {
      return res.status(400).json({ error: 'Email, token, and new password are required.' });
    }

    const pwError = validatePassword(password);
    if (pwError) return res.status(400).json({ error: pwError });

    const result = await pool.query(
      'SELECT id, password_reset_token, password_reset_expires FROM users WHERE email = $1',
      [email]
    );

    if (result.rows.length === 0) {
      return res.status(400).json({ error: 'Invalid or expired reset link.' });
    }

    const user = result.rows[0];

    // Check the token exists and hasn't expired
    if (!user.password_reset_token || !user.password_reset_expires) {
      return res.status(400).json({ error: 'Invalid or expired reset link.' });
    }

    if (new Date() > new Date(user.password_reset_expires)) {
      return res.status(400).json({ error: 'Reset link has expired. Please request a new one.' });
    }

    // Verify the raw token against the stored hash
    const tokenValid = await bcrypt.compare(token, user.password_reset_token);
    if (!tokenValid) {
      return res.status(400).json({ error: 'Invalid or expired reset link.' });
    }

    // Hash the new password and clear the reset token in one update
    const password_hash = await bcrypt.hash(password, 10);
    await pool.query(
      `UPDATE users
       SET password_hash = $1, password_reset_token = NULL, password_reset_expires = NULL
       WHERE id = $2`,
      [password_hash, user.id]
    );

    res.json({ message: 'Password reset successful! You can now log in with your new password.' });
  } catch (err) {
    console.error('Reset password error:', err);
    res.status(500).json({ error: 'Server error. Please try again.' });
  }
});

module.exports = router;
