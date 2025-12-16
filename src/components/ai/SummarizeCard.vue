<template>
  <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-xl transition-all transform hover:-translate-y-1 cursor-pointer border-t-4 border-cyan-500" @click="openSummarize">
    <div class="flex items-center space-x-4">
      <div class="text-4xl">📝</div>
      <div>
        <h3 class="text-xl font-semibold mb-2 text-gray-800">Summarize Content</h3>
        <p class="text-gray-600">Get concise summaries of long texts, books, or paragraphs</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits(['open-summarize'])

const openSummarize = () => {
  emit('open-summarize')
}
</script>

