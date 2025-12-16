import { createApp } from 'vue'
import { createPinia } from 'pinia'
import router from './router'
import './style.css'
import App from './App.vue'
import { useAuthStore } from './stores/auth'
import { authService } from './services/supabase'

const app = createApp(App)
const pinia = createPinia()

app.use(pinia)
app.use(router)

// Initialize auth state listener
authService.onAuthStateChange((event, session) => {
  const authStore = useAuthStore()
  if (event === 'SIGNED_IN' || event === 'TOKEN_REFRESHED') {
    authStore.setSession(session)
    authStore.setUser(session?.user || null)
  } else if (event === 'SIGNED_OUT') {
    authStore.setSession(null)
    authStore.setUser(null)
  }
})

app.mount('#app')
