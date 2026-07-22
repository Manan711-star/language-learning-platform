const express = require('express');
const pool = require('../config/db');
const { authMiddleware } = require('../middleware/auth');

const router = express.Router();

router.get('/:id', authMiddleware, async (req, res) => {
  try {
    const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [req.params.id]);
    if (quizResult.rows.length === 0) {
      return res.status(404).json({ error: 'Quiz not found.' });
    }

    const questionsResult = await pool.query(
      'SELECT id, question_text, question_type, question_order FROM quiz_questions WHERE quiz_id = $1 ORDER BY question_order',
      [req.params.id]
    );

    const questions = [];
    for (const q of questionsResult.rows) {
      const optionsResult = await pool.query(
        'SELECT id, option_text FROM quiz_options WHERE question_id = $1',
        [q.id]
      );
      questions.push({ ...q, options: optionsResult.rows });
    }

    const attemptsResult = await pool.query(
      'SELECT score, total_questions, passed, attempted_at FROM quiz_attempts WHERE user_id = $1 AND quiz_id = $2 ORDER BY attempted_at DESC LIMIT 5',
      [req.user.id, req.params.id]
    );

    res.json({
      quiz: quizResult.rows[0],
      questions,
      previous_attempts: attemptsResult.rows
    });
  } catch (err) {
    console.error('Quiz error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

router.post('/:id/submit', authMiddleware, async (req, res) => {
  try {
    const { answers, time_taken } = req.body;
    const quizId = req.params.id;

    const quizResult = await pool.query('SELECT * FROM quizzes WHERE id = $1', [quizId]);
    if (quizResult.rows.length === 0) {
      return res.status(404).json({ error: 'Quiz not found.' });
    }
    const quiz = quizResult.rows[0];

    const questionsResult = await pool.query(
      'SELECT qq.id, qq.question_text FROM quiz_questions qq WHERE qq.quiz_id = $1',
      [quizId]
    );

    let correct = 0;
    const total = questionsResult.rows.length;
    const results = [];

    for (const q of questionsResult.rows) {
      const optionsResult = await pool.query(
        'SELECT id, option_text, is_correct FROM quiz_options WHERE question_id = $1',
        [q.id]
      );
      const userAnswer = answers[q.id];
      const correctOption = optionsResult.rows.find(o => o.is_correct);
      const isCorrect = userAnswer === correctOption?.id;
      if (isCorrect) correct++;

      results.push({
        question_id: q.id,
        question_text: q.question_text,
        user_answer: userAnswer,
        correct_answer: correctOption?.id,
        is_correct: isCorrect,
        options: optionsResult.rows
      });
    }

    const score = Math.round((correct / total) * 100);
    const passed = score >= quiz.passing_score;

    await pool.query(
      `INSERT INTO quiz_attempts (user_id, quiz_id, score, total_questions, passed, time_taken_seconds)
       VALUES ($1, $2, $3, $4, $5, $6)`,
      [req.user.id, quizId, score, total, passed, time_taken || 0]
    );

    if (passed) {
      // Only award XP on the first pass ever
      const alreadyPassed = await pool.query(
        'SELECT id FROM quiz_attempts WHERE user_id = $1 AND quiz_id = $2 AND passed = true',
        [req.user.id, quizId]
      );

      if (alreadyPassed.rows.length === 0) {
        await pool.query(
          'UPDATE users SET xp_points = xp_points + $1 WHERE id = $2',
          [quiz.xp_reward, req.user.id]
        );

        // Quiz Master: pass first quiz
        await pool.query(
          `INSERT INTO user_achievements (user_id, achievement_id)
           SELECT $1, id FROM achievements WHERE name = 'Quiz Master'
           ON CONFLICT DO NOTHING`,
          [req.user.id]
        );

        // XP Hunter: total XP >= 500
        const xpCheck = await pool.query('SELECT xp_points FROM users WHERE id = $1', [req.user.id]);
        if (xpCheck.rows[0].xp_points >= 500) {
          await pool.query(
            `INSERT INTO user_achievements (user_id, achievement_id)
             SELECT $1, id FROM achievements WHERE name = 'XP Hunter'
             ON CONFLICT DO NOTHING`,
            [req.user.id]
          );
        }
      }
    }

    const userResult = await pool.query('SELECT xp_points FROM users WHERE id = $1', [req.user.id]);

    res.json({
      score,
      correct,
      total,
      passed,
      xp_earned: passed ? quiz.xp_reward : 0,
      total_xp: userResult.rows[0].xp_points,
      results
    });
  } catch (err) {
    console.error('Submit quiz error:', err);
    res.status(500).json({ error: 'Server error.' });
  }
});

module.exports = router;
