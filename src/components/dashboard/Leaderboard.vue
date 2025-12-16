<template>
  <div class="bg-white rounded-xl shadow-lg p-6 border border-gray-100">
    <h3 class="text-xl font-semibold mb-4 bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">
      Leaderboard{{ subjectName ? ` - ${subjectName}` : '' }}
    </h3>
    <div v-if="loading" class="flex justify-center items-center h-64">
      <div class="animate-spin rounded-full h-12 w-12 border-b-2 border-purple-600"></div>
    </div>
    <div v-else-if="!leaderboard || leaderboard.length === 0" class="text-center text-gray-500 py-12">
      No leaderboard data available yet.
    </div>
    <div v-else class="space-y-3">
      <div
        v-for="(entry, index) in leaderboard"
        :key="entry.user_id"
        class="flex items-center justify-between p-4 rounded-xl transition-all"
        :class="{
          'bg-gradient-to-r from-yellow-50 to-amber-50 border-2 border-yellow-400 shadow-md': index === 0,
          'bg-gray-50 border border-gray-200 hover:bg-gray-100': index > 0
        }"
      >
        <div class="flex items-center space-x-4">
          <div
            class="w-10 h-10 rounded-full flex items-center justify-center font-bold text-white shadow-md"
            :class="{
              'bg-gradient-to-br from-yellow-400 to-yellow-600': index === 0,
              'bg-gradient-to-br from-gray-400 to-gray-600': index === 1,
              'bg-gradient-to-br from-orange-400 to-orange-600': index === 2,
              'bg-gradient-to-br from-purple-400 to-blue-500': index > 2
            }"
          >
            {{ index + 1 }}
          </div>
          <div>
            <div class="font-semibold text-gray-800">{{ entry.name }}</div>
            <div class="text-sm text-gray-500">{{ entry.subject }}</div>
          </div>
        </div>
        <div class="text-right">
          <div class="font-semibold bg-gradient-to-r from-purple-600 to-blue-600 bg-clip-text text-transparent">{{ entry.averageScore.toFixed(1) }}%</div>
          <div class="text-xs text-gray-500">{{ entry.totalAttempts }} attempts</div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup>
defineProps({
  leaderboard: {
    type: Array,
    default: () => []
  },
  loading: {
    type: Boolean,
    default: false
  },
  subjectName: {
    type: String,
    default: null
  }
})
</script>

