import { defineStore } from 'pinia'
import { ref, computed } from 'vue'
import { authService } from '../services/supabase'
import router from '../router'

export const useAuthStore = defineStore('auth', () => {
  const user = ref(null)
  const session = ref(null)
  const loading = ref(false)

  const isAuthenticated = computed(() => !!user.value)

  async function initialize() {
    loading.value = true
    try {
      const currentSession = await authService.getSession()
      session.value = currentSession
      user.value = currentSession?.user || null
    } catch (error) {
      console.error('Auth initialization error:', error)
    } finally {
      loading.value = false
    }
  }

  async function signUp(email, password, name) {
    loading.value = true
    try {
      const { data, error } = await authService.signUp(email, password, name)
      if (error) throw error
      
      session.value = data.session
      user.value = data.user
      return { success: true, error: null }
    } catch (error) {
      console.error('Sign up error:', error)
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  async function signIn(email, password) {
    loading.value = true
    try {
      const { data, error } = await authService.signIn(email, password)
      if (error) throw error
      
      session.value = data.session
      user.value = data.user
      return { success: true, error: null }
    } catch (error) {
      console.error('Sign in error:', error)
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  async function signOut() {
    loading.value = true
    try {
      const { error } = await authService.signOut()
      if (error) throw error
      
      user.value = null
      session.value = null
      router.push('/')
      return { success: true, error: null }
    } catch (error) {
      console.error('Sign out error:', error)
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  function setUser(userData) {
    user.value = userData
  }

  function setSession(sessionData) {
    session.value = sessionData
  }

  return {
    user,
    session,
    loading,
    isAuthenticated,
    initialize,
    signUp,
    signIn,
    signOut,
    setUser,
    setSession
  }
})

