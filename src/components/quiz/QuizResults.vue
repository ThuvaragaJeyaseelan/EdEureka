<template>
  <div class="bg-white rounded-xl shadow-xl p-6 border border-gray-100">
    <div class="text-center mb-8">
      <h2 class="text-3xl font-bold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">Quiz Completed!</h2>
      <div class="inline-block p-6 bg-gradient-to-br from-purple-100 to-blue-100 rounded-full mb-4 shadow-lg">
        <div class="text-4xl font-bold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">{{ score }}%</div>
      </div>
      <p class="text-lg text-gray-700">
        You got <span class="font-semibold text-green-600">{{ correct }}</span> out of 
        <span class="font-semibold text-gray-800">{{ total }}</span> questions correct
      </p>
    </div>

    <div class="space-y-6">
      <div
        v-for="(item, index) in results"
        :key="index"
        class="border-2 rounded-xl p-4 transition-all"
        :class="{
          'bg-green-50 border-green-300 shadow-md': item.isCorrect,
          'bg-red-50 border-red-300 shadow-md': !item.isCorrect
        }"
      >
        <div class="flex items-start justify-between mb-2">
          <div class="flex items-center space-x-2">
            <span class="font-semibold">Question {{ index + 1 }}:</span>
            <span v-if="item.isCorrect" class="text-green-600 font-semibold">✓ Correct</span>
            <span v-else class="text-red-600 font-semibold">✗ Incorrect</span>
          </div>
        </div>
        <p class="mb-3 font-medium">{{ item.question.question_text }}</p>
        <div class="space-y-2 text-sm">
          <div>
            <span class="font-semibold">Your answer:</span>
            <span class="ml-2" :class="item.isCorrect ? 'text-green-700' : 'text-red-700'">
              {{ item.selectedAnswer }}. {{ getOptionText(item.question, item.selectedAnswer) }}
            </span>
          </div>
          <div v-if="!item.isCorrect">
            <span class="font-semibold">Correct answer:</span>
            <span class="ml-2 text-green-700">
              {{ item.question.correct_answer }}. {{ getOptionText(item.question, item.question.correct_answer) }}
            </span>
          </div>
          <div v-if="item.question.explanation" class="mt-3 p-3 bg-white rounded border">
            <span class="font-semibold">Explanation:</span>
            <p class="mt-1 text-gray-700">{{ item.question.explanation }}</p>
          </div>
        </div>
      </div>
    </div>

    <div class="mt-8 flex justify-center space-x-4">
      <button
        @click="$emit('retry-quiz')"
        class="px-6 py-2 bg-gradient-to-r from-purple-600 to-blue-600 text-white rounded-xl hover:from-purple-700 hover:to-blue-700 transition shadow-lg font-semibold"
      >
        Try Again
      </button>
      <button
        @click="$emit('back-to-subject')"
        class="px-6 py-2 bg-gray-200 text-gray-700 rounded-xl hover:bg-gray-300 transition font-medium"
      >
        Back to Subject
      </button>
    </div>
  </div>
</template>

<script setup>
defineProps({
  score: {
    type: Number,
    required: true
  },
  correct: {
    type: Number,
    required: true
  },
  total: {
    type: Number,
    required: true
  },
  results: {
    type: Array,
    required: true
  }
})

defineEmits(['retry-quiz', 'back-to-subject'])

const getOptionText = (question, option) => {
  switch (option) {
    case 'A': return question.option_a
    case 'B': return question.option_b
    case 'C': return question.option_c
    case 'D': return question.option_d
    default: return ''
  }
}
</script>

