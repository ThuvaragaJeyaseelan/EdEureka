import { supabase } from './supabase'

export const achievementsService = {
  async getAchievements(userId) {
    try {
      // Get user's quiz data for achievement calculation
      const { data: attempts } = await supabase
        .from('quiz_attempts')
        .select('*')
        .eq('user_id', userId)
        .not('completed_at', 'is', null)

      const { data: dailyPractice } = await supabase
        .from('daily_practice')
        .select('*')
        .eq('user_id', userId)
        .order('practice_date', { ascending: false })

      // Define achievement criteria
      const totalQuizzes = attempts?.length || 0
      const totalQuestions = attempts?.reduce((sum, a) => sum + a.total_questions, 0) || 0
      const perfectScores = attempts?.filter(a => a.score === 100).length || 0
      const highScores = attempts?.filter(a => a.score >= 90).length || 0
      const practiceDays = dailyPractice?.length || 0
      
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

      // Define all achievements
      const allAchievements = [
        {
          id: 'first_quiz',
          name: 'First Steps',
          description: 'Complete your first quiz',
          icon: '🎯',
          unlocked: totalQuizzes >= 1,
          progress: Math.min(100, (totalQuizzes / 1) * 100),
          progressText: `${totalQuizzes}/1 quiz completed`
        },
        {
          id: 'quiz_master',
          name: 'Quiz Master',
          description: 'Complete 10 quizzes',
          icon: '🏆',
          unlocked: totalQuizzes >= 10,
          progress: Math.min(100, (totalQuizzes / 10) * 100),
          progressText: `${totalQuizzes}/10 quizzes completed`
        },
        {
          id: 'century',
          name: 'Century Club',
          description: 'Answer 100 questions',
          icon: '💯',
          unlocked: totalQuestions >= 100,
          progress: Math.min(100, (totalQuestions / 100) * 100),
          progressText: `${totalQuestions}/100 questions answered`
        },
        {
          id: 'perfect_score',
          name: 'Perfect Score',
          description: 'Get 100% on a quiz',
          icon: '⭐',
          unlocked: perfectScores >= 1,
          progress: Math.min(100, (perfectScores / 1) * 100),
          progressText: `${perfectScores}/1 perfect score`
        },
        {
          id: 'excellence',
          name: 'Excellence',
          description: 'Get 90% or above 5 times',
          icon: '🌟',
          unlocked: highScores >= 5,
          progress: Math.min(100, (highScores / 5) * 100),
          progressText: `${highScores}/5 high scores`
        },
        {
          id: 'dedicated',
          name: 'Dedicated Learner',
          description: 'Practice for 7 consecutive days',
          icon: '🔥',
          unlocked: streak >= 7,
          progress: Math.min(100, (streak / 7) * 100),
          progressText: `${streak}/7 day streak`
        },
        {
          id: 'monthly',
          name: 'Monthly Warrior',
          description: 'Practice for 30 days',
          icon: '📅',
          unlocked: practiceDays >= 30,
          progress: Math.min(100, (practiceDays / 30) * 100),
          progressText: `${practiceDays}/30 days practiced`
        },
        {
          id: 'all_subjects',
          name: 'Jack of All Trades',
          description: 'Practice all 4 subjects',
          icon: '🎓',
          unlocked: false, // Will calculate based on unique subjects
          progress: 0,
          progressText: 'Practice all subjects'
        }
      ]

      // Check all subjects achievement
      if (attempts && attempts.length > 0) {
        const uniqueSubjects = new Set(attempts.map(a => a.subject_id))
        const allSubjectsAchievement = allAchievements.find(a => a.id === 'all_subjects')
        if (allSubjectsAchievement) {
          allSubjectsAchievement.unlocked = uniqueSubjects.size >= 4
          allSubjectsAchievement.progress = Math.min(100, (uniqueSubjects.size / 4) * 100)
          allSubjectsAchievement.progressText = `${uniqueSubjects.size}/4 subjects practiced`
        }
      }

      // Add unlocked_at timestamp (simplified - using current date)
      const achievementsWithDates = allAchievements.map(achievement => ({
        ...achievement,
        unlocked_at: achievement.unlocked ? new Date().toISOString() : null
      }))

      return { success: true, data: achievementsWithDates }
    } catch (error) {
      console.error('Error getting achievements:', error)
      return { success: false, error: error.message, data: [] }
    }
  }
}

