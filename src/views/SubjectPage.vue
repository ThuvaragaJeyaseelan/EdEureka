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
              @click="$router.push('/dashboard')"
              class="text-gray-600 hover:text-purple-600 transition font-medium"
            >
              ← Back to Dashboard
            </button>
          </div>
          
          <div class="flex items-center space-x-4">
            <span class="text-gray-700 font-medium">{{ userDisplayName }}</span>
            <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-500 to-blue-500 flex items-center justify-center text-white font-semibold shadow-md">
              {{ userInitials }}
            </div>
          </div>
        </div>
      </div>
    </nav>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-12">
      <div v-if="loading" class="flex justify-center items-center h-64">
        <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
      </div>

      <div v-else-if="subject">
        <h1 class="text-4xl font-bold mb-2 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">{{ subject.name }}</h1>
        <p class="text-gray-600 mb-8">Choose an option to continue</p>

        <!-- Feature Cards -->
        <div class="grid md:grid-cols-2 lg:grid-cols-3 gap-6 mb-8">
          <QuizCard @open-quiz="handleOpenQuiz" />
          <AIChatCard @open-chat="showAIChat = true" />
          <SummarizeCard @open-summarize="showSummarize = true" />
          <ResourceBooksCard @open-resource-books="handleOpenResourceBooks" />
          
          <StudyNotesCard @open-study-notes="handleOpenStudyNotes" />
        </div>
      </div>

      <div v-else class="text-center py-12">
        <p class="text-gray-600">Subject not found</p>
        <router-link to="/dashboard" class="text-blue-600 hover:underline mt-4 inline-block">
          Go back to Dashboard
        </router-link>
      </div>
    </main>

    <!-- AI Chat Modal -->
    <div
      v-if="showAIChat"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click="showAIChat = false"
    >
      <div
        class="bg-white rounded-2xl p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto shadow-2xl"
        @click.stop
      >
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-semibold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">AI Chat Assistant</h3>
          <button @click="showAIChat = false" class="text-gray-500 hover:text-gray-700 text-2xl font-bold">
            ✕
          </button>
        </div>
        <div class="space-y-4">
          <div class="border-2 rounded-xl p-4 h-64 overflow-y-auto bg-gradient-to-br from-gray-50 to-blue-50">
            <div v-if="chatMessages.length === 0" class="text-center text-gray-500 py-8">
              <div class="text-4xl mb-2">💬</div>
              <p>Start a conversation! Ask me anything about {{ subject?.name || 'your subject' }}.</p>
              <p class="text-sm mt-2">You can type or use voice input</p>
            </div>
            <div v-for="(msg, index) in chatMessages" :key="index" class="mb-4">
              <div :class="msg.role === 'user' ? 'text-right' : 'text-left'">
                <div
                  :class="[
                    'inline-block p-3 rounded-xl max-w-[80%]',
                    msg.role === 'user' 
                      ? 'bg-gradient-to-r from-purple-600 to-blue-600 text-white shadow-md' 
                      : 'bg-white border-2 border-gray-200 shadow-sm'
                  ]"
                >
                  <div v-if="msg.role === 'assistant'" class="flex items-start space-x-2">
                    <span class="text-lg">🤖</span>
                    <div class="flex-1">{{ msg.content }}</div>
                  </div>
                  <div v-else>{{ msg.content }}</div>
                </div>
              </div>
            </div>
            <div v-if="chatLoading" class="text-left">
              <div class="inline-block p-3 rounded-xl bg-white border-2 border-gray-200">
                <div class="flex items-center space-x-2">
                  <div class="animate-spin rounded-full h-4 w-4 border-b-2 border-purple-600"></div>
                  <span class="text-gray-600">Thinking...</span>
                </div>
              </div>
            </div>
          </div>
          <div class="flex space-x-2">
            <div class="flex-1 relative">
            <input
              v-model="chatInput"
              @keyup.enter="sendChatMessage"
              type="text"
                placeholder="Type your question or use voice..."
                class="w-full px-4 py-3 pr-12 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition"
                :disabled="isListening || chatLoading"
              />
              <button
                @click="toggleVoiceInput"
                :disabled="chatLoading"
                :class="[
                  'absolute right-2 top-1/2 -translate-y-1/2 p-2 rounded-lg transition',
                  isListening
                    ? 'bg-red-500 text-white animate-pulse'
                    : 'bg-purple-100 text-purple-600 hover:bg-purple-200'
                ]"
                :title="isListening ? 'Stop listening' : 'Start voice input'"
              >
                <svg v-if="!isListening" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
                </svg>
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z" />
                </svg>
              </button>
            </div>
            <button
              @click="sendChatMessage"
              :disabled="chatLoading || !chatInput.trim() || isListening"
              class="px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 disabled:opacity-50 transition shadow-lg font-semibold"
            >
              <span v-if="chatLoading">...</span>
              <span v-else>Send</span>
            </button>
          </div>
          <div v-if="isListening" class="flex items-center space-x-2 text-purple-600">
            <div class="animate-pulse w-3 h-3 bg-red-500 rounded-full"></div>
            <span class="text-sm font-medium">Listening... Speak now</span>
          </div>
          <div v-if="voiceError" class="p-3 bg-red-50 border border-red-200 rounded-xl">
            <p class="text-sm text-red-600">{{ voiceError }}</p>
          </div>
          <p v-if="!voiceService.isSupported" class="text-xs text-gray-500">
            Voice input is not supported in this browser. Please use Chrome, Edge, or Safari.
          </p>
        </div>
      </div>
    </div>

    <!-- Summarize Modal -->
    <div
      v-if="showSummarize"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click="showSummarize = false"
    >
      <div
        class="bg-white rounded-2xl p-6 max-w-2xl w-full max-h-[80vh] overflow-y-auto shadow-2xl"
        @click.stop
      >
        <div class="flex justify-between items-center mb-4">
          <h3 class="text-xl font-semibold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">Summarize Content</h3>
          <button @click="showSummarize = false" class="text-gray-500 hover:text-gray-700 text-2xl font-bold">
            ✕
          </button>
        </div>
        <div class="space-y-4">
          <div>
            <label class="block text-sm font-medium mb-2 text-gray-700">Enter text to summarize:</label>
            <div class="relative">
            <textarea
              v-model="summarizeText"
              rows="8"
                class="w-full px-4 py-3 pr-12 border-2 border-gray-300 rounded-xl focus:ring-2 focus:ring-purple-500 focus:border-purple-500 transition"
                placeholder="Paste your text, paragraph, or book excerpt here... Or use voice input!"
                :disabled="isListeningSummarize || summarizeLoading"
            ></textarea>
              <button
                @click="toggleVoiceInputSummarize"
                :disabled="summarizeLoading"
                :class="[
                  'absolute right-2 top-2 p-2 rounded-lg transition',
                  isListeningSummarize
                    ? 'bg-red-500 text-white animate-pulse'
                    : 'bg-purple-100 text-purple-600 hover:bg-purple-200'
                ]"
                :title="isListeningSummarize ? 'Stop listening' : 'Start voice input'"
              >
                <svg v-if="!isListeningSummarize" class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z" />
                </svg>
                <svg v-else class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
                  <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M9 10a1 1 0 011-1h4a1 1 0 011 1v4a1 1 0 01-1 1h-4a1 1 0 01-1-1v-4z" />
                </svg>
              </button>
            </div>
            <div v-if="isListeningSummarize" class="flex items-center space-x-2 text-purple-600 mt-2">
              <div class="animate-pulse w-3 h-3 bg-red-500 rounded-full"></div>
              <span class="text-sm font-medium">Listening... Speak now</span>
            </div>
            <div v-if="summarizeVoiceError" class="mt-2 p-2 bg-red-50 border border-red-200 rounded-lg">
              <p class="text-sm text-red-600">{{ summarizeVoiceError }}</p>
            </div>
          </div>
          <button
            @click="handleSummarize"
            :disabled="summarizeLoading || !summarizeText.trim() || isListeningSummarize"
            class="w-full px-6 py-3 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 disabled:opacity-50 transition shadow-lg font-semibold"
          >
            <span v-if="summarizeLoading">Summarizing...</span>
            <span v-else>Summarize</span>
          </button>
          <div v-if="summarizedResult" class="border-2 border-gray-200 rounded-xl p-4 bg-gradient-to-br from-gray-50 to-blue-50">
            <h4 class="font-semibold mb-2 text-gray-800">Summary:</h4>
            <p class="text-gray-700 whitespace-pre-wrap">{{ summarizedResult }}</p>
          </div>
        </div>
      </div>
    </div>

    <!-- Resource Books Modal -->
    <div
      v-if="showResourceBooks"
      class="fixed inset-0 bg-black bg-opacity-50 flex items-center justify-center z-50 p-4"
      @click="showResourceBooks = false"
    >
      <div
        class="bg-white rounded-2xl p-6 max-w-4xl w-full max-h-[80vh] overflow-y-auto shadow-2xl"
        @click.stop
      >
        <div class="flex justify-between items-center mb-4 border-b pb-4">
          <h3 class="text-xl font-semibold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
            Resource Books - {{ subject?.name || 'Subject' }}
          </h3>
          <button 
            @click="showResourceBooks = false" 
            class="text-gray-500 hover:text-gray-700 text-2xl font-bold leading-none w-8 h-8 flex items-center justify-center rounded hover:bg-gray-100 transition"
          >
            ✕
          </button>
        </div>
        <div class="space-y-4">
          <p class="text-gray-600 mb-4">Recommended textbooks and study materials for <strong>{{ subject?.name || 'this subject' }}</strong>:</p>
          
          <div v-if="loadingBooks" class="flex justify-center items-center py-12">
            <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
          </div>
          
          <div v-else-if="resourceBooks.length > 0" class="grid md:grid-cols-2 gap-4">
            <div
              v-for="book in resourceBooks"
              :key="book.id"
              class="border-2 border-gray-200 rounded-lg p-4 hover:shadow-md hover:border-purple-300 transition cursor-pointer"
              @click="openPDFViewer(book)"
            >
              <div class="flex items-start space-x-3">
                <div class="text-3xl">📕</div>
                <div class="flex-1">
                  <h4 class="font-semibold text-lg mb-1 text-gray-800">{{ book.title }}</h4>
                  <p class="text-sm text-gray-600 mb-2">by {{ book.author }}</p>
                  <p class="text-sm text-gray-700 mb-3">{{ book.description }}</p>
                  <div class="flex items-center space-x-2 mb-3">
                    <span class="text-xs px-2 py-1 bg-blue-100 text-blue-700 rounded font-medium">{{ book.edition }}</span>
                    <span v-if="book.isbn" class="text-xs text-gray-500">ISBN: {{ book.isbn }}</span>
                  </div>
                  <div class="mt-3 flex items-center space-x-2">
                    <button
                      v-if="book.pdf_url"
                      class="px-4 py-2 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-lg hover:from-purple-700 hover:to-blue-700 transition text-sm font-medium shadow-md"
                      @click.stop="openPDFViewer(book)"
                    >
                      📖 View PDF
                    </button>
                    <button
                      v-else
                      class="px-4 py-2 bg-gray-200 text-gray-600 rounded-lg text-sm font-medium cursor-not-allowed"
                      disabled
                    >
                      PDF Not Available
                    </button>
                    <a
                      v-if="book.link && book.link !== '#'"
                      :href="book.link"
                      target="_blank"
                      rel="noopener noreferrer"
                      class="text-sm text-blue-600 hover:text-blue-800 underline font-medium"
                      @click.stop
                    >
                      More Info →
                    </a>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <div v-else class="text-center py-8 text-gray-500">
            <div class="text-4xl mb-4">📚</div>
            <p class="text-lg font-medium">No resource books available for this subject yet.</p>
            <p class="text-sm mt-2">Check back soon for recommended textbooks!</p>
          </div>
        </div>
      </div>
    </div>

    <!-- PDF Viewer Modal -->
    <ResourceBookViewer
      :show="showPDFViewer"
      :book="selectedBook"
      @close="closePDFViewer"
    />
  </div>
