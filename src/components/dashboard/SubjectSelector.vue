<template>
  <div class="relative" ref="dropdown">
    <button
      @click.stop="toggleDropdown"
      class="flex items-center space-x-2 px-4 py-2 bg-white border-2 border-gray-300 rounded-xl hover:border-purple-400 hover:bg-purple-50 focus:outline-none focus:ring-2 focus:ring-purple-500 transition"
    >
      <span>{{ selectedSubject?.name || 'Select Subject' }}</span>
      <svg 
        class="w-5 h-5 transition-transform"
        :class="{ 'rotate-180': showDropdown }"
        fill="none" 
        stroke="currentColor" 
        viewBox="0 0 24 24"
      >
        <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 9l-7 7-7-7" />
      </svg>
    </button>
    
    <div
      v-if="showDropdown"
      @click.stop
      class="absolute mt-2 w-56 bg-white rounded-xl shadow-xl py-2 z-50 border border-gray-200"
    >
      <div v-if="loading" class="px-4 py-2 text-sm text-gray-500">
        Loading subjects...
      </div>
      <div v-else-if="error" class="px-4 py-2 text-sm text-red-600">
        {{ error }}
      </div>
      <div v-else-if="subjects.length === 0" class="px-4 py-2 text-sm text-gray-500">
        <div>No subjects available</div>
        <div class="text-xs mt-1 text-gray-400">Please set up your database</div>
      </div>
      <button
        v-for="subject in subjects"
        :key="subject.id"
        @click.stop="selectSubject(subject)"
        class="block w-full text-left px-4 py-2 text-sm text-gray-700 hover:bg-purple-50 hover:text-purple-600 transition rounded-lg mx-1"
      >
        {{ subject.name }}
      </button>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted, onUnmounted, watch } from 'vue'
import { useRouter, useRoute } from 'vue-router'
import { useQuizStore } from '../../stores/quiz'

const router = useRouter()
const route = useRoute()
const quizStore = useQuizStore()

const subjects = ref([])
const selectedSubject = ref(null)
const showDropdown = ref(false)
const dropdown = ref(null)
const loading = ref(false)
const error = ref(null)

const toggleDropdown = () => {
  showDropdown.value = !showDropdown.value
  if (showDropdown.value && subjects.value.length === 0) {
    loadSubjects()
  }
}

const emit = defineEmits(['subject-selected'])

const selectSubject = (subject) => {
  selectedSubject.value = subject
  showDropdown.value = false
  emit('subject-selected', subject)
  router.push(`/subject/${subject.id}`)
}

const loadSubjects = async () => {
  if (quizStore.subjects.length > 0) {
    subjects.value = quizStore.subjects
    error.value = null
    return
  }
  
  loading.value = true
  error.value = null
  try {
    await quizStore.loadSubjects()
    subjects.value = quizStore.subjects
    
    if (subjects.value.length === 0) {
      error.value = 'Database not configured. Please run the SQL setup script in Supabase.'
    }
    
    // Set selected subject if we're on a subject page
    if (route.params.subjectId) {
      selectedSubject.value = quizStore.subjects.find(s => s.id === route.params.subjectId)
    }
  } catch (err) {
    console.error('Error loading subjects:', err)
    error.value = err.message || 'Failed to load subjects. Check your database connection.'
  } finally {
    loading.value = false
  }
}

const handleClickOutside = (event) => {
  if (dropdown.value && !dropdown.value.contains(event.target)) {
    showDropdown.value = false
  }
}

// Watch for route changes to update selected subject
watch(() => route.params.subjectId, (newSubjectId) => {
  if (newSubjectId && quizStore.subjects.length > 0) {
    selectedSubject.value = quizStore.subjects.find(s => s.id === newSubjectId)
  }
})

onMounted(async () => {
  await loadSubjects()
  document.addEventListener('click', handleClickOutside)
})

onUnmounted(() => {
  document.removeEventListener('click', handleClickOutside)
})
</script>

