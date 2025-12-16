import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '../stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'Home',
      component: () => import('../views/Home.vue')
    },
    {
      path: '/login',
      name: 'Login',
      component: () => import('../views/Login.vue'),
      meta: { requiresGuest: true }
    },
    {
      path: '/signup',
      name: 'Signup',
      component: () => import('../views/Signup.vue'),
      meta: { requiresGuest: true }
    },
    {
      path: '/dashboard',
      name: 'Dashboard',
      component: () => import('../views/Dashboard.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/subject/:subjectId',
      name: 'SubjectPage',
      component: () => import('../views/SubjectPage.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/quiz/:subjectId',
      name: 'QuizPage',
      component: () => import('../views/QuizPage.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/study-notes/:subjectId',
      name: 'StudyNotes',
      component: () => import('../views/StudyNotes.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/study-plans',
      name: 'StudyPlans',
      component: () => import('../views/StudyPlans.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/progress-reports',
      name: 'ProgressReports',
      component: () => import('../views/ProgressReports.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/achievements',
      name: 'Achievements',
      component: () => import('../views/Achievements.vue'),
      meta: { requiresAuth: true }
    },
    {
      path: '/notifications',
      name: 'Notifications',
      component: () => import('../views/Notifications.vue'),
      meta: { requiresAuth: true }
    }
  ]
})

// Navigation guards
router.beforeEach(async (to, from, next) => {
  const authStore = useAuthStore()

  // Initialize auth if not already done
  if (!authStore.user && !authStore.loading) {
    await authStore.initialize()
  }

  const requiresAuth = to.matched.some(record => record.meta.requiresAuth)
  const requiresGuest = to.matched.some(record => record.meta.requiresGuest)

  if (requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'Login', query: { redirect: to.fullPath } })
  } else if (requiresGuest && authStore.isAuthenticated) {
    next({ name: 'Dashboard' })
  } else {
    next()
  }
})

export default router

