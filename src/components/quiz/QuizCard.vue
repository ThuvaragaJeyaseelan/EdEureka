<template>
  <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-xl transition-all transform hover:-translate-y-1 cursor-pointer border-t-4 border-purple-500" @click="openQuiz">
    <div class="flex items-center space-x-4">
      <div class="text-4xl">📝</div>
      <div>
        <h3 class="text-xl font-semibold mb-2 text-gray-800">Sample Questions</h3>
        <p class="text-gray-600">Practice with randomized MCQ questions and get instant feedback</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits(['open-quiz'])

const openQuiz = () => {
  emit('open-quiz')
}
</script>

