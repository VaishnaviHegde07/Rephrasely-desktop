# Testing OpenRouter API

## Quick Test Script (Without Building the App)

### Option 1: Test with Dart Script

1. **Open `test_api.dart`** in the project root
2. **Replace `YOUR_API_KEY_HERE`** with your actual API key from https://openrouter.ai
3. **Run the test**:

```bash
cd /Users/vaishnavihegde/Desktop/rephrasely_desktop
dart test_api.dart
```

This will:
- ✅ Verify your API key works
- ✅ List available models
- ✅ Send a test chat message
- ✅ Show you the AI response

**Expected Output:**
```
🔍 Testing OpenRouter API Connection...

📋 Test 1: Fetching available models...
✅ Success! Total Models Available: 150+

📌 Sample Models:
   - openai/gpt-4o
     Name: GPT-4O
   - openai/gpt-3.5-turbo
     Name: GPT-3.5 Turbo
   ...

💬 Test 2: Sending test chat message...
✅ Success! AI Response:
   "Hello from Rephrasely! 👋 How can I help you today?"
```

### Option 2: Test in Browser (Chrome)

If you want to test the full app without installing Xcode:

```bash
cd /Users/vaishnavihegde/Desktop/rephrasely_desktop
flutter run -d chrome
```

This will:
- Open the app in your Chrome browser
- Allow you to test all UI features
- Enter and test your API key
- Use the chatbot interface

**Note:** Some macOS-specific features won't work in Chrome, but all the API functionality will work perfectly!

## Testing Inside the App

Once you can run the app (via Chrome or macOS after installing Xcode):

### Step 1: Enter API Key
1. Click **Settings** → **OpenRouter API Keys**
2. Paste your API key
3. Click **Save & Test API Key**
4. Should see: "✅ API key saved successfully!"

### Step 2: Test with Chatbot
1. Click **Test with Chatbot** button
2. Select a model (e.g., GPT-4O Mini)
3. Type: "Hello, test message"
4. Click **Send**
5. Wait for AI response

### Step 3: Try Different Models
- Click the robot icon to select different models
- Test with:
  - **GPT-3.5 Turbo** (fastest, cheapest)
  - **GPT-4O Mini** (balanced)
  - **Claude 3.5 Sonnet** (high quality)

## Troubleshooting

### ❌ "Invalid API Key"
**Cause:** API key is wrong or expired

**Fix:**
1. Go to https://openrouter.ai
2. Login to your account
3. Navigate to "Keys" section
4. Generate a new API key
5. Copy the full key (starts with `sk-or-v1-...`)
6. Paste in the app

### ❌ "API Error: Insufficient credits"
**Cause:** Your OpenRouter account has no credits

**Fix:**
1. Go to https://openrouter.ai
2. Add credits to your account (minimum $5)
3. Try again

### ❌ "Network Error" or "Connection Failed"
**Cause:** No internet connection or firewall blocking

**Fix:**
1. Check your internet connection
2. Try opening https://openrouter.ai in browser
3. Check if your firewall/VPN is blocking API requests

### ❌ "Rate Limit Exceeded"
**Cause:** Too many requests in short time

**Fix:**
1. Wait 60 seconds
2. Try again
3. Use a slower request rate

## API Key Security Tips

### ✅ DO:
- Keep your API key secret
- Store it only in the app settings (encrypted local storage)
- Regenerate it periodically
- Set usage limits in OpenRouter dashboard

### ❌ DON'T:
- Share your API key with others
- Commit it to version control (git)
- Post it in public forums
- Hardcode it in source files

## Understanding API Costs

OpenRouter charges based on:
- **Model used** (GPT-4 is more expensive than GPT-3.5)
- **Tokens processed** (input + output)
- **Request volume**

**Approximate Costs:**
- GPT-3.5 Turbo: ~$0.001 per 1,000 tokens (very cheap)
- GPT-4O Mini: ~$0.15 per 1M tokens (affordable)
- GPT-4O: ~$5 per 1M tokens (premium)
- Claude 3.5 Sonnet: ~$3 per 1M tokens (mid-range)

**Example:**
- A typical chat message (200 tokens): $0.0002 - $0.001
- 100 messages: $0.02 - $0.10

Check current pricing at: https://openrouter.ai/models

## Example Test Messages

Try these in the chatbot:

### Simple Test:
```
User: Hello, are you working?
AI: Should respond with a greeting
```

### Functionality Test:
```
User: What's 25 * 47?
AI: Should calculate: 1,175
```

### Creative Test:
```
User: Write a haiku about coding
AI: Should write a creative haiku
```

### Multi-turn Conversation:
```
User: My name is Alice
AI: Acknowledges your name
User: What's my name?
AI: Should remember: Alice
```

## Monitoring Usage

### In OpenRouter Dashboard:
1. Go to https://openrouter.ai/dashboard
2. View **Usage** tab
3. See:
   - Requests per day
   - Cost per model
   - Total spend
   - Remaining credits

### In the App:
- Currently no usage tracking (future feature)
- Check OpenRouter dashboard for detailed analytics

## Next Steps

Once API testing is successful:

1. ✅ API key validated → You're ready to use the app
2. 🎨 Test theme switching (Settings → App Theme)
3. 🤖 Test different AI models
4. 💾 Verify settings persist after restart
5. 🚀 Start building your features!

## Need Help?

- **OpenRouter Docs**: https://openrouter.ai/docs
- **OpenRouter Discord**: https://discord.gg/openrouter
- **Check app console** for detailed error messages

