import { supabase } from './supabase'

export const studyPlansService = {
  async getStudyPlans(userId) {
    try {
      const { data, error } = await supabase
        .from('study_plans')
        .select(`
          *,
          subjects (name)
        `)
        .eq('user_id', userId)
        .order('created_at', { ascending: false })

      if (error) throw error

      // Calculate progress for each plan
      const plansWithProgress = await Promise.all(
        (data || []).map(async (plan) => {
          const progress = await this.calculateProgress(userId, plan)
          return {
            ...plan,
            subject_name: plan.subjects?.name || 'Unknown',
            progress: progress
          }
        })
      )

      return { success: true, data: plansWithProgress }
    } catch (error) {
      console.error('Error getting study plans:', error)
      return { success: false, error: error.message, data: [] }
    }
  },

  async calculateProgress(userId, plan) {
    try {
      // Get practice data for this subject and date range
      const { data } = await supabase
        .from('daily_practice')
        .select('questions_attempted, practice_date')
        .eq('user_id', userId)
        .eq('subject_id', plan.subject_id)
        .gte('practice_date', plan.start_date)
        .lte('practice_date', plan.end_date)

      if (!data || data.length === 0) return 0

      const totalDays = Math.ceil(
        (new Date(plan.end_date) - new Date(plan.start_date)) / (1000 * 60 * 60 * 24)
      )
      const expectedQuestions = totalDays * plan.daily_goal
      const actualQuestions = data.reduce((sum, day) => sum + day.questions_attempted, 0)

      return Math.min(100, Math.round((actualQuestions / expectedQuestions) * 100))
    } catch (error) {
      console.error('Error calculating progress:', error)
      return 0
    }
  },

  async createStudyPlan(planData) {
    try {
      const { data, error } = await supabase
        .from('study_plans')
        .insert({
          user_id: planData.user_id,
          subject_id: planData.subject_id,
          title: planData.title,
          description: planData.description || null,
          start_date: planData.start_date,
          end_date: planData.end_date,
          daily_goal: planData.daily_goal
        })
        .select()
        .single()

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error creating study plan:', error)
      return { success: false, error: error.message }
    }
  },

  async deleteStudyPlan(planId) {
    try {
      const { error } = await supabase
        .from('study_plans')
        .delete()
        .eq('id', planId)

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Error deleting study plan:', error)
      return { success: false, error: error.message }
    }
  }
}

