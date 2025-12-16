import { supabase } from './supabase'

export const analyticsService = {
  // Get all mistakes (incorrect answers) for a user and subject
  async getMistakes(userId, subjectId, filterBy = 'all', sortBy = 'recent') {
    try {
      // Get all quiz attempts for this user and subject
      const { data: attempts, error: attemptsError } = await supabase
        .from('quiz_attempts')
        .select('id')
        .eq('user_id', userId)
        .eq('subject_id', subjectId)
        .not('completed_at', 'is', null)

      if (attemptsError) throw attemptsError

      if (!attempts || attempts.length === 0) {
        return { success: true, data: [] }
      }

      const attemptIds = attempts.map(a => a.id)

      // Get all incorrect responses with question details
      let query = supabase
        .from('quiz_responses')
        .select(`
          *,
          questions (
            id,
            question_text,
            option_a,
            option_b,
            option_c,
            option_d,
            correct_answer,
            explanation,
            difficulty_level
          ),
          quiz_attempts!inner (
            completed_at
          )
        `)
        .eq('is_correct', false)
        .in('quiz_attempt_id', attemptIds)

      // Apply date filter
      if (filterBy === 'recent') {
        const sevenDaysAgo = new Date()
        sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7)
        query = query.gte('answered_at', sevenDaysAgo.toISOString())
      }

      const { data: responses, error: responsesError } = await query

      if (responsesError) throw responsesError

      if (!responses || responses.length === 0) {
        return { success: true, data: [] }
      }

      // Group mistakes by question_id
      const mistakeMap = {}
      
      for (const response of responses) {
        const questionId = response.question_id
        const question = response.questions

        if (!question) continue

        if (!mistakeMap[questionId]) {
          mistakeMap[questionId] = {
            question_id: questionId,
            question_text: question.question_text,
            option_a: question.option_a,
            option_b: question.option_b,
            option_c: question.option_c,
            option_d: question.option_d,
            correct_answer: question.correct_answer,
            explanation: question.explanation,
            difficulty_level: question.difficulty_level,
            timesWrong: 0,
            wrongAnswers: [],
            attemptDates: [],
            lastAttempted: null,
            totalAttempts: 0
          }
        }

        mistakeMap[questionId].timesWrong++
        mistakeMap[questionId].wrongAnswers.push(response.selected_answer)
        
        if (response.answered_at) {
          mistakeMap[questionId].attemptDates.push(response.answered_at)
          const attemptDate = new Date(response.answered_at)
          const lastAttempted = mistakeMap[questionId].lastAttempted
          if (!lastAttempted || attemptDate > new Date(lastAttempted)) {
            mistakeMap[questionId].lastAttempted = response.answered_at
          }
        }
      }

      // Get total attempts for each question to calculate mistake rate
      const questionIds = Object.keys(mistakeMap)
      if (questionIds.length > 0) {
        const { data: allResponses } = await supabase
          .from('quiz_responses')
          .select('question_id')
          .in('quiz_attempt_id', attemptIds)
          .in('question_id', questionIds)

        if (allResponses) {
          const questionAttemptCounts = {}
          allResponses.forEach(r => {
            questionAttemptCounts[r.question_id] = (questionAttemptCounts[r.question_id] || 0) + 1
          })

          Object.keys(mistakeMap).forEach(qId => {
            mistakeMap[qId].totalAttempts = questionAttemptCounts[qId] || mistakeMap[qId].timesWrong
          })
        }
      }

      // Convert to array and process
      let mistakes = Object.values(mistakeMap).map(mistake => {
        // Get most common wrong answer
        const wrongAnswerCounts = {}
        mistake.wrongAnswers.forEach(ans => {
          wrongAnswerCounts[ans] = (wrongAnswerCounts[ans] || 0) + 1
        })
        const mostCommonWrong = Object.entries(wrongAnswerCounts)
          .sort((a, b) => b[1] - a[1])[0]?.[0] || mistake.wrongAnswers[0] || ''

        return {
          ...mistake,
          wrongAnswer: mostCommonWrong
        }
      })

      // Apply sorting
      if (sortBy === 'frequent') {
        mistakes = mistakes.sort((a, b) => b.timesWrong - a.timesWrong)
      } else if (sortBy === 'difficulty') {
        const difficultyOrder = { 'hard': 3, 'medium': 2, 'easy': 1 }
        mistakes = mistakes.sort((a, b) => 
          (difficultyOrder[b.difficulty_level] || 0) - (difficultyOrder[a.difficulty_level] || 0)
        )
      } else {
        // Recent (default)
        mistakes = mistakes.sort((a, b) => {
          const dateA = a.lastAttempted ? new Date(a.lastAttempted) : new Date(0)
          const dateB = b.lastAttempted ? new Date(b.lastAttempted) : new Date(0)
          return dateB - dateA
        })
      }

      // Apply frequency filter
      if (filterBy === 'frequent') {
        mistakes = mistakes.filter(m => m.timesWrong > 1)
        mistakes = mistakes.sort((a, b) => b.timesWrong - a.timesWrong)
      }

      return { success: true, data: mistakes }
    } catch (error) {
      console.error('Error getting mistakes:', error)
      return { success: false, error: error.message, data: [] }
    }
  },

  // Get mistake analytics
  async getMistakeAnalytics(userId, subjectId = null) {
    try {
      let query = supabase
        .from('quiz_attempts')
        .select('id, subject_id')
        .eq('user_id', userId)
        .not('completed_at', 'is', null)

      if (subjectId) {
        query = query.eq('subject_id', subjectId)
      }

      const { data: attempts, error } = await query
      if (error) throw error

      if (!attempts || attempts.length === 0) {
        return { success: true, data: { totalMistakes: 0, mistakeRate: 0, bySubject: {} } }
      }

      const attemptIds = attempts.map(a => a.id)

      const { data: responses, error: responsesError } = await supabase
        .from('quiz_responses')
        .select('is_correct, quiz_attempts!inner(subject_id)')
        .in('quiz_attempt_id', attemptIds)

      if (responsesError) throw responsesError

      const totalResponses = responses.length
      const incorrectResponses = responses.filter(r => !r.is_correct).length
      const mistakeRate = totalResponses > 0 ? (incorrectResponses / totalResponses) * 100 : 0

      // Group by subject
      const bySubject = {}
      responses.forEach(response => {
        const subjId = response.quiz_attempts?.subject_id
        if (!subjId) return

        if (!bySubject[subjId]) {
          bySubject[subjId] = { total: 0, incorrect: 0 }
        }
        bySubject[subjId].total++
        if (!response.is_correct) {
          bySubject[subjId].incorrect++
        }
      })

      return {
        success: true,
        data: {
          totalMistakes: incorrectResponses,
          mistakeRate: Math.round(mistakeRate * 100) / 100,
          bySubject
        }
      }
    } catch (error) {
      console.error('Error getting mistake analytics:', error)
      return { success: false, error: error.message }
    }
  }
}

