<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-cyan-50">
    <!-- Navbar -->
    <nav class="bg-white shadow-xl border-b border-gray-200">
      <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div class="flex justify-between h-16">
          <div class="flex items-center space-x-6">
            <router-link to="/dashboard" class="text-2xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
              Ed-Eureka
            </router-link>
            <button
              @click="goBack"
              class="text-gray-600 hover:text-purple-600 transition font-medium"
            >
              ← Back
            </button>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <!-- Question Selection Phase -->
      <div v-if="phase === 'selection'" class="bg-white rounded-2xl shadow-xl p-8 border border-gray-100">
        <h2 class="text-3xl font-bold mb-2 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">Select Number of Questions</h2>
        <p class="text-gray-600 mb-6">Choose how many questions you want to practice</p>
        
        <div class="grid grid-cols-2 md:grid-cols-4 gap-4 mb-6">
          <button
            v-for="count in [5, 10, 15, 20]"
            :key="count"
            @click="selectedQuestionCount = count"
            class="p-6 border-2 rounded-xl transition-all transform hover:scale-105"
            :class="{
              'border-purple-500 bg-gradient-to-br from-purple-50 to-blue-50 shadow-md': selectedQuestionCount === count,
              'border-gray-200 hover:border-purple-300 hover:bg-purple-50': selectedQuestionCount !== count
            }"
          >
            <div class="text-3xl font-bold text-gray-800">{{ count }}</div>
            <div class="text-sm text-gray-600 mt-1">Questions</div>
          </button>
        </div>

        <button
          @click="startQuiz"
          :disabled="!selectedQuestionCount || loading"
          class="w-full px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 disabled:opacity-50 disabled:cursor-not-allowed transition shadow-lg font-semibold"
        >
          <span v-if="loading">Loading questions...</span>
          <span v-else>Start Quiz</span>
        </button>
      </div>

      <!-- Quiz Phase -->
      <div v-else-if="phase === 'quiz'">
        <QuestionCounter
          :current-question="currentQuestionIndex"
          :total-questions="quizStore.currentQuestions.length"
          :question-status="questionStatus"
        />

        <QuestionCard
          :question="quizStore.currentQuestions[currentQuestionIndex]"
          :initial-answer="quizStore.getAnswer(quizStore.currentQuestions[currentQuestionIndex]?.id)"
          @answer-selected="handleAnswerSelected"
        />

        <div class="flex justify-between mt-6">
          <button
            @click="previousQuestion"
            :disabled="currentQuestionIndex === 0"
            class="px-6 py-2 bg-gray-200 text-gray-700 rounded-xl hover:bg-gray-300 disabled:opacity-50 disabled:cursor-not-allowed transition font-medium"
          >
            ← Previous
          </button>
          
          <div class="flex space-x-4">
            <button
              @click="goBack"
              class="px-6 py-2 bg-gray-200 text-gray-700 rounded-xl hover:bg-gray-300 transition font-medium"
            >
              Cancel
            </button>
            <button
              @click="submitQuiz"
              :disabled="loading"
              class="px-6 py-2 bg-gradient-to-r from-green-500 to-emerald-600 text-white rounded-xl hover:from-green-600 hover:to-emerald-700 disabled:opacity-50 transition shadow-lg font-semibold"
            >
              Submit Quiz
            </button>
          </div>

          <button
            @click="nextQuestion"
            :disabled="currentQuestionIndex === quizStore.currentQuestions.length - 1"
            class="px-6 py-2 bg-gray-200 text-gray-700 rounded-xl hover:bg-gray-300 disabled:opacity-50 disabled:cursor-not-allowed transition font-medium"
          >
            Next →
          </button>
        </div>
      </div>

      <!-- Results Phase -->
      <div v-else-if="phase === 'results'">
        <QuizResults
          :score="quizResults.score"
          :correct="quizResults.correct"
          :total="quizResults.total"
          :results="quizResults.results"
          @retry-quiz="retryQuiz"
          @back-to-subject="handleBackToSubject"
        />
      </div>
    </main>
  </div>
</template>

