<template>
  <div 
    class="bg-white rounded-xl shadow-md p-6 hover:shadow-xl transition-all transform hover:-translate-y-1 cursor-pointer border-t-4 border-green-500" 
    @click.stop="openResourceBooks"
    @keyup.enter="openResourceBooks"
    tabindex="0"
    role="button"
    aria-label="Open Resource Books"
  >
    <div class="flex items-center space-x-4">
      <div class="text-4xl">📖</div>
      <div>
        <h3 class="text-xl font-semibold mb-2 text-gray-800">Resource Books</h3>
        <p class="text-gray-600">Browse recommended textbooks and study materials</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits(['open-resource-books'])

const openResourceBooks = (event) => {
  event?.preventDefault()
  event?.stopPropagation()
  console.log('ResourceBooksCard clicked, emitting event')
  emit('open-resource-books')
}
</script>

