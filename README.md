# LinguaVerse - Language Learning Platform

A full-stack web application for learning languages through structured courses, interactive quizzes, and daily challenges. Supports Spanish, French, German, Japanese, Italian, and Chinese.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | HTML5, CSS3, Bootstrap 5.3, Vanilla JavaScript |
| Backend | Node.js, Express.js |
| Database | PostgreSQL |
| Auth | JWT (JSON Web Tokens), bcryptjs |
| File Upload | Multer |
| Environment | dotenv |

---

## Project Structure

```
language-learning-platform/
├── backend/
│   ├── config/
│   │   └── db.js              # PostgreSQL connection
│   ├── middleware/
│   │   ├── auth.js            # JWT authentication middleware
│   │   └── upload.js          # Multer file upload config
│   ├── routes/
│   │   ├── auth.js            # Register, login, profile, avatar
│   │   ├── courses.js         # Courses and lessons
│   │   ├── quizzes.js         # Quiz questions and attempts
│   │   ├── challenges.js      # Daily challenges
│   │   └── progress.js        # Dashboard, leaderboard, stats
│   ├── server.js              # Express app entry point
│   └── package.json
├── frontend/
│   ├── assets/images/         # SVG course and badge images
│   ├── css/style.css          # Global styles
│   ├── js/api.js              # API client and shared utilities
│   ├── uploads/avatars/       # User uploaded profile photos
│   ├── index.html             # Home page
│   ├── login.html             # Login page
│   ├── register.html          # Register page
│   ├── dashboard.html         # User dashboard
│   ├── courses.html           # All courses
│   ├── course-detail.html     # Course lessons and quizzes
│   ├── lesson.html            # Individual lesson
│   ├── quiz.html              # Quiz page
│   ├── challenges.html        # Daily challenges
│   └── profile.html           # User profile and settings
├── database/
│   ├── schema.sql             # All tables, indexes, and constraints
│   └── seed.sql               # Initial courses, lessons, quizzes, challenges
├── .env.example               # Environment variable template
└── README.md
```

---

## Features

- **User Authentication** — Register, login, JWT-based sessions, profile photo upload
- **6 Language Courses** — Spanish, French, German, Japanese, Italian, Chinese
- **Structured Lessons** — Content with vocabulary cards and XP rewards
- **Interactive Quizzes** — Timed multiple-choice quizzes with pass/fail scoring
- **Daily Challenges** — Rotating vocabulary, translation, grammar, and pronunciation challenges
- **XP & Streaks** — Earn XP points and maintain daily learning streaks
- **Achievements** — Unlock badges for milestones (First Steps, Quiz Master, Polyglot, etc.)
- **Leaderboard** — See top learners ranked by XP
- **Dashboard** — Track progress, recent activity, and course completion

---

## Prerequisites

Make sure you have the following installed before running the project:

- [Node.js](https://nodejs.org/) v18 or higher
- [PostgreSQL](https://www.postgresql.org/) v14 or higher
- [pgAdmin 4](https://www.pgadmin.org/) (optional, for managing the database visually)

---

## Setup & Installation

### 1. Clone the Repository

```bash
git clone https://gitlab.com/your-username/language-learning-platform.git
cd language-learning-platform
```

### 2. Set Up the Database

Open **pgAdmin 4** (or any PostgreSQL client) and run the following SQL files **in order**:

1. Open the Query Tool for your target database
2. Run `database/schema.sql` — creates all tables, indexes, and constraints
3. Run `database/seed.sql` — inserts all courses, lessons, quizzes, and challenges

Or using the `psql` command line:

```bash
psql -U postgres -d your_database_name -f database/schema.sql
psql -U postgres -d your_database_name -f database/seed.sql
```

### 3. Configure Environment Variables

Copy the example env file and fill in your values:

```bash
cp .env.example .env
```

Edit `.env` with your actual values:

```env
PORT=3000
DB_HOST=localhost
DB_PORT=5432
DB_NAME=linguaverse
DB_USER=postgres
DB_PASSWORD=your_postgres_password
JWT_SECRET=your_secret_key_here
```

> **Note:** `JWT_SECRET` can be any long random string. Keep it secret and never commit `.env` to version control.

### 4. Install Backend Dependencies

```bash
cd backend
npm install
```

### 5. Run the Server

```bash
npm start
```

The server will start at **http://localhost:3000**

Open your browser and go to `http://localhost:3000` to use the app.

---

## API Endpoints

| Method | Endpoint | Description | Auth |
|---|---|---|---|
| POST | `/api/auth/register` | Register a new user | No |
| POST | `/api/auth/login` | Login and get JWT token | No |
| GET | `/api/auth/profile` | Get current user profile | Yes |
| PUT | `/api/auth/profile` | Update profile details | Yes |
| POST | `/api/auth/profile/avatar` | Upload profile photo | Yes |
| GET | `/api/courses` | List all courses | No |
| GET | `/api/courses/:id` | Course details with lessons | No |
| GET | `/api/courses/:id/lessons/:lessonId` | Get a single lesson | Yes |
| POST | `/api/courses/:id/lessons/:lessonId/complete` | Mark lesson complete | Yes |
| GET | `/api/quizzes/:id` | Get quiz with questions | Yes |
| POST | `/api/quizzes/:id/attempt` | Submit quiz answers | Yes |
| GET | `/api/challenges` | Get today's challenges | Yes |
| POST | `/api/challenges/:id/complete` | Submit challenge answers | Yes |
| GET | `/api/progress/dashboard` | Dashboard stats and progress | Yes |
| GET | `/api/progress/leaderboard` | Top learners by XP | No |

---

## Environment Variables Reference

| Variable | Description | Example |
|---|---|---|
| `PORT` | Port the server runs on | `3000` |
| `DB_HOST` | PostgreSQL host | `localhost` |
| `DB_PORT` | PostgreSQL port | `5432` |
| `DB_NAME` | Database name | `linguaverse` |
| `DB_USER` | PostgreSQL username | `postgres` |
| `DB_PASSWORD` | PostgreSQL password | `yourpassword` |
| `JWT_SECRET` | Secret key for signing JWTs | `any_long_random_string` |

---

## Default Test Account

After running `seed.sql`, there are no pre-created users. Register a new account at `http://localhost:3000/register.html` to get started.
