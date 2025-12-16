import { supabase } from './supabase'

export const quizService = {
  async getSubjects() {
    const { data, error } = await supabase
      .from('subjects')
      .select('*')
      .order('name')
    return { data, error }
  },

  async getRandomQuestions(subjectId, count) {
    const { data, error } = await supabase
      .from('questions')
      .select('*')
      .eq('subject_id', subjectId)
      .limit(1000) // Get more than needed, then randomize

    if (error) return { data: null, error }

    // Shuffle and take requested count
    const shuffled = data.sort(() => 0.5 - Math.random())
    const selected = shuffled.slice(0, count)

    return { data: selected, error: null }
  },

  async createQuizAttempt(userId, subjectId, totalQuestions) {
    const { data, error } = await supabase
      .from('quiz_attempts')
      .insert({
        user_id: userId,
        subject_id: subjectId,
        total_questions: totalQuestions,
        correct_answers: 0,
        score: 0,
        started_at: new Date().toISOString()
      })
      .select()
      .single()

    return { data, error }
  },

  async saveQuizResponse(quizAttemptId, questionId, selectedAnswer, isCorrect) {
    const { data, error } = await supabase
      .from('quiz_responses')
      .insert({
        quiz_attempt_id: quizAttemptId,
        question_id: questionId,
        selected_answer: selectedAnswer,
        is_correct: isCorrect,
        answered_at: new Date().toISOString()
      })

    return { data, error }
  },

  async completeQuizAttempt(quizAttemptId, correctAnswers, score) {
    const { data, error } = await supabase
      .from('quiz_attempts')
      .update({
        correct_answers: correctAnswers,
        score: score,
        completed_at: new Date().toISOString()
      })
      .eq('id', quizAttemptId)
      .select()
      .single()

    return { data, error }
  },

  async updateDailyPractice(userId, subjectId, questionsAttempted, averageScore) {
    const today = new Date().toISOString().split('T')[0]
    
    // Check if record exists for today
    const { data: existing } = await supabase
      .from('daily_practice')
      .select('*')
      .eq('user_id', userId)
      .eq('subject_id', subjectId)
      .eq('practice_date', today)
      .single()

    if (existing) {
      // Update existing record
      const { data, error } = await supabase
        .from('daily_practice')
        .update({
          questions_attempted: existing.questions_attempted + questionsAttempted,
          average_score: (existing.average_score * existing.questions_attempted + averageScore * questionsAttempted) / 
                        (existing.questions_attempted + questionsAttempted)
        })
        .eq('id', existing.id)
        .select()
        .single()

      return { data, error }
    } else {
      // Create new record
      const { data, error } = await supabase
        .from('daily_practice')
        .insert({
          user_id: userId,
          subject_id: subjectId,
          practice_date: today,
          questions_attempted: questionsAttempted,
          average_score: averageScore
        })
        .select()
        .single()

      return { data, error }
    }
  },

  async getUserQuizHistory(userId, subjectId = null) {
    let query = supabase
      .from('quiz_attempts')
      .select(`
        *,
        subjects (name)
      `)
      .eq('user_id', userId)
      .order('completed_at', { ascending: false })

    if (subjectId) {
      query = query.eq('subject_id', subjectId)
    }

    const { data, error } = await query
    return { data, error }
  }
}