</template>

<script setup>
import { ref, computed, onMounted, onUnmounted, nextTick } from 'vue'
import { useRoute, useRouter } from 'vue-router'
import { useAuthStore } from '../stores/auth'
import { useQuizStore } from '../stores/quiz'
import { aiService } from '../services/aiService'
import { voiceService } from '../services/voiceService'
import { resourceBooksService } from '../services/resourceBooksService'
import QuizCard from '../components/quiz/QuizCard.vue'
import AIChatCard from '../components/ai/AIChatCard.vue'
import SummarizeCard from '../components/ai/SummarizeCard.vue'
import ResourceBooksCard from '../components/quiz/ResourceBooksCard.vue'
import StudyNotesCard from '../components/quiz/StudyNotesCard.vue'
import ResourceBookViewer from '../components/ResourceBookViewer.vue'

const route = useRoute()
const router = useRouter()
const authStore = useAuthStore()
const quizStore = useQuizStore()

const subjectId = route.params.subjectId
const subject = ref(null)
const loading = ref(true)

const showAIChat = ref(false)
const chatMessages = ref([])
const chatInput = ref('')
const chatLoading = ref(false)
const isListening = ref(false)
const voiceError = ref('')

const showSummarize = ref(false)
const summarizeText = ref('')
const summarizedResult = ref('')
const summarizeLoading = ref(false)
const isListeningSummarize = ref(false)
const summarizeVoiceError = ref('')

