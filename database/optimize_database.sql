-- Database Optimization Script
-- Run this to add missing indexes and constraints for better performance

-- Add missing foreign key indexes (improves JOIN performance)
CREATE INDEX IF NOT EXISTS idx_quiz_options_question ON quiz_options(question_id);
CREATE INDEX IF NOT EXISTS idx_user_achievements_achievement ON user_achievements(achievement_id);
CREATE INDEX IF NOT EXISTS idx_user_challenge_attempts_challenge ON user_challenge_attempts(challenge_id);

-- Remove unused index (active_date is no longer used, day_offset is used instead)
DROP INDEX IF EXISTS idx_challenges_date;

-- Add index for day_offset (used in challenge rotation logic)
CREATE INDEX IF NOT EXISTS idx_challenges_day_offset ON challenges(day_offset);

-- Add composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_lessons_course_order ON lessons(course_id, lesson_order);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz_order ON quiz_questions(quiz_id, question_order);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_quiz ON quiz_attempts(user_id, quiz_id);
CREATE INDEX IF NOT EXISTS idx_user_lesson_user_completed ON user_lesson_progress(user_id, completed);

-- Add CHECK constraints for data integrity
ALTER TABLE users 
  DROP CONSTRAINT IF EXISTS check_xp_non_negative,
  ADD CONSTRAINT check_xp_non_negative CHECK (xp_points >= 0);

ALTER TABLE users 
  DROP CONSTRAINT IF EXISTS check_streak_non_negative,
  ADD CONSTRAINT check_streak_non_negative CHECK (streak_days >= 0);

ALTER TABLE users 
  DROP CONSTRAINT IF EXISTS check_max_streak_non_negative,
  ADD CONSTRAINT check_max_streak_non_negative CHECK (max_streak_days >= 0);

ALTER TABLE courses 
  DROP CONSTRAINT IF EXISTS check_total_lessons_non_negative,
  ADD CONSTRAINT check_total_lessons_non_negative CHECK (total_lessons >= 0);

ALTER TABLE lessons 
  DROP CONSTRAINT IF EXISTS check_xp_reward_positive,
  ADD CONSTRAINT check_xp_reward_positive CHECK (xp_reward > 0);

ALTER TABLE quizzes 
  DROP CONSTRAINT IF EXISTS check_passing_score_range,
  ADD CONSTRAINT check_passing_score_range CHECK (passing_score >= 0 AND passing_score <= 100);

ALTER TABLE quiz_attempts 
  DROP CONSTRAINT IF EXISTS check_score_range,
  ADD CONSTRAINT check_score_range CHECK (score >= 0 AND score <= 100);

ALTER TABLE challenges 
  DROP CONSTRAINT IF EXISTS check_day_offset_non_negative,
  ADD CONSTRAINT check_day_offset_non_negative CHECK (day_offset >= 0);

-- Analyze tables to update statistics for query planner
ANALYZE users;
ANALYZE courses;
ANALYZE lessons;
ANALYZE user_lesson_progress;
ANALYZE quizzes;
ANALYZE quiz_questions;
ANALYZE quiz_options;
ANALYZE quiz_attempts;
ANALYZE challenges;
ANALYZE user_challenge_attempts;
ANALYZE achievements;
ANALYZE user_achievements;

-- Show index usage statistics
SELECT 
    schemaname,
    relname as tablename,
    indexrelname as indexname,
    idx_scan as index_scans,
    idx_tup_read as tuples_read,
    idx_tup_fetch as tuples_fetched
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;

-- Show table sizes
SELECT 
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
