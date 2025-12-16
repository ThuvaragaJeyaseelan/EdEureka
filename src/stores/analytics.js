import { defineStore } from 'pinia'
import { ref } from 'vue'
import { supabase } from '../services/supabase'
import { analyticsService } from '../services/analyticsService'

export const useAnalyticsStore = defineStore('analytics', () => {
  const dailyPractice = ref([])
  const leaderboard = ref([])
  const mistakeAnalytics = ref(null)
  const loading = ref(false)

  async function loadDailyPractice(userId, subjectId = null) {
    loading.value = true
    try {
      let query = supabase
        .from('daily_practice')
        .select(`
          *,
          subjects (name)
        `)
        .eq('user_id', userId)
        .order('practice_date', { ascending: false })
        .limit(30) // Last 30 days

      if (subjectId) {
        query = query.eq('subject_id', subjectId)
      }

      const { data, error } = await query
      if (error) throw error

      dailyPractice.value = data || []
    } catch (error) {
      console.error('Error loading daily practice:', error)
    } finally {
      loading.value = false
    }
  }

  async function loadLeaderboard(subjectId = null) {
    loading.value = true
    try {
      // Get top performers based on average scores
      let query = supabase
        .from('quiz_attempts')
        .select(`
          user_id,
          subject_id,
          score,
          completed_at,
          subjects (name)
        `)
        .not('completed_at', 'is', null)
        .order('score', { ascending: false })
        .limit(100) // Get more to calculate averages

      if (subjectId) {
        query = query.eq('subject_id', subjectId)
      }

      const { data, error } = await query
      if (error) throw error

      // Group by user and calculate averages
      const userScores = {}
      data.forEach(attempt => {
        const userId = attempt.user_id
        if (!userScores[userId]) {
          userScores[userId] = {
            user_id: userId,
            name: `User ${userId.substring(0, 8)}`, // Use partial UUID as identifier
            scores: [],
            subject: attempt.subjects?.name || 'All Subjects'
          }
        }
        userScores[userId].scores.push(attempt.score)
      })

      // Calculate averages and sort
      leaderboard.value = Object.values(userScores)
        .map(user => ({
          ...user,
          averageScore: user.scores.reduce((a, b) => a + b, 0) / user.scores.length,
          totalAttempts: user.scores.length
        }))
        .sort((a, b) => b.averageScore - a.averageScore)
        .slice(0, 10)
    } catch (error) {
      console.error('Error loading leaderboard:', error)
      leaderboard.value = []
    } finally {
      loading.value = false
    }
  }

  async function loadMistakeAnalytics(userId, subjectId = null) {
    loading.value = true
    try {
      const result = await analyticsService.getMistakeAnalytics(userId, subjectId)
      if (result.success) {
        mistakeAnalytics.value = result.data
      } else {
        console.error('Error loading mistake analytics:', result.error)
        mistakeAnalytics.value = null
      }
    } catch (error) {
      console.error('Error loading mistake analytics:', error)
      mistakeAnalytics.value = null
    } finally {
      loading.value = false
    }
  }

  return {
    dailyPractice,
    leaderboard,
    mistakeAnalytics,
    loading,
    loadDailyPractice,
    loadLeaderboard,
    loadMistakeAnalytics
  }
})