const showResourceBooks = ref(false)
const resourceBooks = ref([])
const loadingBooks = ref(false)
const showPDFViewer = ref(false)
const selectedBook = ref(null)

const userDisplayName = computed(() => {
  if (!authStore.user) return ''
  return authStore.user.user_metadata?.name || authStore.user.email?.split('@')[0] || 'User'
})

const userInitials = computed(() => {
  const name = userDisplayName.value
  if (!name) return 'U'
  const parts = name.split(' ')
  if (parts.length >= 2) {
    return (parts[0][0] + parts[1][0]).toUpperCase()
  }
  return name[0].toUpperCase()
})

onMounted(async () => {
  // Initialize voice service
  voiceService.init()
  
  await authStore.initialize()
  await quizStore.loadSubjects()
  
  subject.value = quizStore.subjects.find(s => s.id === subjectId)
  loading.value = false
})

const handleOpenQuiz = () => {
  router.push(`/quiz/${subjectId}`)
}

const handleOpenStudyNotes = () => {
  router.push(`/study-notes/${subjectId}`)
}

const handleOpenResourceBooks = async () => {
  if (!subject.value) {
    alert('Subject not loaded. Please wait a moment and try again.')
    return
  }
  
  showResourceBooks.value = true
  await loadResourceBooks()
}

