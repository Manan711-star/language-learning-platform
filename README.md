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
| Email | Resend |
| File Upload | Multer |
| Environment | dotenv |

---

## Project Structure

```
language-learning-platform/
├── backend/
│   ├── config/
│   │   └── db.js                    # PostgreSQL connection pool
│   ├── middleware/
│   │   ├── auth.js                  # JWT authentication middleware
│   │   └── upload.js                # Multer file upload config
│   ├── routes/
│   │   ├── auth.js                  # Register, login, profile, avatar, forgot/reset password
│   │   ├── courses.js               # Courses and lessons
│   │   ├── quizzes.js               # Quiz questions and attempts
│   │   ├── challenges.js            # Daily challenges
│   │   └── progress.js              # Dashboard, leaderboard, stats
│   ├── server.js                    # Express app entry point
│   └── package.json
├── frontend/
│   ├── assets/images/               # SVG course and badge images
│   ├── css/style.css                # Global styles
│   ├── js/api.js                    # API client and shared utilities
│   ├── uploads/avatars/             # User uploaded profile photos
│   ├── index.html                   # Home page
│   ├── login.html                   # Login page
│   ├── register.html                # Register page
│   ├── forgot-password.html         # Forgot password page
│   ├── reset-password.html          # Reset password page
│   ├── dashboard.html               # User dashboard
│   ├── courses.html                 # All courses
│   ├── course-detail.html           # Course lessons and quizzes
│   ├── lesson.html                  # Individual lesson
│   ├── quiz.html                    # Quiz page
│   ├── challenges.html              # Daily challenges
│   └── profile.html                 # User profile and settings
├── database/
│   ├── schema.sql                   # All tables, indexes, and constraints
│   ├── seed.sql                     # Initial courses, lessons, quizzes, challenges
│   └── migrations/
│       └── 001_add_password_reset.sql  # Add password reset columns (existing DBs)
├── LinguaVerse.postman_collection.json  # Postman API collection
├── .env                             # Local environment variables (never commit)
└── README.md
```

---

## Features

- **User Authentication** — Register, login, JWT-based sessions, profile photo upload
- **Forgot / Reset Password** — Secure email-based password reset via Resend
- **Password Policy** — Min 8 characters, uppercase, number, and special character required
- **6 Language Courses** — Spanish, French, German, Japanese, Italian, Chinese
- **Structured Lessons** — Content with vocabulary cards and XP rewards
- **Interactive Quizzes** — Timed multiple-choice quizzes with pass/fail scoring
- **Daily Challenges** — Rotating vocabulary, translation, grammar, recognition, and pronunciation challenges
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

> **Existing database?** If you already have data and are upgrading, run the migration instead of the full schema:
> ```bash
> psql -U postgres -d your_database_name -f database/migrations/001_add_password_reset.sql
> ```

### 3. Configure Environment Variables

Create a `.env` file in the project root with your actual values:

```env
PORT=3000

# PostgreSQL
DB_HOST=localhost
DB_PORT=5432
DB_NAME=linguaverse
DB_USER=postgres
DB_PASSWORD=your_postgres_password

# JWT — use any long random string, keep it secret
JWT_SECRET=your_secret_key_here

# App URL — used to build the password reset link in emails
APP_URL=http://localhost:3000

# Resend — for forgot password emails
# Sign up free at https://resend.com (100 emails/day, no credit card)
RESEND_API_KEY=re_your_api_key_here
```

> **Note:** Never commit `.env` to version control. It is already in `.gitignore`.

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
| GET | `/api/health` | Health check | No |
| POST | `/api/auth/register` | Register a new user | No |
| POST | `/api/auth/login` | Login and get JWT token | No |
| GET | `/api/auth/profile` | Get current user profile | Yes |
| PUT | `/api/auth/profile` | Update profile details | Yes |
| POST | `/api/auth/profile/avatar` | Upload profile photo | Yes |
| POST | `/api/auth/forgot-password` | Request a password reset email | No |
| POST | `/api/auth/reset-password` | Reset password using email token | No |
| GET | `/api/courses` | List all courses | No |
| GET | `/api/courses/:id` | Course details with lessons | No |
| GET | `/api/courses/:id/lessons/:lessonId` | Get a single lesson | Yes |
| POST | `/api/courses/:id/lessons/:lessonId/complete` | Mark lesson complete | Yes |
| GET | `/api/quizzes/:id` | Get quiz with questions | Yes |
| POST | `/api/quizzes/:id/submit` | Submit quiz answers | Yes |
| GET | `/api/challenges` | Get today's challenges | Yes |
| GET | `/api/challenges/:id` | Get a single challenge | Yes |
| POST | `/api/challenges/:id/complete` | Submit challenge completion | Yes |
| GET | `/api/progress/dashboard` | Dashboard stats and progress | Yes |
| GET | `/api/progress/leaderboard` | Top learners by XP | No |

> All endpoints accept parameters via **JSON body** or **query params** interchangeably.

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
| `JWT_SECRET` | Secret key for signing JWTs — required, no default | `any_long_random_string` |
| `APP_URL` | Base URL used in password reset emails | `http://localhost:3000` |
| `RESEND_API_KEY` | API key from resend.com for sending emails | `re_xxxxxxxxxxxx` |

---

## Password Policy

All passwords (registration and reset) must meet the following requirements:

- At least **8 characters**
- At least one **uppercase letter**
- At least one **number**
- At least one **special character** (e.g. `@`, `#`, `$`, `!`)

The register and reset-password pages show a live checklist as you type.

---

## Forgot Password Flow

1. User clicks **Forgot password?** on the login page
2. Enters their email on `forgot-password.html`
3. A secure reset link is emailed via [Resend](https://resend.com)
4. User clicks the link → lands on `reset-password.html`
5. Enters and confirms a new password (must pass the policy)
6. Password is updated — user is redirected to login

Reset links expire after **1 hour** and can only be used once.

---


## Getting Started

After running `seed.sql`, there are no pre-created users. Register a new account at `http://localhost:3000/register.html` to get started.

> After registration, you are redirected to the login page. Enter your credentials to log in and access the dashboard.
