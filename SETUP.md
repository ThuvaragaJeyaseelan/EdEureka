# Setup Guide for AL Exam Prep Platform

## Quick Start

### 1. Install Dependencies

```bash
npm install
```

### 2. Set Up Supabase

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. Go to **SQL Editor** in your Supabase dashboard
4. Copy and paste the entire contents of `supabase-setup.sql` and run it
5. Go to **Project Settings** > **API**
6. Copy your **Project URL** and **anon/public key**

### 3. Set Up OpenAI (Optional - for AI features)

1. Go to [platform.openai.com](https://platform.openai.com)
2. Create an account or sign in
3. Go to **API Keys** section
4. Create a new API key
5. Copy the API key (you won't be able to see it again!)

### 4. Configure Environment Variables

Create a `.env.local` file in the root directory of the project:

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
VITE_OPENAI_API_KEY=sk-your-openai-key-here
```

**Important Notes:**
- Replace the placeholder values with your actual credentials
- The `.env.local` file is already in `.gitignore` and won't be committed to git
- Without OpenAI API key, AI features (chat and summarization) will show error messages

### 5. Run the Development Server

```bash
npm run dev
```

The application will be available at `http://localhost:5173`

## Testing the Application

1. **Sign Up**: Create a new account with your email and password
2. **Dashboard**: You'll see your profile, analytics (empty initially), and leaderboard
3. **Select Subject**: Use the dropdown in the navbar to select a subject
4. **Take Quiz**: 
   - Click on "Sample Questions" card
   - Select number of questions (5, 10, 15, or 20)
   - Answer questions and submit
   - View your results with explanations
5. **AI Features**: 
   - Click "AI Chat Assistant" to ask questions
   - Click "Summarize Content" to summarize text

## Adding More Questions

To add more questions to the database:

1. Go to your Supabase dashboard
2. Navigate to **Table Editor** > **questions**
3. Click **Insert** > **Insert row**
4. Fill in the fields:
   - `subject_id`: Select from the subjects table (get the UUID)
   - `question_text`: Your question
   - `option_a`, `option_b`, `option_c`, `option_d`: The four answer choices
   - `correct_answer`: 'A', 'B', 'C', or 'D'
   - `explanation`: Explanation for the correct answer
   - `difficulty_level`: 'easy', 'medium', or 'hard'

Or use SQL:

```sql
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
VALUES (
  'subject-uuid-here',
  'Your question text here?',
  'Option A text',
  'Option B text',
  'Option C text',
  'Option D text',
  'A',
  'Explanation for why A is correct',
  'medium'
);
```

## Troubleshooting

### "Missing Supabase environment variables" error
- Make sure `.env.local` file exists in the root directory
- Check that variable names start with `VITE_`
- Restart the dev server after creating/updating `.env.local`

### "OpenAI API key not configured" error
- This is expected if you haven't set up OpenAI
- AI features won't work, but the rest of the app will function normally
- To enable AI features, add your OpenAI API key to `.env.local`

### Database connection issues
- Verify your Supabase project is active
- Check that you've run the SQL setup script
- Ensure RLS policies are enabled (they're included in the setup script)

### Questions not loading
- Make sure you've inserted sample questions using the SQL script
- Check that subjects exist in the `subjects` table
- Verify the `subject_id` in questions matches an actual subject UUID

## Building for Production

```bash
npm run build
```

The built files will be in the `dist` directory. You can deploy this to any static hosting service like:
- Vercel
- Netlify
- GitHub Pages
- AWS S3 + CloudFront

## Environment Variables for Production

When deploying, make sure to set the environment variables in your hosting platform:
- `VITE_SUPABASE_URL`
- `VITE_SUPABASE_ANON_KEY`
- `VITE_OPENAI_API_KEY` (optional)