const loadResourceBooks = async () => {
  if (!subject.value) return
  
  loadingBooks.value = true
  try {
    const result = await resourceBooksService.getResourceBooks(subject.value.id)
    if (result.success) {
      resourceBooks.value = result.data || []
    } else {
      console.error('Error loading resource books:', result.error)
      resourceBooks.value = []
    }
  } catch (error) {
    console.error('Error loading resource books:', error)
    resourceBooks.value = []
  } finally {
    loadingBooks.value = false
  }
}

const openPDFViewer = (book) => {
  if (!book.pdf_url) {
    alert('PDF not available for this book.')
    return
  }
  selectedBook.value = book
  showPDFViewer.value = true
}

const closePDFViewer = () => {
  showPDFViewer.value = false
  selectedBook.value = null
}

const sendChatMessage = async () => {
  if (!chatInput.value.trim() || chatLoading.value || isListening.value) return

  const userMessage = chatInput.value.trim()
  chatMessages.value.push({ role: 'user', content: userMessage })
  chatInput.value = ''
  chatLoading.value = true
  voiceError.value = ''

  try {
    const messages = [
      {
        role: 'system',
        content: `You are an expert tutor helping a student prepare for AL (Advanced Level) exams in ${subject.value?.name || 'their subject'}. 
        - Provide clear, step-by-step explanations
        - Use examples when helpful
        - Break down complex concepts into simpler parts
        - Encourage learning and understanding
        - If asked about something outside your knowledge, politely say so
        - Always be supportive and educational`
      },
      ...chatMessages.value.map(msg => ({
        role: msg.role,
        content: msg.content
      }))
    ]

    const response = await aiService.chat(messages)
    chatMessages.value.push({ role: 'assistant', content: response })
  } catch (error) {
    console.error('Chat error:', error)
    
    // Provide user-friendly error messages
    let errorMessage = 'Sorry, I encountered an error. Please try again.'
    
    if (error.message?.includes('quota') || error.message?.includes('Rate limit') || error.message?.includes('429')) {
      errorMessage = '⚠️ API Quota Exceeded\n\nYou have exceeded your OpenAI API quota. Please check your OpenAI account billing and plan details, or try again later.\n\nVisit: https://platform.openai.com/account/billing'
    } else if (error.message?.includes('API key') || error.message?.includes('401')) {
      errorMessage = '⚠️ API Key Error\n\nPlease check your OpenAI API key configuration in the .env.local file.'
    } else if (error.message?.includes('Payment') || error.message?.includes('402')) {
      errorMessage = '⚠️ Payment Required\n\nPlease check your OpenAI account billing details.'
    } else if (error.message) {
      errorMessage = `⚠️ ${error.message}`
    }
    
    chatMessages.value.push({
      role: 'assistant',
      content: errorMessage
    })
  } finally {
    chatLoading.value = false
  }
}

