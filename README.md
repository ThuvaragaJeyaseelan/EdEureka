# Ed-Eureka

A comprehensive Vue.js-based platform for AL (Advanced Level) examination preparation, focusing on Combined Maths, Physics, Chemistry, and Biology streams with MCQ practice, analytics, and AI-powered features.

## Features

- 🔐 **Authentication**: Secure login/signup using Supabase Auth
- 📊 **Dashboard**: Student analytics, progress tracking, and leaderboards
- 📚 **Subject Selection**: Combined Maths, Physics, Chemistry, and Biology
- 📝 **Quiz System**: Randomized MCQ questions with instant feedback
- 🤖 **AI Features**: Chat assistant and text summarization using OpenAI
- 📈 **Analytics**: Daily practice tracking, learning curves, and performance charts

## Tech Stack

- **Frontend**: Vue 3 (Composition API) + Vite
- **Styling**: Tailwind CSS
- **State Management**: Pinia
- **Routing**: Vue Router
- **Backend/Database**: Supabase (PostgreSQL + Auth)
- **Charts**: Chart.js
- **AI**: Multi-provider support (Google Gemini, Groq, OpenAI) - Free options available!

## Prerequisites

- Node.js 18+ and npm
- A Supabase account (free tier works)
- An AI API key (for AI features) - **Free options available!** See [FREE_AI_SETUP.md](./FREE_AI_SETUP.md)

## Setup Instructions

### 1. Clone and Install Dependencies

```bash
npm install
```

### 2. Set Up Supabase

1. Create a new project at [supabase.com](https://supabase.com)
2. Go to SQL Editor in your Supabase dashboard
3. Run the SQL script from `supabase-setup.sql` to create all tables and policies
4. Go to Project Settings > API to get your project URL and anon key

### 3. Configure Environment Variables

Create a `.env.local` file in the root directory:

```env
VITE_SUPABASE_URL=your_supabase_project_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
VITE_OPENAI_API_KEY=your_openai_api_key
```

**Note**: Replace the placeholder values with your actual credentials.

### 4. Run the Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## Project Structure

```
src/
├── components/
│   ├── common/          # Navbar, LoadingSpinner
│   ├── auth/            # LoginForm, SignupForm
│   ├── dashboard/       # StudentProfile, AnalyticsChart, Leaderboard
│   ├── quiz/            # QuestionCard, QuizResults, QuestionCounter
│   └── ai/              # AIChatCard, SummarizeCard
├── views/               # Home, Login, Signup, Dashboard, SubjectPage, QuizPage
├── stores/              # Pinia stores (auth, quiz, analytics)
├── services/            # Supabase, OpenAI, Quiz services
├── router/              # Vue Router configuration
└── utils/               # Validators and utilities
```

## Database Schema

The platform uses the following tables:

- **subjects**: Available subjects (Combined Maths, Physics, Chemistry, Biology)
- **questions**: MCQ questions with options and explanations
- **quiz_attempts**: Records of quiz sessions
- **quiz_responses**: Individual question responses
- **daily_practice**: Daily practice analytics per subject

## Usage

1. **Sign Up**: Create a new account with email and password
2. **Dashboard**: View your profile, analytics, and leaderboard
3. **Select Subject**: Choose a subject from the dropdown
4. **Practice**: 
   - Take quizzes with randomized questions
   - Use AI chat for instant help
   - Summarize long texts
5. **Track Progress**: View daily practice charts and learning curves

## Adding Questions

To add more questions, insert them into the `questions` table in Supabase:

```sql
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
VALUES (
  'subject-uuid-here',
  'Your question text',
  'Option A',
  'Option B',
  'Option C',
  'Option D',
  'A', -- or B, C, D
  'Explanation for the answer',
  'easy' -- or 'medium', 'hard'
);
```

## Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory.

## Notes

- The OpenAI API key is required for AI features (chat and summarization). Without it, these features will show error messages.
- Make sure Row Level Security (RLS) policies are properly set up in Supabase for data security.
- Sample questions are included in the SQL setup file, but you should add more for a complete experience.

## License

This project is provided as-is for educational purposes.
