import { supabase } from './supabase'

export const notificationsService = {
  async getNotifications(userId) {
    try {
      const { data, error } = await supabase
        .from('notifications')
        .select('*')
        .eq('user_id', userId)
        .order('created_at', { ascending: false })
        .limit(50)

      if (error) throw error

      return { success: true, data: data || [] }
    } catch (error) {
      console.error('Error getting notifications:', error)
      return { success: false, error: error.message, data: [] }
    }
  },

  async markAsRead(notificationId) {
    try {
      const { error } = await supabase
        .from('notifications')
        .update({ read: true, read_at: new Date().toISOString() })
        .eq('id', notificationId)

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Error marking notification as read:', error)
      return { success: false, error: error.message }
    }
  },

  async markAllAsRead(userId) {
    try {
      const { error } = await supabase
        .from('notifications')
        .update({ read: true, read_at: new Date().toISOString() })
        .eq('user_id', userId)
        .eq('read', false)

      if (error) throw error

      return { success: true }
    } catch (error) {
      console.error('Error marking all as read:', error)
      return { success: false, error: error.message }
    }
  },

  async createNotification(userId, type, title, message, icon = '🔔') {
    try {
      const { data, error } = await supabase
        .from('notifications')
        .insert({
          user_id: userId,
          type,
          title,
          message,
          icon,
          read: false
        })
        .select()
        .single()

      if (error) throw error

      return { success: true, data }
    } catch (error) {
      console.error('Error creating notification:', error)
      return { success: false, error: error.message }
    }
  }
}

