// Voice input service using Web Speech API
export const voiceService = {
  recognition: null,
  isSupported: false,
  currentInstance: null,

  init() {
    if (typeof window !== 'undefined') {
      const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
      
      if (SpeechRecognition) {
        this.isSupported = true
      }
    }
    return this.isSupported
  },

  createRecognition() {
    if (!this.isSupported) {
      this.init()
    }
    
    if (!this.isSupported) {
      return null
    }

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    const recognition = new SpeechRecognition()
    recognition.continuous = false
    recognition.interimResults = false
    recognition.lang = 'en-US'
    
    return recognition
  },

  startListening(onResult, onError, onEnd) {
    // Stop any existing recognition first
    this.stopListening()

    if (!this.isSupported) {
      this.init()
    }

    if (!this.isSupported) {
      if (onError) onError(new Error('Speech recognition is not supported in this browser. Please use Chrome, Edge, or Safari.'))
      return false
    }

    // Create a new recognition instance
    this.currentInstance = this.createRecognition()
    
    if (!this.currentInstance) {
      if (onError) onError(new Error('Failed to initialize speech recognition'))
      return false
    }

    this.currentInstance.onresult = (event) => {
      const transcript = event.results[0][0].transcript.trim()
      if (onResult && transcript) onResult(transcript)
    }

    this.currentInstance.onerror = (event) => {
      let errorMessage = 'Speech recognition error'
      
      switch(event.error) {
        case 'no-speech':
          errorMessage = 'No speech detected. Please try again.'
          break
        case 'audio-capture':
          errorMessage = 'No microphone found. Please check your microphone.'
          break
        case 'not-allowed':
          errorMessage = 'Microphone permission denied. Please allow microphone access in your browser settings.'
          break
        case 'network':
          errorMessage = 'Network error. Please check your internet connection.'
          break
        default:
          errorMessage = `Speech recognition error: ${event.error}`
      }
      
      if (onError) onError(new Error(errorMessage))
    }

    this.currentInstance.onend = () => {
      this.currentInstance = null
      if (onEnd) onEnd()
    }

    try {
      this.currentInstance.start()
      return true
    } catch (error) {
      this.currentInstance = null
      if (onError) {
        if (error.message && error.message.includes('already started')) {
          onError(new Error('Speech recognition is already running. Please wait.'))
        } else {
          onError(error)
        }
      }
      return false
    }
  },

  stopListening() {
    if (this.currentInstance) {
      try {
        this.currentInstance.stop()
      } catch (error) {
        // Ignore errors when stopping
        console.log('Error stopping recognition:', error)
      }
      this.currentInstance = null
    }
  },

  isListening() {
    return this.currentInstance && this.currentInstance.state === 'listening'
  }
}

