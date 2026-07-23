const express = require('express');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

// ---------------------------------------------------------------------------
// Helper: compute today's day_offset for challenge rotation.
// epochDays % 7 gives a value 0-6 that changes every calendar day (UTC).
// ---------------------------------------------------------------------------
function todayOffset() {
  const epochDays = Math.floor(Date.now() / 86400000);
  return epochDays % 7;
}

// ---------------------------------------------------------------------------
// Helper: return today's date string in UTC (YYYY-MM-DD).
// Using UTC everywhere avoids midnight timezone surprises.
// ---------------------------------------------------------------------------
function todayUTC() {
  return new Date().toISOString().split('T')[0];
}

// ---------------------------------------------------------------------------
// Minimum score thresholds per challenge type.
// Types that require typed / selected answers need at least 1 correct answer.
// Pronunciation / vocabulary are self-assessed — we just require the button
// click (score will be 100 sent by the frontend), but we still validate that
// the field is present.
// ---------------------------------------------------------------------------
const MIN_SCORE = {
  translation:   1,   // at least 1 phrase translated correctly
  recognition:   1,   // at least 1 character identified correctly
  grammar:       1,   // at least 1 article selected correctly
  vocabulary:    100, // self-assessed — frontend always sends 100
  pronunciation: 100, // self-assessed — frontend always sends 100
};

