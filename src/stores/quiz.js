import { defineStore } from 'pinia'
import { ref } from 'vue'
import { quizService } from '../services/quizService'

export const useQuizStore = defineStore('quiz', () => {
  const subjects = ref([])
  const currentQuestions = ref([])
  const currentQuizAttempt = ref(null)
  const userAnswers = ref({})
  const loading = ref(false)

  async function loadSubjects() {
    loading.value = true
    try {
      const { data, error } = await quizService.getSubjects()
      if (error) {
        console.error('Error loading subjects:', error)
        throw new Error(error.message || 'Failed to load subjects from database')
      }
      subjects.value = data || []
      if (!data || data.length === 0) {
        console.warn('No subjects found in database. Please run the SQL setup script.')
      }
    } catch (error) {
      console.error('Error loading subjects:', error)
      throw error // Re-throw to allow components to handle it
    } finally {
      loading.value = false
    }
  }

  async function loadQuestions(subjectId, count) {
    loading.value = true
    try {
      const { data, error } = await quizService.getRandomQuestions(subjectId, count)
      if (error) throw error
      currentQuestions.value = data || []
      userAnswers.value = {}
      return { success: true, error: null }
    } catch (error) {
      console.error('Error loading questions:', error)
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  async function startQuiz(userId, subjectId, totalQuestions) {
    loading.value = true
    try {
      const { data, error } = await quizService.createQuizAttempt(userId, subjectId, totalQuestions)
      if (error) throw error
      currentQuizAttempt.value = data
      return { success: true, error: null }
    } catch (error) {
      console.error('Error starting quiz:', error)
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  function setAnswer(questionId, answer) {
    userAnswers.value[questionId] = answer
  }

  function getAnswer(questionId) {
    return userAnswers.value[questionId] || null
  }

  async function submitQuiz() {
    if (!currentQuizAttempt.value) return { success: false, error: 'No active quiz attempt' }

    loading.value = true
    try {
      let correctCount = 0
      const responses = []

      // Calculate scores and save responses
      for (const question of currentQuestions.value) {
        const selectedAnswer = userAnswers.value[question.id] || ''
        const isCorrect = selectedAnswer === question.correct_answer

        if (isCorrect) correctCount++

        responses.push({
          quizAttemptId: currentQuizAttempt.value.id,
          questionId: question.id,
          selectedAnswer,
          isCorrect
        })

        await quizService.saveQuizResponse(
          currentQuizAttempt.value.id,
          question.id,
          selectedAnswer,
          isCorrect
        )
      }

      const score = (correctCount / currentQuestions.value.length) * 100

      // Complete quiz attempt
      const { data, error } = await quizService.completeQuizAttempt(
        currentQuizAttempt.value.id,
        correctCount,
        score
      )

      if (error) throw error

      // Update daily practice
      const subjectId = currentQuizAttempt.value.subject_id
      await quizService.updateDailyPractice(
        currentQuizAttempt.value.user_id,
        subjectId,
        currentQuestions.value.length,
        score
      )

      return {
        success: true,
        data: {
          total: currentQuestions.value.length,
          correct: correctCount,
          score: score,
          responses: responses
        },
        error: null
      }
    } catch (error) {
      console.error('Error submitting quiz:', error)
      return { success: false, error: error.message }
    } finally {
      loading.value = false
    }
  }

  function resetQuiz() {
    currentQuestions.value = []
    currentQuizAttempt.value = null
    userAnswers.value = {}
  }

  return {
    subjects,
    currentQuestions,
    currentQuizAttempt,
    userAnswers,
    loading,
    loadSubjects,
    loadQuestions,
    startQuiz,
    setAnswer,
    getAnswer,
    submitQuiz,
    resetQuiz
  }
})

