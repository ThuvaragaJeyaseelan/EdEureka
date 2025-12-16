<template>
  <div class="bg-white rounded-xl shadow-md p-6 hover:shadow-xl transition-all transform hover:-translate-y-1 cursor-pointer border-t-4 border-blue-500" @click="openChat">
    <div class="flex items-center space-x-4">
      <div class="text-4xl">💬</div>
      <div>
        <h3 class="text-xl font-semibold mb-2 text-gray-800">AI Chat Assistant</h3>
        <p class="text-gray-600">Ask questions and get instant help with your studies</p>
        <p class="text-sm text-gray-500 mt-2">Text & Voice support</p>
      </div>
    </div>
  </div>
</template>

<script setup>
const emit = defineEmits(['open-chat'])

const openChat = () => {
  emit('open-chat')
}
</script>

