import OpenAI from 'openai'

const apiKey = import.meta.env.VITE_OPENAI_API_KEY

if (!apiKey) {
  console.warn('OpenAI API key not found. AI features will not work.')
}

const openai = apiKey ? new OpenAI({
  apiKey: apiKey,
  dangerouslyAllowBrowser: true
}) : null

export const aiService = {
  async chat(messages) {
    if (!openai) {
      throw new Error('OpenAI API key not configured')
    }

    try {
      const completion = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: messages,
        temperature: 0.7
      })
      return completion.choices[0].message.content
    } catch (error) {
      console.error('OpenAI API error:', error)
      
      // Handle specific error types
      if (error.status === 429) {
        throw new Error('Rate limit exceeded. You have exceeded your OpenAI API quota. Please check your plan and billing details, or try again later.')
      } else if (error.status === 401) {
        throw new Error('Invalid API key. Please check your OpenAI API key configuration.')
      } else if (error.status === 402) {
        throw new Error('Payment required. Please check your OpenAI account billing details.')
      } else if (error.message?.includes('quota')) {
        throw new Error('API quota exceeded. Please check your OpenAI plan and billing details.')
      }
      
      throw error
    }
  },

  async summarize(text, subjectName = null) {
    if (!openai) {
      throw new Error('OpenAI API key not configured')
    }

    try {
      const systemPrompt = subjectName
        ? `You are an expert educational assistant helping a student studying ${subjectName} for AL exams. 
        Summarize the following text clearly and concisely, focusing on:
        - Key concepts and main ideas
        - Important facts and details
        - How concepts relate to ${subjectName}
        - Any formulas, definitions, or critical information
        Keep the summary educational and easy to understand.`
        : `You are a helpful assistant that summarizes educational content. 
        Provide clear, concise summaries focusing on key points, main ideas, and important details.`

      const completion = await openai.chat.completions.create({
        model: 'gpt-3.5-turbo',
        messages: [
          {
            role: 'system',
            content: systemPrompt
          },
          {
            role: 'user',
            content: `Please summarize the following text:\n\n${text}`
          }
        ],
        temperature: 0.5,
        max_tokens: 500
      })
      return completion.choices[0].message.content
    } catch (error) {
      console.error('OpenAI API error:', error)
      
      // Handle specific error types
      if (error.status === 429) {
        throw new Error('Rate limit exceeded. You have exceeded your OpenAI API quota. Please check your plan and billing details, or try again later.')
      } else if (error.status === 401) {
        throw new Error('Invalid API key. Please check your OpenAI API key configuration.')
      } else if (error.status === 402) {
        throw new Error('Payment required. Please check your OpenAI account billing details.')
      } else if (error.message?.includes('quota')) {
        throw new Error('API quota exceeded. Please check your OpenAI plan and billing details.')
      }
      
      throw error
    }
  }
}

