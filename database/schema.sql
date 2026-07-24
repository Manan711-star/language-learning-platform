-- Language Learning Platform - PostgreSQL Schema
-- Run this in pgAdmin 4 Query Tool

-- Drop existing objects (for clean reinstall)
DROP TABLE IF EXISTS user_achievements CASCADE;
DROP TABLE IF EXISTS achievements CASCADE;
DROP TABLE IF EXISTS user_challenge_attempts CASCADE;
DROP TABLE IF EXISTS challenges CASCADE;
DROP TABLE IF EXISTS quiz_attempts CASCADE;
DROP TABLE IF EXISTS quiz_options CASCADE;
DROP TABLE IF EXISTS quiz_questions CASCADE;
DROP TABLE IF EXISTS quizzes CASCADE;
DROP TABLE IF EXISTS user_lesson_progress CASCADE;
DROP TABLE IF EXISTS lessons CASCADE;
DROP TABLE IF EXISTS courses CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- Users table
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100),
    avatar_url VARCHAR(255) DEFAULT 'assets/images/avatar-default.svg',
    native_language VARCHAR(50) DEFAULT 'English',
    target_language VARCHAR(50),
    xp_points INTEGER DEFAULT 0,
    streak_days INTEGER DEFAULT 0,       -- current consecutive-day streak
    max_streak_days INTEGER DEFAULT 0,   -- highest streak the user has ever reached
    last_login DATE,
    last_streak_date DATE,               -- last calendar date a daily challenge was completed
    password_reset_token VARCHAR(255),   -- hashed reset token
    password_reset_expires TIMESTAMPTZ, -- token expiry (1 hour from request)
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Courses table
CREATE TABLE courses (
    id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    language VARCHAR(50) NOT NULL,
    description TEXT,
    level VARCHAR(20) DEFAULT 'Beginner',
    image_url VARCHAR(255),
    total_lessons INTEGER DEFAULT 0,
    duration_hours DECIMAL(5,1) DEFAULT 0,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Lessons table
CREATE TABLE lessons (
    id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    content TEXT NOT NULL,
    lesson_order INTEGER NOT NULL,
    xp_reward INTEGER DEFAULT 10,
    vocabulary JSONB,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User lesson progress
CREATE TABLE user_lesson_progress (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    lesson_id INTEGER REFERENCES lessons(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT FALSE,
    score INTEGER DEFAULT 0,
    completed_at TIMESTAMP,
    UNIQUE(user_id, lesson_id)
);

-- Quizzes table
CREATE TABLE quizzes (
    id SERIAL PRIMARY KEY,
    course_id INTEGER REFERENCES courses(id) ON DELETE CASCADE,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    time_limit_seconds INTEGER DEFAULT 300,
    passing_score INTEGER DEFAULT 70,
    xp_reward INTEGER DEFAULT 25,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Quiz questions
CREATE TABLE quiz_questions (
    id SERIAL PRIMARY KEY,
    quiz_id INTEGER REFERENCES quizzes(id) ON DELETE CASCADE,
    question_text TEXT NOT NULL,
    question_type VARCHAR(20) DEFAULT 'multiple_choice',
    question_order INTEGER NOT NULL
);

-- Quiz options
CREATE TABLE quiz_options (
    id SERIAL PRIMARY KEY,
    question_id INTEGER REFERENCES quiz_questions(id) ON DELETE CASCADE,
    option_text VARCHAR(255) NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE
);

-- Quiz attempts
CREATE TABLE quiz_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    quiz_id INTEGER REFERENCES quizzes(id) ON DELETE CASCADE,
    score INTEGER NOT NULL,
    total_questions INTEGER NOT NULL,
    passed BOOLEAN DEFAULT FALSE,
    time_taken_seconds INTEGER,
    attempted_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Daily challenges
-- Each challenge has a day_offset used for rotation.
-- The active challenge set for a given date is determined by:
--   (EXTRACT(EPOCH FROM CURRENT_DATE)::BIGINT / 86400) % <total distinct day_offsets>
-- Challenges with matching day_offset are shown as today's challenges.
CREATE TABLE challenges (
    id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    description TEXT,
    challenge_type VARCHAR(50) DEFAULT 'vocabulary',
    language VARCHAR(50),
    xp_reward INTEGER DEFAULT 15,
    difficulty VARCHAR(20) DEFAULT 'Easy',
    content JSONB NOT NULL,
    is_daily BOOLEAN DEFAULT TRUE,
    day_offset INTEGER DEFAULT 0,   -- which day slot this challenge belongs to (0, 1, 2, ...)
    active_date DATE,               -- kept for backwards compat, populated automatically on fetch
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- User challenge attempts
CREATE TABLE user_challenge_attempts (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    challenge_id INTEGER REFERENCES challenges(id) ON DELETE CASCADE,
    completed BOOLEAN DEFAULT FALSE,
    score INTEGER DEFAULT 0,
    completed_at TIMESTAMP,
    UNIQUE(user_id, challenge_id)
);

-- Achievements
CREATE TABLE achievements (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon_url VARCHAR(255),
    xp_required INTEGER DEFAULT 0,
    badge_color VARCHAR(20) DEFAULT 'gold'
);

-- User achievements
CREATE TABLE user_achievements (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id) ON DELETE CASCADE,
    achievement_id INTEGER REFERENCES achievements(id) ON DELETE CASCADE,
    earned_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(user_id, achievement_id)
);

-- Indexes for performance
CREATE INDEX idx_lessons_course ON lessons(course_id);
CREATE INDEX idx_lessons_course_order ON lessons(course_id, lesson_order);
CREATE INDEX idx_progress_user ON user_lesson_progress(user_id);
CREATE INDEX idx_user_lesson_user_completed ON user_lesson_progress(user_id, completed);
CREATE INDEX idx_quiz_questions_quiz ON quiz_questions(quiz_id);
CREATE INDEX idx_quiz_questions_quiz_order ON quiz_questions(quiz_id, question_order);
CREATE INDEX idx_quiz_options_question ON quiz_options(question_id);
CREATE INDEX idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX idx_quiz_attempts_user_quiz ON quiz_attempts(user_id, quiz_id);
CREATE INDEX idx_challenges_day_offset ON challenges(day_offset);
CREATE INDEX idx_user_challenge_attempts_challenge ON user_challenge_attempts(challenge_id);
CREATE INDEX idx_user_achievements_achievement ON user_achievements(achievement_id);

-- CHECK constraints for data integrity
ALTER TABLE users ADD CONSTRAINT check_xp_non_negative CHECK (xp_points >= 0);
ALTER TABLE users ADD CONSTRAINT check_streak_non_negative CHECK (streak_days >= 0);
ALTER TABLE users ADD CONSTRAINT check_max_streak_non_negative CHECK (max_streak_days >= 0);
ALTER TABLE courses ADD CONSTRAINT check_total_lessons_non_negative CHECK (total_lessons >= 0);
ALTER TABLE lessons ADD CONSTRAINT check_xp_reward_positive CHECK (xp_reward > 0);
ALTER TABLE quizzes ADD CONSTRAINT check_passing_score_range CHECK (passing_score >= 0 AND passing_score <= 100);
ALTER TABLE quiz_attempts ADD CONSTRAINT check_score_range CHECK (score >= 0 AND score <= 100);
ALTER TABLE challenges ADD CONSTRAINT check_day_offset_non_negative CHECK (day_offset >= 0);

-- Migration: Add password reset columns to users table
-- Run this if you already have an existing database (do NOT run on a fresh schema install).

ALTER TABLE users
  ADD COLUMN IF NOT EXISTS password_reset_token   VARCHAR(255),
  ADD COLUMN IF NOT EXISTS password_reset_expires  TIMESTAMPTZ;

-- Updated_at trigger for users
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at();
