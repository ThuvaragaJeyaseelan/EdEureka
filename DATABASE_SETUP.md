# Database Setup Guide - Quick Fix for "No Subjects Available"

If you're seeing "No subjects available" in the dropdown, follow these steps:

## Step 1: Verify Environment Variables

Make sure you have a `.env.local` file in the root directory with:

```env
VITE_SUPABASE_URL=https://your-project-id.supabase.co
VITE_SUPABASE_ANON_KEY=your-anon-key-here
```

**To get these values:**
1. Go to your Supabase project dashboard
2. Click on **Project Settings** (gear icon)
3. Go to **API** section
4. Copy the **Project URL** and **anon/public key**

## Step 2: Run the SQL Setup Script

1. Go to your Supabase project dashboard
2. Click on **SQL Editor** in the left sidebar
3. Click **New Query**
4. Open the file `supabase-setup.sql` from this project
5. Copy **ALL** the contents of that file
6. Paste it into the SQL Editor
7. Click **Run** (or press Ctrl+Enter)

This will create:
- All required tables
- The 4 subjects: Combined Maths, Physics, Chemistry, Biology
- Sample questions for each subject
- Row Level Security policies

## Step 3: Verify Subjects Were Created

1. In Supabase dashboard, go to **Table Editor**
2. Click on the **subjects** table
3. You should see 4 rows:
   - Combined Maths
   - Physics
   - Chemistry
   - Biology

If you don't see these, run this SQL query in the SQL Editor:

```sql
INSERT INTO subjects (name) VALUES
  ('Combined Maths'),
  ('Physics'),
  ('Chemistry'),
  ('Biology')
ON CONFLICT (name) DO NOTHING;
```

## Step 4: Restart Your Development Server

After setting up the database:

1. Stop your dev server (Ctrl+C)
2. Make sure `.env.local` is saved
3. Run `npm run dev` again
4. Refresh your browser

## Troubleshooting

### Error: "Missing Supabase environment variables"
- Make sure `.env.local` exists in the root directory (same level as `package.json`)
- Check that variable names start with `VITE_`
- Restart the dev server after creating/updating `.env.local`

### Error: "Failed to load subjects"
- Check browser console (F12) for detailed error messages
- Verify your Supabase project is active (not paused)
- Make sure you've run the SQL setup script
- Check that RLS policies allow reading from the `subjects` table

### Still not working?
1. Open browser console (F12)
2. Check for any red error messages
3. Look for messages about Supabase connection
4. Verify your Supabase project URL is correct (no typos)

## Quick Test Query

Run this in Supabase SQL Editor to test:

```sql
SELECT * FROM subjects;
```

You should see 4 rows. If you see 0 rows, the subjects weren't inserted. Run the INSERT statement from Step 3.

