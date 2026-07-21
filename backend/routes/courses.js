const express = require('express');
const pool = require('../config/db');
const { authMiddleware, optionalAuth } = require('../middleware/auth');

const router = express.Router();

router.get('/', optionalAuth, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM courses WHERE is_active = TRUE ORDER BY id'
    );

    if (req.user) {
      const progressResult = await pool.query(
        `SELECT c.id as course_id, COUNT(ulp.id) FILTER (WHERE ulp.completed) as completed_lessons
         FROM courses c
         LEFT JOIN lessons l ON l.course_id = c.id
         LEFT JOIN user_lesson_progress ulp ON ulp.lesson_id = l.id AND ulp.user_id = $1
         GROUP BY c.id`,
        [req.user.id]
      );
      const progressMap = {};
      progressResult.rows.forEach(r => { progressMap[r.course_id] = parseInt(r.completed_lessons) || 0; });

      const courses = result.rows.map(c => ({
        ...c,
        completed_lessons: progressMap[c.id] || 0,
        progress_percent: c.total_lessons > 0
          ? Math.round(((progressMap[c.id] || 0) / c.total_lessons) * 100)
          : 0
      }));
      return res.json(courses);
    }

    res.json(result.rows);
  } catch (err) {
    console.error('Courses error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

router.get('/:id', optionalAuth, async (req, res) => {
  try {
    const courseResult = await pool.query('SELECT * FROM courses WHERE id = $1', [req.params.id]);
    if (courseResult.rows.length === 0) {
      return res.status(404).json({ error: 'Course not found.' });
    }

    const lessonsResult = await pool.query(
      'SELECT id, course_id, title, lesson_order, xp_reward FROM lessons WHERE course_id = $1 ORDER BY lesson_order',
      [req.params.id]
    );

    const quizzesResult = await pool.query(
      'SELECT id, title, description, time_limit_seconds, passing_score, xp_reward FROM quizzes WHERE course_id = $1',
      [req.params.id]
    );

    let lessons = lessonsResult.rows;
    if (req.user) {
      const progressResult = await pool.query(
        'SELECT lesson_id, completed, score FROM user_lesson_progress WHERE user_id = $1',
        [req.user.id]
      );
      const progressMap = {};
      progressResult.rows.forEach(p => { progressMap[p.lesson_id] = p; });

      lessons = lessons.map(l => ({
        ...l,
        completed: progressMap[l.id]?.completed || false,
        score: progressMap[l.id]?.score || 0
      }));
    }

    res.json({
      course: courseResult.rows[0],
      lessons,
      quizzes: quizzesResult.rows
    });
  } catch (err) {
    console.error('Course detail error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

router.get('/:courseId/lessons/:lessonId', authMiddleware, async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT * FROM lessons WHERE id = $1 AND course_id = $2',
      [req.params.lessonId, req.params.courseId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Lesson not found.' });
    }

    const progress = await pool.query(
      'SELECT * FROM user_lesson_progress WHERE user_id = $1 AND lesson_id = $2',
      [req.user.id, req.params.lessonId]
    );

    res.json({
      lesson: result.rows[0],
      progress: progress.rows[0] || null
    });
  } catch (err) {
    console.error('Lesson error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

router.post('/:courseId/lessons/:lessonId/complete', authMiddleware, async (req, res) => {
  try {
    const lessonResult = await pool.query('SELECT * FROM lessons WHERE id = $1', [req.params.lessonId]);
    if (lessonResult.rows.length === 0) {
      return res.status(404).json({ error: 'Lesson not found.' });
    }

    const lesson = lessonResult.rows[0];
    const score = req.body.score || 100;

    await pool.query(
      `INSERT INTO user_lesson_progress (user_id, lesson_id, completed, score, completed_at)
       VALUES ($1, $2, TRUE, $3, CURRENT_TIMESTAMP)
       ON CONFLICT (user_id, lesson_id) DO UPDATE SET completed = TRUE, score = $3, completed_at = CURRENT_TIMESTAMP`,
      [req.user.id, req.params.lessonId, score]
    );

    await pool.query(
      'UPDATE users SET xp_points = xp_points + $1 WHERE id = $2',
      [lesson.xp_reward, req.user.id]
    );

    // Check achievements
    const completedCount = await pool.query(
      'SELECT COUNT(*) FROM user_lesson_progress WHERE user_id = $1 AND completed = TRUE',
      [req.user.id]
    );

    // First Steps: complete first lesson
    if (parseInt(completedCount.rows[0].count) === 1) {
      await pool.query(
        `INSERT INTO user_achievements (user_id, achievement_id)
         SELECT $1, id FROM achievements WHERE name = 'First Steps'
         ON CONFLICT DO NOTHING`,
        [req.user.id]
      );
    }

    // Polyglot: have lesson progress in 3 or more different courses
    const distinctCourses = await pool.query(
      `SELECT COUNT(DISTINCT l.course_id) as course_count
       FROM user_lesson_progress ulp
       JOIN lessons l ON l.id = ulp.lesson_id
       WHERE ulp.user_id = $1`,
      [req.user.id]
    );
    if (parseInt(distinctCourses.rows[0].course_count) >= 3) {
      await pool.query(
        `INSERT INTO user_achievements (user_id, achievement_id)
         SELECT $1, id FROM achievements WHERE name = 'Polyglot'
         ON CONFLICT DO NOTHING`,
        [req.user.id]
      );
    }

    // XP Hunter: total XP >= 500
    const userResult = await pool.query('SELECT xp_points, streak_days FROM users WHERE id = $1', [req.user.id]);
    if (userResult.rows[0].xp_points >= 500) {
      await pool.query(
        `INSERT INTO user_achievements (user_id, achievement_id)
         SELECT $1, id FROM achievements WHERE name = 'XP Hunter'
         ON CONFLICT DO NOTHING`,
        [req.user.id]
      );
    }

    res.json({
      message: 'Lesson completed!',
      xp_earned: lesson.xp_reward,
      total_xp: userResult.rows[0].xp_points
    });
  } catch (err) {
    console.error('Complete lesson error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

module.exports = router;
