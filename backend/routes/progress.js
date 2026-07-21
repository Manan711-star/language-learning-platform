const express = require('express');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.get('/dashboard', authMiddleware, async (req, res) => {
  try {
    const userId = req.user.id;

    const userResult = await pool.query(
      'SELECT id, username, full_name, xp_points, streak_days, max_streak_days, target_language, avatar_url FROM users WHERE id = $1',
      [userId]
    );

    const lessonsCompleted = await pool.query(
      'SELECT COUNT(*) FROM user_lesson_progress WHERE user_id = $1 AND completed = TRUE',
      [userId]
    );

    const quizzesPassed = await pool.query(
      'SELECT COUNT(DISTINCT quiz_id) FROM quiz_attempts WHERE user_id = $1',
      [userId]
    );

    const challengesCompleted = await pool.query(
      'SELECT COUNT(*) FROM user_challenge_attempts WHERE user_id = $1 AND completed = TRUE',
      [userId]
    );

    const recentActivity = await pool.query(
      `(SELECT 'lesson' as type, l.title as name, ulp.completed_at as date, ulp.score
        FROM user_lesson_progress ulp JOIN lessons l ON l.id = ulp.lesson_id
        WHERE ulp.user_id = $1 AND ulp.completed = TRUE
        ORDER BY ulp.completed_at DESC LIMIT 3)
       UNION ALL
       (SELECT 'quiz' as type, q.title as name, qa.attempted_at as date, qa.score
        FROM quiz_attempts qa JOIN quizzes q ON q.id = qa.quiz_id
        WHERE qa.user_id = $1 ORDER BY qa.attempted_at DESC LIMIT 3)
       ORDER BY date DESC LIMIT 5`,
      [userId]
    );

    const courseProgress = await pool.query(
      `SELECT c.id, c.title, c.language, c.image_url, c.total_lessons,
              COUNT(ulp.id) FILTER (WHERE ulp.completed) as completed
       FROM courses c
       LEFT JOIN lessons l ON l.course_id = c.id
       LEFT JOIN user_lesson_progress ulp ON ulp.lesson_id = l.id AND ulp.user_id = $1
       WHERE c.is_active = TRUE
       GROUP BY c.id ORDER BY c.id LIMIT 4`,
      [userId]
    );

    const achievements = await pool.query(
      `SELECT a.*, ua.earned_at FROM achievements a
       LEFT JOIN user_achievements ua ON ua.achievement_id = a.id AND ua.user_id = $1
       ORDER BY a.xp_required`,
      [userId]
    );

    res.json({
      user: userResult.rows[0],
      stats: {
        lessons_completed: parseInt(lessonsCompleted.rows[0].count),
        quizzes_passed: parseInt(quizzesPassed.rows[0].count),
        challenges_completed: parseInt(challengesCompleted.rows[0].count)
      },
      recent_activity: recentActivity.rows,
      course_progress: courseProgress.rows.map(c => ({
        ...c,
        progress_percent: c.total_lessons > 0 ? Math.round((c.completed / c.total_lessons) * 100) : 0
      })),
      achievements: achievements.rows
    });
  } catch (err) {
    console.error('Dashboard error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

router.get('/leaderboard', async (req, res) => {
  try {
    const result = await pool.query(
      `SELECT username, full_name, xp_points, streak_days, max_streak_days, avatar_url
       FROM users ORDER BY xp_points DESC LIMIT 10`
    );
    res.json(result.rows);
  } catch (err) {
    console.error('Leaderboard error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

module.exports = router;
