<template>
  <div class="flex items-center justify-between mb-6">
    <div class="text-sm text-gray-600">
      Question <span class="font-semibold">{{ currentQuestion + 1 }}</span> of 
      <span class="font-semibold">{{ totalQuestions }}</span>
    </div>
    <div class="flex space-x-2">
      <div
        v-for="(answered, index) in questionStatus"
        :key="index"
        class="w-3 h-3 rounded-full"
        :class="{
          'bg-green-500': answered === 'answered',
          'bg-blue-500': answered === 'current',
          'bg-gray-300': answered === 'unanswered'
        }"
        :title="`Question ${index + 1}`"
      ></div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  currentQuestion: {
    type: Number,
    required: true
  },
  totalQuestions: {
    type: Number,
    required: true
  },
  questionStatus: {
    type: Array,
    default: () => []
  }
})
</script>

