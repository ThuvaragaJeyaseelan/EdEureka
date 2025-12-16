<template>
  <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-xl transition-all transform hover:-translate-y-1 cursor-pointer border-t-4 border-orange-500" @click="openStudyNotes">
    <div class="flex items-center space-x-4">
      <div class="text-4xl">📚</div>
      <div>
        <h3 class="text-xl font-semibold mb-2 text-gray-800">Study Notes</h3>
        <p class="text-gray-600">Review your mistakes and learn from them</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits(['open-study-notes'])

const openStudyNotes = () => {
  emit('open-study-notes')
}
</script>

