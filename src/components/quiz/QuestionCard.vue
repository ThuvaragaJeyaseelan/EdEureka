<template>
  <div class="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
    <div class="mb-6">
      <h3 class="text-lg font-semibold mb-4 text-gray-800">{{ question.question_text }}</h3>
      <div class="space-y-3">
        <label
          v-for="option in options"
          :key="option.value"
          class="flex items-center p-4 border-2 rounded-xl cursor-pointer transition-all"
          :class="{
            'border-purple-500 bg-gradient-to-r from-purple-50 to-blue-50 shadow-md': selectedAnswer === option.value,
            'border-gray-200 hover:border-purple-300 hover:bg-purple-50': selectedAnswer !== option.value
          }"
        >
          <input
            type="radio"
            :value="option.value"
            v-model="selectedAnswer"
            @change="handleAnswerChange"
            class="mr-3 w-5 h-5 text-purple-600 accent-purple-600"
          />
          <span class="font-medium mr-2 text-gray-800">{{ option.value }}.</span>
          <span class="text-gray-700">{{ option.text }}</span>
        </label>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, watch } from 'vue'

const props = defineProps({
  question: {
    type: Object,
    required: true
  },
  initialAnswer: {
    type: String,
    default: null
  }
})

const emit = defineEmits(['answer-selected'])

const selectedAnswer = ref(props.initialAnswer || null)

const options = [
  { value: 'A', text: props.question.option_a },
  { value: 'B', text: props.question.option_b },
  { value: 'C', text: props.question.option_c },
  { value: 'D', text: props.question.option_d }
]

const handleAnswerChange = () => {
  emit('answer-selected', selectedAnswer.value)
}

watch(() => props.initialAnswer, (newValue) => {
  selectedAnswer.value = newValue || null
})
</script>