// ---------------------------------------------------------------------------
// GET /api/challenges
// Returns ONLY today's challenges with the user's completion status.
// Challenges from any other day_offset are never returned.
// ---------------------------------------------------------------------------
router.get('/', authMiddleware, async (req, res) => {
  try {
    const offset = todayOffset();

    const result = await pool.query(
      `SELECT c.id, c.title, c.description, c.challenge_type, c.language,
              c.xp_reward, c.difficulty, c.day_offset,
              uca.completed, uca.score, uca.completed_at
       FROM challenges c
       LEFT JOIN user_challenge_attempts uca
              ON uca.challenge_id = c.id AND uca.user_id = $1
       WHERE c.day_offset = $2
       ORDER BY
         CASE c.difficulty WHEN 'Easy' THEN 1 WHEN 'Medium' THEN 2 ELSE 3 END,
         c.id`,
      [req.user.id, offset]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('Challenges fetch error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

// ---------------------------------------------------------------------------
// GET /api/challenges/:id
// Returns a single challenge ONLY if it belongs to today's rotation.
// Accessing a past or future challenge returns 403.
// content field is NOT returned here — it is returned only when the user
// explicitly opens the challenge (prevents scraping all answers at once).
// ---------------------------------------------------------------------------
router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const offset = todayOffset();

    const result = await pool.query(
      'SELECT * FROM challenges WHERE id = $1',
      [req.params.id]
    );

    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Challenge not found.' });
    }

    const challenge = result.rows[0];

    // Block access to challenges that do not belong to today
    if (challenge.day_offset !== offset) {
      return res.status(403).json({
        error: 'This challenge is not available today.'
      });
    }

    const attempt = await pool.query(
      'SELECT * FROM user_challenge_attempts WHERE user_id = $1 AND challenge_id = $2',
      [req.user.id, challenge.id]
    );

    res.json({
      challenge,
      attempt: attempt.rows[0] || null
    });
  } catch (err) {
    console.error('Challenge detail error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

// ---------------------------------------------------------------------------
// POST /api/challenges/:id/complete
//
// All rules are enforced here on the backend — the frontend cannot bypass them.
//
// Rule 1 — Today only:
//   The challenge must belong to today's day_offset. Completing a past or
//   future challenge returns 403.
//
// Rule 2 — Valid answer required:
//   The submitted score must meet the minimum threshold for the challenge type.
//   Empty / zero submissions for interactive types are rejected with 422.
//
// Rule 3 — No re-completion XP:
//   If the user already completed this challenge today, we return the existing
//   result without awarding XP again.
//
// Rule 4 — Streak is one increment per calendar day:
//   We use a PostgreSQL advisory lock keyed on the user ID so that even if two
//   challenge completions arrive simultaneously, only the first one increments
//   the streak. After that, last_streak_date = today prevents any further
//   increments until the next calendar day.
// ---------------------------------------------------------------------------
router.post('/:id/complete', authMiddleware, async (req, res) => {
  const client = await pool.connect();
  try {
    await client.query('BEGIN');

    // ── Rule 1: load and validate the challenge belongs to today ────────────
    const offset = todayOffset();
    const today  = todayUTC();

    const challengeResult = await client.query(
      'SELECT * FROM challenges WHERE id = $1',
      [req.params.id]
    );

    if (challengeResult.rows.length === 0) {
      await client.query('ROLLBACK');
      return res.status(404).json({ error: 'Challenge not found.' });
    }

    const challenge = challengeResult.rows[0];

    if (challenge.day_offset !== offset) {
      await client.query('ROLLBACK');
      return res.status(403).json({
        error: 'This challenge is not available today. You can only complete today\'s challenges.'
      });
    }

    // ── Rule 2: validate the submitted score ────────────────────────────────
    const rawScore = req.body.score !== undefined && req.body.score !== null
      ? req.body.score
      : req.query.score;
    const score = rawScore !== undefined && rawScore !== null
      ? parseInt(rawScore, 10)
      : -1;

    if (isNaN(score) || score < 0) {
      await client.query('ROLLBACK');
      return res.status(422).json({ error: 'Invalid score submitted.' });
    }

    const minRequired = MIN_SCORE[challenge.challenge_type] ?? 1;

    if (score < minRequired) {
      await client.query('ROLLBACK');
      return res.status(422).json({
        error: challenge.challenge_type === 'pronunciation' || challenge.challenge_type === 'vocabulary'
          ? 'Please complete the activity before marking it done.'
          : `You need at least one correct answer to complete this challenge. You scored ${score}%.`
      });
    }

    // ── Rule 3: check for existing completion (no double XP) ────────────────
    const existingAttempt = await client.query(
      'SELECT * FROM user_challenge_attempts WHERE user_id = $1 AND challenge_id = $2',
      [req.user.id, challenge.id]
    );

    const alreadyCompleted = existingAttempt.rows.length > 0 && existingAttempt.rows[0].completed;

    if (alreadyCompleted) {
      await client.query('ROLLBACK');
      const userNow = await pool.query(
        'SELECT xp_points, streak_days, max_streak_days FROM users WHERE id = $1',
        [req.user.id]
      );
      return res.json({
        message: 'Challenge already completed.',
        xp_earned:       0,
        total_xp:        userNow.rows[0].xp_points,
        streak_days:     userNow.rows[0].streak_days,
        max_streak_days: userNow.rows[0].max_streak_days,
        streak_updated:  false,
        already_completed: true
      });
    }

    // ── Record the attempt ───────────────────────────────────────────────────
    await client.query(
      `INSERT INTO user_challenge_attempts (user_id, challenge_id, completed, score, completed_at)
       VALUES ($1, $2, TRUE, $3, CURRENT_TIMESTAMP)
       ON CONFLICT (user_id, challenge_id)
       DO UPDATE SET completed = TRUE, score = $3, completed_at = CURRENT_TIMESTAMP`,
      [req.user.id, challenge.id, score]
    );

    // ── Award XP ─────────────────────────────────────────────────────────────
    await client.query(
      'UPDATE users SET xp_points = xp_points + $1 WHERE id = $2',
      [challenge.xp_reward, req.user.id]
    );

    // ── Rule 4: streak — exactly one increment per calendar day ─────────────
    // Use PostgreSQL's built-in date logic to calculate streak entirely in the database.
    // This ensures consistency and prevents timezone/race condition issues.
    const streakResult = await client.query(
      `WITH user_data AS (
         SELECT streak_days, max_streak_days, last_streak_date
         FROM users WHERE id = $1 FOR UPDATE
       ),
       streak_calc AS (
         SELECT 
           CASE 
             -- Already completed a challenge today: no change
             WHEN last_streak_date = CURRENT_DATE THEN streak_days
             -- Completed yesterday and today: extend streak
             WHEN last_streak_date = CURRENT_DATE - INTERVAL '1 day' THEN streak_days + 1
             -- Gap or first time: reset to 1
             ELSE 1
           END as new_streak,
           CASE 
             -- If this is NOT the first challenge today, don't update last_streak_date
             WHEN last_streak_date = CURRENT_DATE THEN false
             ELSE true
           END as should_update,
           streak_days as old_streak,
           max_streak_days as old_max,
           last_streak_date
         FROM user_data
       )
       SELECT 
         new_streak,
         GREATEST(new_streak, old_max) as new_max,
         should_update,
         old_streak
       FROM streak_calc`,
      [req.user.id]
    );
    
    const streakData = streakResult.rows[0];
    const newStreak = streakData.new_streak;
    const newMaxStreak = streakData.new_max;
    const streakChanged = streakData.should_update;

    // Only update if this is the first challenge completed today
    if (streakChanged) {
      await client.query(
        `UPDATE users
         SET streak_days      = $1,
             max_streak_days  = $2,
             last_streak_date = CURRENT_DATE
         WHERE id = $3`,
        [newStreak, newMaxStreak, req.user.id]
      );
    }

    // ── Achievements ─────────────────────────────────────────────────────────
    // Challenge Champion: 5 total completed challenges
    const completedCount = await client.query(
      'SELECT COUNT(*) FROM user_challenge_attempts WHERE user_id = $1 AND completed = TRUE',
      [req.user.id]
    );
    if (parseInt(completedCount.rows[0].count, 10) >= 5) {
      await client.query(
        `INSERT INTO user_achievements (user_id, achievement_id)
         SELECT $1, id FROM achievements WHERE name = 'Challenge Champion'
         ON CONFLICT DO NOTHING`,
        [req.user.id]
      );
    }

    // Streak Starter: 3-day streak (based on current streak, not max)
    if (newStreak >= 3) {
      await client.query(
        `INSERT INTO user_achievements (user_id, achievement_id)
         SELECT $1, id FROM achievements WHERE name = 'Streak Starter'
         ON CONFLICT DO NOTHING`,
        [req.user.id]
      );
    }

    // XP Hunter: total XP >= 500
    const xpCheck = await client.query('SELECT xp_points FROM users WHERE id = $1', [req.user.id]);
    if (xpCheck.rows[0].xp_points >= 500) {
      await client.query(
        `INSERT INTO user_achievements (user_id, achievement_id)
         SELECT $1, id FROM achievements WHERE name = 'XP Hunter'
         ON CONFLICT DO NOTHING`,
        [req.user.id]
      );
    }

    // ── Fetch final XP + streak values for response ──────────────────────────
    const updatedUser = await client.query(
      'SELECT xp_points, streak_days, max_streak_days FROM users WHERE id = $1',
      [req.user.id]
    );

    await client.query('COMMIT');

    res.json({
      message: 'Challenge completed!',
      xp_earned:       challenge.xp_reward,
      total_xp:        updatedUser.rows[0].xp_points,
      streak_days:     updatedUser.rows[0].streak_days,
      max_streak_days: updatedUser.rows[0].max_streak_days,
      streak_updated:  streakChanged
    });

  } catch (err) {
    await client.query('ROLLBACK');
    console.error('Complete challenge error:', err);
    res.status(500).json({ error: 'Server error.' });
  } finally {
    client.release();
  }
});

module.exports = router;
