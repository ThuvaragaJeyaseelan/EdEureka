<template>
  <div
    v-if="show"
    class="fixed inset-0 bg-black bg-opacity-75 flex items-center justify-center z-[100] p-4"
    @click.self="close"
  >
    <div
      class="bg-white rounded-2xl shadow-2xl w-full max-w-6xl h-[90vh] flex flex-col"
      @click.stop
    >
      <!-- Header -->
      <div class="flex justify-between items-center p-4 border-b border-gray-200 bg-gradient-to-r from-purple-50 to-blue-50">
        <div>
          <h3 class="text-xl font-semibold text-gray-800">{{ book?.title }}</h3>
          <p class="text-sm text-gray-600">{{ book?.author }}</p>
        </div>
        <div class="flex items-center space-x-2">
          <button
            @click="downloadPDF"
            class="px-4 py-2 bg-blue-600 text-white rounded-lg hover:bg-blue-700 transition font-medium text-sm"
            :disabled="loading"
          >
            📥 Download
          </button>
          <button
            @click="close"
            class="text-gray-500 hover:text-gray-700 text-2xl font-bold leading-none w-8 h-8 flex items-center justify-center rounded hover:bg-gray-100 transition"
          >
            ✕
          </button>
        </div>
      </div>

      <!-- PDF Viewer -->
      <div class="flex-1 overflow-hidden relative">
        <div v-if="loading" class="absolute inset-0 flex items-center justify-center bg-gray-50">
          <div class="text-center">
            <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600 mx-auto mb-4"></div>
            <p class="text-gray-600">Loading PDF...</p>
          </div>
        </div>
        
        <div v-else-if="error" class="absolute inset-0 flex items-center justify-center bg-gray-50">
          <div class="text-center p-8">
            <div class="text-6xl mb-4">❌</div>
            <p class="text-lg font-semibold text-gray-800 mb-2">Error loading PDF</p>
            <p class="text-gray-600 mb-4">{{ error }}</p>
            <button
              @click="loadPDF"
              class="px-6 py-2 bg-purple-600 text-white rounded-lg hover:bg-purple-700 transition"
            >
              Try Again
            </button>
          </div>
        </div>

        <iframe
          v-else-if="pdfUrl"
          :src="pdfUrl"
          class="w-full h-full border-0"
          frameborder="0"
        ></iframe>

        <div v-else class="absolute inset-0 flex items-center justify-center bg-gray-50">
          <div class="text-center p-8">
            <div class="text-6xl mb-4">📄</div>
            <p class="text-lg font-semibold text-gray-800 mb-2">No PDF available</p>
            <p class="text-gray-600">PDF file not found for this resource book.</p>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  show: {
    type: Boolean,
    default: false
  },
  book: {
    type: Object,
    default: null
  }
})

const emit = defineEmits(['close'])

const loading = ref(false)
const error = ref(null)
const pdfUrl = ref(null)

const close = () => {
  emit('close')
}

const loadPDF = async () => {
  if (!props.book?.pdf_url) {
    error.value = 'No PDF URL available'
    return
  }

  loading.value = true
  error.value = null

  try {
    // Use the PDF URL directly - Supabase Storage provides public URLs
    pdfUrl.value = props.book.pdf_url
    loading.value = false
  } catch (err) {
    console.error('Error loading PDF:', err)
    error.value = 'Failed to load PDF. Please try again.'
    loading.value = false
  }
}

const downloadPDF = () => {
  if (pdfUrl.value) {
    const link = document.createElement('a')
    link.href = pdfUrl.value
    link.download = `${props.book?.title || 'resource'}.pdf`
    link.target = '_blank'
    document.body.appendChild(link)
    link.click()
    document.body.removeChild(link)
  }
}

watch(() => props.show, (newVal) => {
  if (newVal && props.book) {
    loadPDF()
  } else {
    pdfUrl.value = null
    error.value = null
  }
})

watch(() => props.book, (newBook) => {
  if (props.show && newBook) {
    loadPDF()
  }
})
</script>

