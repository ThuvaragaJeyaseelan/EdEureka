# AI Features Guide

## Voice Input Functionality

The platform now includes full voice input support for AI features using the Web Speech API.

### Supported Browsers
- ✅ Chrome (recommended)
- ✅ Edge (Chromium-based)
- ✅ Safari (macOS/iOS)
- ❌ Firefox (not supported)

### Features

#### 1. AI Chat Assistant with Voice Input
- **Location**: Subject Page → AI Chat Assistant card
- **Features**:
  - Type questions normally
  - Click the microphone button to use voice input
  - Voice is converted to text automatically
  - Text appears in the input field for review before sending
  - Enhanced AI prompts for better educational responses

#### 2. Summarize Content with Voice Input
- **Location**: Subject Page → Summarize Content card
- **Features**:
  - Type or paste text to summarize
  - Use voice input to speak text (useful for long paragraphs)
  - Voice input appends to existing text
  - Subject-aware summarization (tailored to the selected subject)

### How to Use Voice Input

1. **Click the microphone button** (🎤) next to the input field
2. **Allow microphone access** when prompted by your browser
3. **Speak clearly** - the system will listen for your speech
4. **Wait for conversion** - your speech will be converted to text
5. **Review and send** - the text appears in the input field for you to review

### Voice Input Tips

- Speak clearly and at a moderate pace
- Minimize background noise
- Ensure microphone permissions are granted
- The red pulsing indicator shows when listening is active
- Click the microphone again to stop listening

### Error Handling

The system provides helpful error messages for:
- Microphone permission denied
- No speech detected
- Network errors
- Browser compatibility issues

### Technical Details

- Uses Web Speech API (SpeechRecognition)
- Converts speech to text before sending to OpenAI
- Supports English (en-US) language
- Non-continuous recognition (stops after speech ends)
- Automatic cleanup when modals are closed

## Enhanced AI Prompts

### Chat Assistant
- Subject-aware responses
- Step-by-step explanations
- Educational examples
- Encouraging and supportive tone

### Summarization
- Subject-specific summaries
- Focus on key concepts
- Important facts and formulas
- Educational context

## Troubleshooting

### Voice input not working?
1. Check browser compatibility (Chrome/Edge/Safari)
2. Ensure microphone permissions are granted
3. Check if microphone is working in other apps
4. Try refreshing the page

### Microphone permission denied?
1. Go to browser settings
2. Find site permissions
3. Allow microphone access for this site
4. Refresh the page

### No speech detected?
1. Check microphone is connected and working
2. Speak louder and clearer
3. Reduce background noise
4. Try again after a moment