<script setup>
import { ref, computed, onMounted } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useQuizStore } from '../stores/quiz'
import { useAnalyticsStore } from '../stores/analytics'
import QuestionCounter from '../components/quiz/QuestionCounter.vue'
import QuestionCard from '../components/quiz/QuestionCard.vue'
import QuizResults from '../components/quiz/QuizResults.vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const quizStore = useQuizStore()
const analyticsStore = useAnalyticsStore()

const subjectId = route.params.subjectId
const phase = ref('selection') // 'selection', 'quiz', 'results'
const selectedQuestionCount = ref(null)
const currentQuestionIndex = ref(0)
const quizResults = ref(null)

const loading = computed(() => quizStore.loading)

const questionStatus = computed(() => {
  return quizStore.currentQuestions.map((q, index) => {
    const answer = quizStore.getAnswer(q.id)
    if (index === currentQuestionIndex.value) return 'current'
    if (answer) return 'answered'
    return 'unanswered'
  })
})

onMounted(async () => {
  await authStore.initialize()
})

const startQuiz = async () => {
  if (!selectedQuestionCount.value || !authStore.user) return

  // Load questions
  const result = await quizStore.loadQuestions(subjectId, selectedQuestionCount.value)
  if (!result.success) {
    alert('Failed to load questions. Please try again.')
    return
  }

  // Start quiz attempt
  const attemptResult = await quizStore.startQuiz(
    authStore.user.id,
    subjectId,
    selectedQuestionCount.value
  )

  if (attemptResult.success) {
    phase.value = 'quiz'
    currentQuestionIndex.value = 0
  } else {
    alert('Failed to start quiz. Please try again.')
  }
}

const handleAnswerSelected = (answer) => {
  const question = quizStore.currentQuestions[currentQuestionIndex.value]
  quizStore.setAnswer(question.id, answer)
}

const nextQuestion = () => {
  if (currentQuestionIndex.value < quizStore.currentQuestions.length - 1) {
    currentQuestionIndex.value++
  }
}

const previousQuestion = () => {
  if (currentQuestionIndex.value > 0) {
    currentQuestionIndex.value--
  }
}

const submitQuiz = async () => {
  if (!confirm('Are you sure you want to submit? You cannot change your answers after submission.')) {
    return
  }

  const result = await quizStore.submitQuiz()
  
  if (result.success) {
    // Refresh analytics in real-time
    if (authStore.user) {
      await analyticsStore.loadDailyPractice(authStore.user.id)
      await analyticsStore.loadMistakeAnalytics(authStore.user.id)
    }
    
    // Prepare results for display
    quizResults.value = {
      score: result.data.score,
      correct: result.data.correct,
      total: result.data.total,
      results: quizStore.currentQuestions.map(question => {
        const selectedAnswer = quizStore.getAnswer(question.id) || ''
        const isCorrect = selectedAnswer === question.correct_answer
        
        return {
          question,
          selectedAnswer,
          isCorrect
        }
      })
    }
    
    phase.value = 'results'
  } else {
    alert('Failed to submit quiz: ' + (result.error || 'Unknown error'))
  }
}

const retryQuiz = () => {
  quizStore.resetQuiz()
  phase.value = 'selection'
  selectedQuestionCount.value = null
  currentQuestionIndex.value = 0
  quizResults.value = null
}

const backToSubject = async () => {
  // Refresh analytics before navigating back
  if (authStore.user) {
    await analyticsStore.loadDailyPractice(authStore.user.id)
    await analyticsStore.loadMistakeAnalytics(authStore.user.id)
  }
  router.push(`/subject/${subjectId}`)
}

const backToDashboard = async () => {
  // Refresh analytics before navigating to dashboard
  if (authStore.user) {
    await analyticsStore.loadDailyPractice(authStore.user.id)
    await analyticsStore.loadMistakeAnalytics(authStore.user.id)
  }
  router.push('/dashboard')
}

const goBack = () => {
  if (phase.value === 'selection') {
    router.push(`/subject/${subjectId}`)
  } else {
    phase.value = 'selection'
    quizStore.resetQuiz()
  }
}
</script>

