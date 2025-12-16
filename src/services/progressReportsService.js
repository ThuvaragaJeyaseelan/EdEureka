import { supabase } from './supabase'

export const progressReportsService = {
  async generateReport(userId, subjectId = null, period = 'month') {
    try {
      // Calculate date range
      const endDate = new Date()
      const startDate = new Date()
      
      switch (period) {
        case 'week':
          startDate.setDate(endDate.getDate() - 7)
          break
        case 'month':
          startDate.setMonth(endDate.getMonth() - 1)
          break
        case '3months':
          startDate.setMonth(endDate.getMonth() - 3)
          break
        case 'all':
          startDate.setFullYear(2020) // Far back date
          break
      }

      // Get quiz attempts
      let query = supabase
        .from('quiz_attempts')
        .select(`
          *,
          subjects (name)
        `)
        .eq('user_id', userId)
        .not('completed_at', 'is', null)
        .gte('completed_at', startDate.toISOString())
        .lte('completed_at', endDate.toISOString())

      if (subjectId) {
        query = query.eq('subject_id', subjectId)
      }

      const { data: attempts, error: attemptsError } = await query
      if (attemptsError) throw attemptsError

      // Get daily practice for streak calculation
      const { data: dailyPractice } = await supabase
        .from('daily_practice')
        .select('practice_date')
        .eq('user_id', userId)
        .order('practice_date', { ascending: false })

      // Calculate streak
      let streak = 0
      if (dailyPractice && dailyPractice.length > 0) {
        const today = new Date().toISOString().split('T')[0]
        let checkDate = new Date(today)
        
        for (const practice of dailyPractice) {
          const practiceDate = practice.practice_date
          const checkDateStr = checkDate.toISOString().split('T')[0]
          
          if (practiceDate === checkDateStr) {
            streak++
            checkDate.setDate(checkDate.getDate() - 1)
          } else {
            break
          }
        }
      }

      // Calculate totals
      const totalQuizzes = attempts?.length || 0
      const totalQuestions = attempts?.reduce((sum, a) => sum + a.total_questions, 0) || 0
      const totalScore = attempts?.reduce((sum, a) => sum + a.score, 0) || 0
      const averageScore = totalQuizzes > 0 ? totalScore / totalQuizzes : 0

      // Group by subject
      const subjectMap = {}
      attempts?.forEach(attempt => {
        const subjId = attempt.subject_id
        const subjName = attempt.subjects?.name || 'Unknown'
        
        if (!subjectMap[subjId]) {
          subjectMap[subjId] = {
            id: subjId,
            name: subjName,
            quizzes: 0,
            questions: 0,
            totalScore: 0,
            mistakes: 0
          }
        }
        
        subjectMap[subjId].quizzes++
        subjectMap[subjId].questions += attempt.total_questions
        subjectMap[subjId].totalScore += attempt.score
        subjectMap[subjId].mistakes += (attempt.total_questions - attempt.correct_answers)
      })

      // Get mistakes count
      if (attempts && attempts.length > 0) {
        const attemptIds = attempts.map(a => a.id)
        const { data: responses } = await supabase
          .from('quiz_responses')
          .select('quiz_attempt_id, is_correct')
          .in('quiz_attempt_id', attemptIds)
          .eq('is_correct', false)

        // Count mistakes per subject
        responses?.forEach(response => {
          const attempt = attempts.find(a => a.id === response.quiz_attempt_id)
          if (attempt && subjectMap[attempt.subject_id]) {
            // Already counted above
          }
        })
      }

      const subjectBreakdown = Object.values(subjectMap).map(subj => ({
        ...subj,
        averageScore: subj.quizzes > 0 ? subj.totalScore / subj.quizzes : 0
      }))

      // Recent activity (last 10 quizzes)
      const recentActivity = (attempts || [])
        .slice(0, 10)
        .map(attempt => ({
          id: attempt.id,
          subject_name: attempt.subjects?.name || 'Unknown',
          date: attempt.completed_at,
          score: attempt.score,
          questions: attempt.total_questions
        }))

      return {
        success: true,
        data: {
          totalQuizzes,
          totalQuestions,
          averageScore,
          studyStreak: streak,
          subjectBreakdown,
          recentActivity
        }
      }
    } catch (error) {
      console.error('Error generating report:', error)
      return { success: false, error: error.message }
    }
  }
}