const toggleVoiceInput = () => {
  if (isListening.value) {
    voiceService.stopListening()
    isListening.value = false
    voiceError.value = ''
    return
  }

  // Initialize voice service if not already done
  if (!voiceService.isSupported) {
    voiceService.init()
  }

  if (!voiceService.isSupported) {
    voiceError.value = 'Voice input is not supported in this browser. Please use Chrome, Edge, or Safari.'
    return
  }

  isListening.value = true
  voiceError.value = ''

  voiceService.startListening(
    (transcript) => {
      // Successfully got transcript
      chatInput.value = transcript
      isListening.value = false
      // Optionally auto-send, or let user review and send manually
      // sendChatMessage()
    },
    (error) => {
      // Error occurred
      console.error('Voice recognition error:', error)
      isListening.value = false
      if (error.message.includes('no-speech')) {
        voiceError.value = 'No speech detected. Please try again.'
      } else if (error.message.includes('not-allowed')) {
        voiceError.value = 'Microphone permission denied. Please allow microphone access.'
      } else {
        voiceError.value = 'Voice recognition error: ' + error.message
      }
    },
    () => {
      // Recognition ended
      isListening.value = false
    }
  )
}

onUnmounted(() => {
  // Clean up voice recognition
  if (isListening.value) {
    voiceService.stopListening()
  }
  if (isListeningSummarize.value) {
    voiceService.stopListening()
  }
})

const handleSummarize = async () => {
  if (!summarizeText.value.trim() || summarizeLoading.value || isListeningSummarize.value) return

  summarizeLoading.value = true
  summarizeVoiceError.value = ''
  
  try {
    const result = await aiService.summarize(summarizeText.value, subject.value?.name)
    summarizedResult.value = result
  } catch (error) {
    console.error('Summarize error:', error)
    
    // Provide user-friendly error messages
    if (error.message?.includes('quota') || error.message?.includes('Rate limit') || error.message?.includes('429')) {
      summarizedResult.value = '⚠️ API Quota Exceeded\n\nYou have exceeded your OpenAI API quota. Please:\n\n1. Check your OpenAI account billing and plan details\n2. Upgrade your plan if needed\n3. Wait for your quota to reset\n4. Or configure a different API key\n\nVisit: https://platform.openai.com/account/billing'
    } else if (error.message?.includes('API key') || error.message?.includes('401')) {
      summarizedResult.value = '⚠️ API Key Error\n\nPlease check your OpenAI API key configuration in the .env.local file.\n\nMake sure you have:\nVITE_OPENAI_API_KEY=your_api_key_here'
    } else if (error.message?.includes('Payment') || error.message?.includes('402')) {
      summarizedResult.value = '⚠️ Payment Required\n\nPlease check your OpenAI account billing details and ensure payment method is set up.'
    } else {
      summarizedResult.value = `⚠️ Error: ${error.message || 'Could not summarize. Please try again or check your internet connection.'}`
    }
  } finally {
    summarizeLoading.value = false
  }
}

const toggleVoiceInputSummarize = () => {
  if (isListeningSummarize.value) {
    voiceService.stopListening()
    isListeningSummarize.value = false
    summarizeVoiceError.value = ''
    return
  }

  // Initialize voice service if not already done
  if (!voiceService.isSupported) {
    voiceService.init()
  }

  if (!voiceService.isSupported) {
    summarizeVoiceError.value = 'Voice input is not supported in this browser. Please use Chrome, Edge, or Safari.'
    return
  }

  isListeningSummarize.value = true
  summarizeVoiceError.value = ''

  voiceService.startListening(
    (transcript) => {
      // Successfully got transcript - append to existing text
      summarizeText.value = (summarizeText.value ? summarizeText.value + ' ' : '') + transcript
      isListeningSummarize.value = false
    },
    (error) => {
      // Error occurred
      console.error('Voice recognition error:', error)
      isListeningSummarize.value = false
      if (error.message.includes('no-speech')) {
        summarizeVoiceError.value = 'No speech detected. Please try again.'
      } else if (error.message.includes('not-allowed')) {
        summarizeVoiceError.value = 'Microphone permission denied. Please allow microphone access.'
      } else {
        summarizeVoiceError.value = 'Voice recognition error: ' + error.message
      }
    },
    () => {
      // Recognition ended
      isListeningSummarize.value = false
    }
  )
}
</script>

