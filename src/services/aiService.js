// Multi-provider AI Service
// Supports: OpenAI, Google Gemini, Groq, Hugging Face

const OPENAI_API_KEY = import.meta.env.VITE_OPENAI_API_KEY
const GEMINI_API_KEY = import.meta.env.VITE_GEMINI_API_KEY
const GROQ_API_KEY = import.meta.env.VITE_GROQ_API_KEY
const AI_PROVIDER = import.meta.env.VITE_AI_PROVIDER || 'groq' // 'openai', 'gemini', 'groq' - Default to Groq (free & fast)

// Google Gemini API (Free tier: 15 RPM, 1500 RPD)
async function chatWithGemini(messages, systemPrompt = null) {
  if (!GEMINI_API_KEY) {
    throw new Error('Gemini API key not configured. Please set VITE_GEMINI_API_KEY in your .env file.')
  }

  try {
    // Convert messages format for Gemini
    const geminiMessages = messages
      .filter(msg => msg.role !== 'system')
      .map(msg => ({
        role: msg.role === 'assistant' ? 'model' : 'user',
        parts: [{ text: msg.content }]
      }))

    // Add system instruction if provided
    if (systemPrompt) {
      geminiMessages.unshift({
        role: 'user',
        parts: [{ text: systemPrompt }]
      })
    }

    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: geminiMessages,
          generationConfig: {
            temperature: 0.7,
            topK: 40,
            topP: 0.95,
            maxOutputTokens: 1024,
          },
        }),
      }
    )

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error?.message || 'Gemini API error')
    }

    const data = await response.json()
    return data.candidates[0].content.parts[0].text
  } catch (error) {
    console.error('Gemini API error:', error)
    throw error
  }
}

