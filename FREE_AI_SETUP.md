# Free AI API Setup Guide

This project now supports multiple free AI providers! You can use Google Gemini, Groq, or OpenAI.

## 🆓 Free AI Providers

### 1. **Groq API** (Recommended - Fastest & Free) ⚡
- **Free Tier**: Very generous limits, extremely fast responses
- **Get API Key**: https://console.groq.com/keys
- **Setup**: 
  1. Sign up at Groq Console (free)
  2. Go to API Keys section
  3. Create a new API key
  4. Add to `.env.local`: `VITE_GROQ_API_KEY=your_api_key_here`
- **Why Groq?**: Fastest responses, great free tier, perfect for development!

### 2. **Google Gemini API** (Good Free Tier)
- **Free Tier**: 15 requests per minute, 1,500 requests per day
- **Get API Key**: https://makersuite.google.com/app/apikey
- **Setup**: 
  1. Go to Google AI Studio
  2. Click "Get API Key"
  3. Create a new API key
  4. Add to `.env.local`: `VITE_GEMINI_API_KEY=your_api_key_here`

### 3. **OpenAI API** (If you have credits)
- **Free Tier**: Limited credits for new users
- **Get API Key**: https://platform.openai.com/api-keys
- **Setup**: Add to `.env.local`: `VITE_OPENAI_API_KEY=your_api_key_here`

## Configuration

### Option 1: Auto-Detection (Recommended)
The service will automatically use the first available API key in this order:
1. **Groq** (if `VITE_GROQ_API_KEY` is set) - Default & Recommended ⚡
2. Gemini (if `VITE_GEMINI_API_KEY` is set)
3. OpenAI (if `VITE_OPENAI_API_KEY` is set)

### Option 2: Manual Selection
Set your preferred provider in `.env.local`:
```
VITE_AI_PROVIDER=groq
# Options: 'groq' (recommended), 'gemini', 'openai'
```

## Example .env.local File

```env
# Choose your AI provider (optional - defaults to Groq if not set)
VITE_AI_PROVIDER=groq

# Groq API (Free - Fastest & Recommended) ⚡
VITE_GROQ_API_KEY=your_groq_api_key_here

# Google Gemini API (Free - Alternative)
VITE_GEMINI_API_KEY=your_gemini_api_key_here

# OpenAI API (Paid - Fallback)
VITE_OPENAI_API_KEY=your_openai_api_key_here

# Supabase (Required)
VITE_SUPABASE_URL=your_supabase_url
VITE_SUPABASE_ANON_KEY=your_supabase_anon_key
```

## Quick Start with Groq (Free & Fast) ⚡

1. **Get your free API key**:
   - Visit: https://console.groq.com/keys
   - Sign up for free (no credit card required)
   - Go to API Keys section
   - Click "Create API Key"
   - Copy your API key

2. **Add to your project**:
   ```bash
   # Create .env.local file in project root
   echo "VITE_GROQ_API_KEY=your_groq_api_key_here" >> .env.local
   ```

3. **Restart your dev server**:
   ```bash
   npm run dev
   ```

4. **That's it!** Your AI features will now work for free with lightning-fast responses! 🎉⚡

## Features Supported

All providers support:
- ✅ AI Chat Assistant
- ✅ Text Summarization
- ✅ Educational content generation

## Rate Limits

- **Groq**: Very generous limits, extremely fast (free tier) ⚡
- **Gemini**: 15 requests/minute, 1,500/day (free tier)
- **OpenAI**: Varies by plan

## Troubleshooting

### "No AI provider configured"
- Make sure at least one API key is set in `.env.local`
- Restart your dev server after adding keys
- Check that the `.env.local` file is in the project root

### "Rate limit exceeded"
- Wait a few minutes and try again
- Consider switching to a different provider
- Check your API usage in the provider's dashboard

### "Invalid API key"
- Verify your API key is correct
- Make sure there are no extra spaces
- Regenerate the key if needed

## Switching Providers

To switch providers, simply:
1. Set `VITE_AI_PROVIDER` in `.env.local` to your preferred provider
2. Or remove it to use auto-detection
3. Restart your dev server

The service will automatically use the configured provider!

