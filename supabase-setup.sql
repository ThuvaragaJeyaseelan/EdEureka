-- AL Exam Prep Platform - Supabase Database Setup
-- Run this SQL in your Supabase SQL Editor

-- 1. Create subjects table
CREATE TABLE IF NOT EXISTS subjects (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL UNIQUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insert default subjects
INSERT INTO subjects (name) VALUES
  ('Combined Maths'),
  ('Physics'),
  ('Chemistry'),
  ('Biology')
ON CONFLICT (name) DO NOTHING;

-- 2. Create questions table
CREATE TABLE IF NOT EXISTS questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  question_text TEXT NOT NULL,
  option_a TEXT NOT NULL,
  option_b TEXT NOT NULL,
  option_c TEXT NOT NULL,
  option_d TEXT NOT NULL,
  correct_answer TEXT NOT NULL CHECK (correct_answer IN ('A', 'B', 'C', 'D')),
  explanation TEXT,
  difficulty_level TEXT DEFAULT 'medium' CHECK (difficulty_level IN ('easy', 'medium', 'hard')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 3. Create quiz_attempts table
CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  total_questions INTEGER NOT NULL,
  correct_answers INTEGER DEFAULT 0,
  score DECIMAL(5, 2) DEFAULT 0,
  started_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  completed_at TIMESTAMP WITH TIME ZONE
);

-- 4. Create quiz_responses table
CREATE TABLE IF NOT EXISTS quiz_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_attempt_id UUID NOT NULL REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  question_id UUID NOT NULL REFERENCES questions(id) ON DELETE CASCADE,
  selected_answer TEXT CHECK (selected_answer IN ('A', 'B', 'C', 'D', '')),
  is_correct BOOLEAN DEFAULT FALSE,
  answered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5. Create daily_practice table
CREATE TABLE IF NOT EXISTS daily_practice (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  practice_date DATE NOT NULL,
  questions_attempted INTEGER DEFAULT 0,
  average_score DECIMAL(5, 2) DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  UNIQUE(user_id, subject_id, practice_date)
);

-- 5a. Create study_plans table
CREATE TABLE IF NOT EXISTS study_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  description TEXT,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  daily_goal INTEGER NOT NULL DEFAULT 20,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5b. Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT NOT NULL,
  message TEXT NOT NULL,
  icon TEXT DEFAULT '🔔',
  read BOOLEAN DEFAULT FALSE,
  read_at TIMESTAMP WITH TIME ZONE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 5c. Create resource_books table
CREATE TABLE IF NOT EXISTS resource_books (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  subject_id UUID NOT NULL REFERENCES subjects(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  author TEXT NOT NULL,
  description TEXT,
  edition TEXT,
  isbn TEXT,
  link TEXT,
  pdf_path TEXT, -- Path in Supabase Storage (e.g., 'subject-id/book-id_timestamp.pdf')
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 6. Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_questions_subject_id ON questions(subject_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user_id ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_subject_id ON quiz_attempts(subject_id);
CREATE INDEX IF NOT EXISTS idx_quiz_responses_quiz_attempt_id ON quiz_responses(quiz_attempt_id);
CREATE INDEX IF NOT EXISTS idx_daily_practice_user_id ON daily_practice(user_id);
CREATE INDEX IF NOT EXISTS idx_daily_practice_subject_id ON daily_practice(subject_id);
CREATE INDEX IF NOT EXISTS idx_daily_practice_date ON daily_practice(practice_date);
CREATE INDEX IF NOT EXISTS idx_study_plans_user_id ON study_plans(user_id);
CREATE INDEX IF NOT EXISTS idx_study_plans_subject_id ON study_plans(subject_id);
CREATE INDEX IF NOT EXISTS idx_notifications_user_id ON notifications(user_id);
CREATE INDEX IF NOT EXISTS idx_notifications_read ON notifications(user_id, read);
CREATE INDEX IF NOT EXISTS idx_resource_books_subject_id ON resource_books(subject_id);
CREATE INDEX IF NOT EXISTS idx_resource_books_active ON resource_books(is_active);

-- 7. Enable Row Level Security (RLS)
ALTER TABLE subjects ENABLE ROW LEVEL SECURITY;
ALTER TABLE questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_practice ENABLE ROW LEVEL SECURITY;
ALTER TABLE study_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE resource_books ENABLE ROW LEVEL SECURITY;

-- 8. Create RLS Policies
-- Drop existing policies if they exist (to allow re-running the script)

-- Subjects: Everyone can read
DROP POLICY IF EXISTS "Subjects are viewable by everyone" ON subjects;
CREATE POLICY "Subjects are viewable by everyone"
  ON subjects FOR SELECT
  USING (true);

-- Questions: Everyone can read
DROP POLICY IF EXISTS "Questions are viewable by everyone" ON questions;
CREATE POLICY "Questions are viewable by everyone"
  ON questions FOR SELECT
  USING (true);

-- Quiz attempts: Users can only see their own attempts
DROP POLICY IF EXISTS "Users can view their own quiz attempts" ON quiz_attempts;
CREATE POLICY "Users can view their own quiz attempts"
  ON quiz_attempts FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own quiz attempts" ON quiz_attempts;
CREATE POLICY "Users can insert their own quiz attempts"
  ON quiz_attempts FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own quiz attempts" ON quiz_attempts;
CREATE POLICY "Users can update their own quiz attempts"
  ON quiz_attempts FOR UPDATE
  USING (auth.uid() = user_id);

-- Quiz responses: Users can only see responses for their own quiz attempts
DROP POLICY IF EXISTS "Users can view their own quiz responses" ON quiz_responses;
CREATE POLICY "Users can view their own quiz responses"
  ON quiz_responses FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM quiz_attempts
      WHERE quiz_attempts.id = quiz_responses.quiz_attempt_id
      AND quiz_attempts.user_id = auth.uid()
    )
  );

DROP POLICY IF EXISTS "Users can insert their own quiz responses" ON quiz_responses;
CREATE POLICY "Users can insert their own quiz responses"
  ON quiz_responses FOR INSERT
  WITH CHECK (
    EXISTS (
      SELECT 1 FROM quiz_attempts
      WHERE quiz_attempts.id = quiz_responses.quiz_attempt_id
      AND quiz_attempts.user_id = auth.uid()
    )
  );

-- Daily practice: Users can only see their own practice data
DROP POLICY IF EXISTS "Users can view their own daily practice" ON daily_practice;
CREATE POLICY "Users can view their own daily practice"
  ON daily_practice FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own daily practice" ON daily_practice;
CREATE POLICY "Users can insert their own daily practice"
  ON daily_practice FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own daily practice" ON daily_practice;
CREATE POLICY "Users can update their own daily practice"
  ON daily_practice FOR UPDATE
  USING (auth.uid() = user_id);

-- Study plans: Users can only see their own plans
DROP POLICY IF EXISTS "Users can view their own study plans" ON study_plans;
CREATE POLICY "Users can view their own study plans"
  ON study_plans FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own study plans" ON study_plans;
CREATE POLICY "Users can insert their own study plans"
  ON study_plans FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own study plans" ON study_plans;
CREATE POLICY "Users can update their own study plans"
  ON study_plans FOR UPDATE
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can delete their own study plans" ON study_plans;
CREATE POLICY "Users can delete their own study plans"
  ON study_plans FOR DELETE
  USING (auth.uid() = user_id);

-- Notifications: Users can only see their own notifications
DROP POLICY IF EXISTS "Users can view their own notifications" ON notifications;
CREATE POLICY "Users can view their own notifications"
  ON notifications FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert their own notifications" ON notifications;
CREATE POLICY "Users can insert their own notifications"
  ON notifications FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update their own notifications" ON notifications;
CREATE POLICY "Users can update their own notifications"
  ON notifications FOR UPDATE
  USING (auth.uid() = user_id);

-- Resource books: Everyone can read active books
DROP POLICY IF EXISTS "Resource books are viewable by everyone" ON resource_books;
CREATE POLICY "Resource books are viewable by everyone"
  ON resource_books FOR SELECT
  USING (is_active = true);

-- 9. Create a function to get user display names for leaderboard
-- This function helps retrieve user metadata for display purposes
CREATE OR REPLACE FUNCTION get_user_display_name(user_uuid UUID)
RETURNS TEXT AS $$
DECLARE
  user_meta JSONB;
BEGIN
  SELECT raw_user_meta_data INTO user_meta
  FROM auth.users
  WHERE id = user_uuid;
  
  IF user_meta->>'name' IS NOT NULL THEN
    RETURN user_meta->>'name';
  ELSE
    RETURN 'User ' || SUBSTRING(user_uuid::TEXT, 1, 8);
  END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 10. Insert sample questions (at least 20 per subject)
-- Combined Maths questions (20+ questions)
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the derivative of x²?', 'x', '2x', 'x²', '2x²', 'B', 'The derivative of x² is 2x using the power rule: d/dx(xⁿ) = nxⁿ⁻¹', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of sin(90°)?', '0', '1', '0.5', '√2/2', 'B', 'sin(90°) = 1, which is the maximum value of the sine function.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the integral of 2x?', 'x²', 'x² + C', '2x²', 'x', 'B', 'The integral of 2x is x² + C, where C is the constant of integration.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of cos(0°)?', '0', '1', '0.5', '√3/2', 'B', 'cos(0°) = 1, which is the maximum value of the cosine function.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the derivative of sin(x)?', 'cos(x)', '-cos(x)', 'sin(x)', '-sin(x)', 'A', 'The derivative of sin(x) is cos(x).', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of tan(45°)?', '0', '1', '√3', '1/√3', 'B', 'tan(45°) = 1, as it is the ratio of sin(45°) to cos(45°), both equal to √2/2.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the quadratic formula?', 'x = (-b ± √(b²-4ac))/2a', 'x = (-b ± √(b²+4ac))/2a', 'x = (b ± √(b²-4ac))/2a', 'x = (-b ± √(4ac-b²))/2a', 'A', 'The quadratic formula is x = (-b ± √(b²-4ac))/2a for the equation ax² + bx + c = 0.', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the derivative of eˣ?', 'eˣ', 'xeˣ', 'eˣ/x', 'ln(x)', 'A', 'The derivative of eˣ is eˣ itself, making it unique among exponential functions.', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of log₁₀(100)?', '1', '2', '10', '100', 'B', 'log₁₀(100) = 2 because 10² = 100.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the limit of (x²-1)/(x-1) as x approaches 1?', '0', '1', '2', 'Undefined', 'C', 'Using L''Hôpital''s rule or factoring: (x²-1)/(x-1) = (x+1)(x-1)/(x-1) = x+1, so the limit is 2.', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the derivative of ln(x)?', '1/x', 'x', '1', 'ln(x)', 'A', 'The derivative of ln(x) is 1/x.', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of √(-1)?', '1', '-1', 'i', '0', 'C', '√(-1) = i, where i is the imaginary unit.', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the product rule for derivatives?', '(fg)'' = f''g + fg''', '(fg)'' = f''g''', '(fg)'' = f'' + g''', '(fg)'' = fg', 'A', 'The product rule states that the derivative of f(x)g(x) is f''(x)g(x) + f(x)g''(x).', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of sin²(x) + cos²(x)?', '0', '1', 'sin(2x)', 'cos(2x)', 'B', 'This is the Pythagorean identity: sin²(x) + cos²(x) = 1 for all values of x.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chain rule for derivatives?', '(f(g(x)))'' = f''(g(x))g''(x)', '(f(g(x)))'' = f''(g(x))', '(f(g(x)))'' = g''(x)', '(f(g(x)))'' = f(x)g(x)', 'A', 'The chain rule states that the derivative of f(g(x)) is f''(g(x)) × g''(x).', 'hard' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the derivative of x³?', 'x²', '3x²', '3x', 'x³', 'B', 'Using the power rule: d/dx(x³) = 3x².', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of 2⁵?', '16', '32', '64', '10', 'B', '2⁵ = 2 × 2 × 2 × 2 × 2 = 32.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the area of a circle with radius r?', 'πr', 'πr²', '2πr', 'πr²/2', 'B', 'The area of a circle is πr², where r is the radius.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the circumference of a circle with radius r?', 'πr', 'πr²', '2πr', 'πr²/2', 'C', 'The circumference of a circle is 2πr, where r is the radius.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the derivative of 5x⁴?', '5x³', '20x³', '20x⁴', '5x⁵', 'B', 'Using the power rule: d/dx(5x⁴) = 5 × 4x³ = 20x³.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the sum of angles in a triangle?', '90°', '180°', '270°', '360°', 'B', 'The sum of interior angles in any triangle is always 180°.', 'easy' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the value of i²?', '1', '-1', 'i', '0', 'B', 'i² = -1, where i is the imaginary unit.', 'medium' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the quotient rule for derivatives?', '(f/g)'' = (f''g - fg'')/g²', '(f/g)'' = f''/g''', '(f/g)'' = f'' - g''', '(f/g)'' = fg', 'A', 'The quotient rule states that the derivative of f(x)/g(x) is (f''(x)g(x) - f(x)g''(x))/g(x)².', 'hard' FROM subjects s WHERE s.name = 'Combined Maths' LIMIT 1;

-- Physics questions (20+ questions)
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the SI unit of force?', 'Joule', 'Newton', 'Watt', 'Pascal', 'B', 'Force is measured in Newtons (N), named after Sir Isaac Newton.', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the speed of light in vacuum?', '3 × 10⁸ m/s', '3 × 10⁶ m/s', '3 × 10¹⁰ m/s', '3 × 10¹² m/s', 'A', 'The speed of light in vacuum is approximately 3 × 10⁸ meters per second.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the SI unit of energy?', 'Newton', 'Joule', 'Watt', 'Volt', 'B', 'Energy is measured in Joules (J).', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is Newton''s first law of motion?', 'F = ma', 'An object at rest stays at rest', 'Every action has an equal reaction', 'Energy is conserved', 'B', 'Newton''s first law states that an object at rest stays at rest, and an object in motion stays in motion unless acted upon by a force.', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is Newton''s second law of motion?', 'F = ma', 'An object at rest stays at rest', 'Every action has an equal reaction', 'Energy is conserved', 'A', 'Newton''s second law states that F = ma, where F is force, m is mass, and a is acceleration.', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the acceleration due to gravity on Earth?', '9.8 m/s²', '10 m/s²', '8.9 m/s²', '11 m/s²', 'A', 'The standard acceleration due to gravity on Earth is approximately 9.8 m/s².', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the SI unit of power?', 'Joule', 'Newton', 'Watt', 'Volt', 'C', 'Power is measured in Watts (W), where 1 W = 1 J/s.', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the formula for kinetic energy?', 'mgh', '½mv²', 'mv', 'mgh²', 'B', 'Kinetic energy is given by KE = ½mv², where m is mass and v is velocity.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the formula for potential energy?', 'mgh', '½mv²', 'mv', 'mgh²', 'A', 'Potential energy is given by PE = mgh, where m is mass, g is gravity, and h is height.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the SI unit of electric current?', 'Volt', 'Ampere', 'Ohm', 'Watt', 'B', 'Electric current is measured in Amperes (A).', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is Ohm''s law?', 'V = IR', 'P = IV', 'E = mc²', 'F = ma', 'A', 'Ohm''s law states that voltage (V) equals current (I) times resistance (R): V = IR.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the SI unit of resistance?', 'Volt', 'Ampere', 'Ohm', 'Watt', 'C', 'Electrical resistance is measured in Ohms (Ω).', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the frequency of a wave with period 0.5 seconds?', '0.5 Hz', '1 Hz', '2 Hz', '4 Hz', 'C', 'Frequency = 1/period = 1/0.5 = 2 Hz.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the speed of sound in air at room temperature?', '330 m/s', '343 m/s', '300 m/s', '350 m/s', 'B', 'The speed of sound in air at room temperature (20°C) is approximately 343 m/s.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the formula for momentum?', 'mv', 'ma', 'mgh', '½mv²', 'A', 'Momentum is given by p = mv, where m is mass and v is velocity.', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the law of conservation of energy?', 'Energy cannot be created', 'Energy cannot be destroyed', 'Energy cannot be created or destroyed', 'Energy increases over time', 'C', 'The law of conservation of energy states that energy cannot be created or destroyed, only transformed.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the SI unit of pressure?', 'Newton', 'Joule', 'Pascal', 'Watt', 'C', 'Pressure is measured in Pascals (Pa), where 1 Pa = 1 N/m².', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the formula for work done?', 'Fd', 'ma', 'mv', 'mgh', 'A', 'Work done is given by W = Fd, where F is force and d is displacement.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the wavelength of a wave with frequency 100 Hz and speed 340 m/s?', '0.34 m', '3.4 m', '34 m', '340 m', 'B', 'Wavelength = speed/frequency = 340/100 = 3.4 m.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the charge of an electron?', '+1.6 × 10⁻¹⁹ C', '-1.6 × 10⁻¹⁹ C', '+1.6 × 10¹⁹ C', '-1.6 × 10¹⁹ C', 'B', 'The charge of an electron is -1.6 × 10⁻¹⁹ coulombs.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the formula for electric power?', 'V = IR', 'P = IV', 'E = mc²', 'F = ma', 'B', 'Electric power is given by P = IV, where I is current and V is voltage.', 'medium' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the SI unit of frequency?', 'Hertz', 'Watt', 'Joule', 'Newton', 'A', 'Frequency is measured in Hertz (Hz), where 1 Hz = 1 cycle per second.', 'easy' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the mass of an electron?', '9.1 × 10⁻³¹ kg', '9.1 × 10⁻²⁷ kg', '1.67 × 10⁻²⁷ kg', '1.67 × 10⁻³¹ kg', 'A', 'The mass of an electron is approximately 9.1 × 10⁻³¹ kg.', 'hard' FROM subjects s WHERE s.name = 'Physics' LIMIT 1;

-- Chemistry questions (20+ questions)
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical symbol for water?', 'H₂O', 'CO₂', 'O₂', 'H₂', 'A', 'Water is composed of two hydrogen atoms and one oxygen atom, hence H₂O.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the pH of a neutral solution?', '0', '7', '14', '10', 'B', 'A neutral solution has a pH of 7. Values below 7 are acidic, above 7 are basic.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the atomic number of carbon?', '4', '6', '12', '14', 'B', 'Carbon has an atomic number of 6, meaning it has 6 protons.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical symbol for sodium?', 'S', 'Na', 'So', 'Sa', 'B', 'Sodium is represented by Na, derived from the Latin word "natrium".', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is Avogadro''s number?', '6.02 × 10²²', '6.02 × 10²³', '6.02 × 10²⁴', '6.02 × 10²¹', 'B', 'Avogadro''s number is 6.02 × 10²³, representing the number of particles in one mole.', 'medium' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for table salt?', 'NaCl', 'Na₂Cl', 'NaCl₂', 'Na₂Cl₂', 'A', 'Table salt is sodium chloride, with the formula NaCl.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for carbon dioxide?', 'CO', 'CO₂', 'C₂O', 'C₂O₂', 'B', 'Carbon dioxide consists of one carbon atom and two oxygen atoms: CO₂.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the atomic number of oxygen?', '6', '8', '16', '18', 'B', 'Oxygen has an atomic number of 8, meaning it has 8 protons.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the pH range for acids?', '0-7', '7-14', '0-14', '7', 'A', 'Acids have a pH less than 7, with lower values being more acidic.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the pH range for bases?', '0-7', '7-14', '0-14', '7', 'B', 'Bases have a pH greater than 7, with higher values being more basic.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical symbol for gold?', 'Go', 'Gd', 'Au', 'Ag', 'C', 'Gold is represented by Au, derived from the Latin word "aurum".', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical symbol for silver?', 'Si', 'Sv', 'Ag', 'Au', 'C', 'Silver is represented by Ag, derived from the Latin word "argentum".', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for methane?', 'CH₄', 'C₂H₆', 'CH₃', 'C₂H₄', 'A', 'Methane is CH₄, consisting of one carbon atom and four hydrogen atoms.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the atomic number of hydrogen?', '0', '1', '2', '3', 'B', 'Hydrogen has an atomic number of 1, making it the simplest element.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for ammonia?', 'NH₃', 'NH₄', 'N₂H₃', 'NH₂', 'A', 'Ammonia is NH₃, consisting of one nitrogen atom and three hydrogen atoms.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for sulfuric acid?', 'H₂SO₄', 'H₂SO₃', 'HSO₄', 'H₃SO₄', 'A', 'Sulfuric acid is H₂SO₄, a strong acid commonly used in industry.', 'medium' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for glucose?', 'C₆H₁₂O₆', 'C₆H₁₀O₆', 'C₅H₁₂O₆', 'C₆H₁₂O₅', 'A', 'Glucose is C₆H₁₂O₆, a simple sugar and important energy source.', 'medium' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the atomic number of nitrogen?', '5', '6', '7', '8', 'C', 'Nitrogen has an atomic number of 7, meaning it has 7 protons.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for hydrochloric acid?', 'HCl', 'H₂Cl', 'HCl₂', 'H₃Cl', 'A', 'Hydrochloric acid is HCl, a strong acid found in the stomach.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for calcium carbonate?', 'CaCO₃', 'Ca₂CO₃', 'CaCO₂', 'Ca₂CO₂', 'A', 'Calcium carbonate is CaCO₃, found in limestone and shells.', 'medium' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the atomic number of helium?', '1', '2', '3', '4', 'B', 'Helium has an atomic number of 2, making it the second lightest element.', 'easy' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for ethanol?', 'C₂H₅OH', 'CH₃OH', 'C₃H₇OH', 'C₂H₆O', 'A', 'Ethanol is C₂H₅OH, the alcohol found in alcoholic beverages.', 'medium' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the atomic number of iron?', '24', '25', '26', '27', 'C', 'Iron has an atomic number of 26, making it an important transition metal.', 'medium' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the chemical formula for nitric acid?', 'HNO₃', 'HNO₂', 'H₂NO₃', 'HNO₄', 'A', 'Nitric acid is HNO₃, a strong oxidizing acid.', 'medium' FROM subjects s WHERE s.name = 'Chemistry' LIMIT 1;

-- Biology questions (20+ questions)
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the powerhouse of the cell?', 'Nucleus', 'Mitochondria', 'Ribosome', 'Golgi apparatus', 'B', 'Mitochondria are known as the powerhouse of the cell because they produce ATP through cellular respiration.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'How many chromosomes do humans have?', '23', '46', '44', '48', 'B', 'Humans have 46 chromosomes (23 pairs) in each somatic cell.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the basic unit of life?', 'Tissue', 'Cell', 'Organ', 'Organ system', 'B', 'The cell is the basic structural and functional unit of all living organisms.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the process by which plants make food?', 'Respiration', 'Photosynthesis', 'Digestion', 'Excretion', 'B', 'Photosynthesis is the process by which plants convert light energy into chemical energy (glucose).', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the main product of photosynthesis?', 'Oxygen', 'Carbon dioxide', 'Water', 'Nitrogen', 'A', 'Oxygen is released as a byproduct of photosynthesis, while glucose is the main product stored.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the largest organ in the human body?', 'Liver', 'Lungs', 'Skin', 'Intestines', 'C', 'The skin is the largest organ in the human body, covering the entire external surface.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the smallest unit of DNA?', 'Gene', 'Chromosome', 'Nucleotide', 'Base pair', 'C', 'A nucleotide is the smallest unit of DNA, consisting of a sugar, phosphate, and base.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What are the four bases in DNA?', 'A, T, G, C', 'A, U, G, C', 'A, T, G, U', 'T, U, G, C', 'A', 'DNA contains adenine (A), thymine (T), guanine (G), and cytosine (C).', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of red blood cells?', 'Fight infection', 'Carry oxygen', 'Clot blood', 'Produce antibodies', 'B', 'Red blood cells contain hemoglobin and transport oxygen from the lungs to body tissues.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the process of cell division?', 'Mitosis', 'Meiosis', 'Both A and B', 'None of the above', 'C', 'Cell division occurs through mitosis (somatic cells) and meiosis (gametes).', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of white blood cells?', 'Carry oxygen', 'Fight infection', 'Clot blood', 'Transport nutrients', 'B', 'White blood cells are part of the immune system and help fight infections and diseases.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the largest part of the brain?', 'Cerebellum', 'Brainstem', 'Cerebrum', 'Medulla', 'C', 'The cerebrum is the largest part of the brain, responsible for higher functions like thinking and memory.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the process by which cells break down glucose to release energy?', 'Photosynthesis', 'Respiration', 'Digestion', 'Excretion', 'B', 'Cellular respiration breaks down glucose to produce ATP (energy) for the cell.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the heart?', 'Pump blood', 'Filter blood', 'Store blood', 'Produce blood', 'A', 'The heart pumps blood throughout the body, delivering oxygen and nutrients to tissues.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the basic unit of heredity?', 'Chromosome', 'Gene', 'DNA', 'Nucleotide', 'B', 'A gene is the basic unit of heredity, containing instructions for making proteins.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the kidneys?', 'Pump blood', 'Filter waste', 'Digest food', 'Produce hormones', 'B', 'The kidneys filter waste products from the blood and produce urine.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the process by which plants lose water through leaves?', 'Transpiration', 'Respiration', 'Photosynthesis', 'Osmosis', 'A', 'Transpiration is the process by which water evaporates from plant leaves through stomata.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the ribosomes?', 'Store DNA', 'Produce proteins', 'Generate energy', 'Control cell division', 'B', 'Ribosomes are responsible for protein synthesis, reading mRNA and assembling amino acids.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the liver?', 'Pump blood', 'Filter blood and produce bile', 'Digest food', 'Produce insulin', 'B', 'The liver filters blood, produces bile for digestion, and performs many metabolic functions.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the process by which organisms maintain a stable internal environment?', 'Homeostasis', 'Metabolism', 'Respiration', 'Reproduction', 'A', 'Homeostasis is the process by which organisms maintain a stable internal environment despite external changes.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the pancreas?', 'Pump blood', 'Filter waste', 'Produce insulin and digestive enzymes', 'Store bile', 'C', 'The pancreas produces insulin to regulate blood sugar and enzymes for digestion.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the lungs?', 'Pump blood', 'Exchange gases', 'Digest food', 'Filter waste', 'B', 'The lungs exchange oxygen and carbon dioxide between the blood and the atmosphere.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the nervous system?', 'Transport nutrients', 'Coordinate body activities', 'Produce hormones', 'Filter blood', 'B', 'The nervous system coordinates body activities through electrical signals and responses.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the function of the skeletal system?', 'Produce blood cells', 'Support and protect', 'Generate energy', 'Filter waste', 'B', 'The skeletal system provides support, protection, and enables movement through muscle attachment.', 'easy' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;
INSERT INTO questions (subject_id, question_text, option_a, option_b, option_c, option_d, correct_answer, explanation, difficulty_level)
SELECT s.id, 'What is the process by which DNA is copied?', 'Transcription', 'Translation', 'Replication', 'Mutation', 'C', 'DNA replication is the process by which DNA makes a copy of itself before cell division.', 'medium' FROM subjects s WHERE s.name = 'Biology' LIMIT 1;