async function summarizeWithGemini(text, subjectName = null) {
  if (!GEMINI_API_KEY) {
    throw new Error('Gemini API key not configured')
  }

  try {
    const systemPrompt = subjectName
      ? `You are an expert educational assistant helping a student studying ${subjectName} for AL exams. Summarize the following text clearly and concisely, focusing on key concepts, main ideas, important facts, and how concepts relate to ${subjectName}. Keep the summary educational and easy to understand.`
      : `You are a helpful assistant that summarizes educational content. Provide clear, concise summaries focusing on key points, main ideas, and important details.`

    const prompt = `Please summarize the following text:\n\n${text}`

    // Use gemini-1.5-flash (newer, free model)
    const model = 'gemini-1.5-flash'
    
    const response = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${GEMINI_API_KEY}`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          contents: [{
            role: 'user',
            parts: [{ text: `${systemPrompt}\n\n${prompt}` }]
          }],
          generationConfig: {
            temperature: 0.5,
            maxOutputTokens: 500,
          },
        }),
      }
    )

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error?.message || 'Gemini API error')
    }

    const data = await response.json()
    return data.candidates[0].content.parts[0].text
  } catch (error) {
    console.error('Gemini API error:', error)
    throw error
  }
}

// Groq API (Free tier: Very fast, good limits)
async function chatWithGroq(messages, systemPrompt = null) {
  if (!GROQ_API_KEY) {
    throw new Error('Groq API key not configured. Please set VITE_GROQ_API_KEY in your .env file.')
  }

  try {
    const formattedMessages = systemPrompt
      ? [{ role: 'system', content: systemPrompt }, ...messages]
      : messages

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GROQ_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'llama-3.1-8b-instant', // Free, fast model
        messages: formattedMessages,
        temperature: 0.7,
      }),
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error?.message || 'Groq API error')
    }

    const data = await response.json()
    return data.choices[0].message.content
  } catch (error) {
    console.error('Groq API error:', error)
    throw error
  }
}

async function summarizeWithGroq(text, subjectName = null) {
  if (!GROQ_API_KEY) {
    throw new Error('Groq API key not configured')
  }

  try {
    const systemPrompt = subjectName
      ? `You are an expert educational assistant helping a student studying ${subjectName} for AL exams. Summarize the following text clearly and concisely, focusing on key concepts, main ideas, important facts, and how concepts relate to ${subjectName}. Keep the summary educational and easy to understand.`
      : `You are a helpful assistant that summarizes educational content. Provide clear, concise summaries focusing on key points, main ideas, and important details.`

    const response = await fetch('https://api.groq.com/openai/v1/chat/completions', {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${GROQ_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: 'llama-3.1-8b-instant',
        messages: [
          { role: 'system', content: systemPrompt },
          { role: 'user', content: `Please summarize the following text:\n\n${text}` }
        ],
        temperature: 0.5,
        max_tokens: 500,
      }),
    })

    if (!response.ok) {
      const error = await response.json()
      throw new Error(error.error?.message || 'Groq API error')
    }

    const data = await response.json()
    return data.choices[0].message.content
  } catch (error) {
    console.error('Groq API error:', error)
    throw error
  }
}

// OpenAI (fallback if configured)
async function chatWithOpenAI(messages, systemPrompt = null) {
  if (!OPENAI_API_KEY) {
    throw new Error('OpenAI API key not configured')
  }

  const { default: OpenAI } = await import('openai')
  const openai = new OpenAI({
    apiKey: OPENAI_API_KEY,
    dangerouslyAllowBrowser: true
  })

  const formattedMessages = systemPrompt
    ? [{ role: 'system', content: systemPrompt }, ...messages]
    : messages

  const completion = await openai.chat.completions.create({
    model: 'gpt-3.5-turbo',
    messages: formattedMessages,
    temperature: 0.7
  })

  return completion.choices[0].message.content
}

async function summarizeWithOpenAI(text, subjectName = null) {
  if (!OPENAI_API_KEY) {
    throw new Error('OpenAI API key not configured')
  }

  const { default: OpenAI } = await import('openai')
  const openai = new OpenAI({
    apiKey: OPENAI_API_KEY,
    dangerouslyAllowBrowser: true
  })

  const systemPrompt = subjectName
    ? `You are an expert educational assistant helping a student studying ${subjectName} for AL exams. Summarize the following text clearly and concisely, focusing on key concepts, main ideas, important facts, and how concepts relate to ${subjectName}. Keep the summary educational and easy to understand.`
    : `You are a helpful assistant that summarizes educational content. Provide clear, concise summaries focusing on key points, main ideas, and important details.`

  const completion = await openai.chat.completions.create({
    model: 'gpt-3.5-turbo',
    messages: [
      { role: 'system', content: systemPrompt },
      { role: 'user', content: `Please summarize the following text:\n\n${text}` }
    ],
    temperature: 0.5,
    max_tokens: 500
  })

  return completion.choices[0].message.content
}

// Main AI Service with provider selection
export const aiService = {
  async chat(messages, systemPrompt = null) {
    try {
      switch (AI_PROVIDER) {
        case 'gemini':
          return await chatWithGemini(messages, systemPrompt)
        case 'groq':
          return await chatWithGroq(messages, systemPrompt)
        case 'openai':
          return await chatWithOpenAI(messages, systemPrompt)
        default:
          // Try providers in order of preference
          if (GEMINI_API_KEY) {
            return await chatWithGemini(messages, systemPrompt)
          } else if (GROQ_API_KEY) {
            return await chatWithGroq(messages, systemPrompt)
          } else if (OPENAI_API_KEY) {
            return await chatWithOpenAI(messages, systemPrompt)
          } else {
            throw new Error('No AI provider configured. Please set at least one API key in your .env file.')
          }
      }
    } catch (error) {
      console.error('AI Service error:', error)
      
      // Handle specific error types
      if (error.message?.includes('429') || error.message?.includes('quota') || error.message?.includes('rate limit')) {
        throw new Error('Rate limit exceeded. You have exceeded your API quota. Please check your plan and billing details, or try again later.')
      } else if (error.message?.includes('API key') || error.message?.includes('401') || error.message?.includes('403')) {
        throw new Error('Invalid API key. Please check your API key configuration.')
      } else if (error.message?.includes('Payment') || error.message?.includes('402')) {
        throw new Error('Payment required. Please check your account billing details.')
      }
      
      throw error
    }
  },

  async summarize(text, subjectName = null) {
    try {
      switch (AI_PROVIDER) {
        case 'gemini':
          return await summarizeWithGemini(text, subjectName)
        case 'groq':
          return await summarizeWithGroq(text, subjectName)
        case 'openai':
          return await summarizeWithOpenAI(text, subjectName)
        default:
          // Try providers in order of preference (Groq first - free & fast)
          if (GROQ_API_KEY) {
            return await summarizeWithGroq(text, subjectName)
          } else if (GEMINI_API_KEY) {
            return await summarizeWithGemini(text, subjectName)
          } else if (OPENAI_API_KEY) {
            return await summarizeWithOpenAI(text, subjectName)
          } else {
            throw new Error('No AI provider configured. Please set at least one API key in your .env file. Recommended: VITE_GROQ_API_KEY (free & fast)')
          }
      }
    } catch (error) {
      console.error('AI Service error:', error)
      
      // Handle specific error types
      if (error.message?.includes('429') || error.message?.includes('quota') || error.message?.includes('rate limit')) {
        throw new Error('Rate limit exceeded. You have exceeded your API quota. Please check your plan and billing details, or try again later.')
      } else if (error.message?.includes('API key') || error.message?.includes('401') || error.message?.includes('403')) {
        throw new Error('Invalid API key. Please check your API key configuration.')
      } else if (error.message?.includes('Payment') || error.message?.includes('402')) {
        throw new Error('Payment required. Please check your account billing details.')
      }
      
      throw error
    }
  }
}

