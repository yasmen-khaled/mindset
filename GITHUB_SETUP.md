# GitHub Integration Setup Guide

## How It Works Now

1. **User sets GitHub repo URL** in the quiz (question 4 - code question)
2. **User writes code** with filename (e.g., `sum.dart`)
3. **User clicks "Execute & Submit"**
4. **Backend creates file in your GitHub repo** using GitHub API
5. **Backend runs checks** and returns score

## Setup Steps

### 1. Get GitHub Personal Access Token

1. Go to GitHub.com → Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token (classic)"
3. Give it a name like "Mindset App"
4. Select scopes: `repo` (full control of private repositories)
5. Click "Generate token"
6. **Copy the token** (you won't see it again!)

### 2. Configure Backend

Edit `backend/simple_server.go` line 55:

```go
const GITHUB_TOKEN = "YOUR_GITHUB_TOKEN_HERE" // Replace with your GitHub personal access token
```

Replace `YOUR_GITHUB_TOKEN_HERE` with your actual token:

```go
const GITHUB_TOKEN = "ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### 3. Create a Test Repository

1. Go to GitHub.com and create a new repository
2. Make it public or private (your choice)
3. Copy the repository URL (e.g., `https://github.com/yourusername/test-repo`)

### 4. Test the Integration

1. Start the backend server:
   ```bash
   cd backend
   go run simple_server.go
   ```

2. Run the Flutter app and go to Quiz page
3. When you reach question 4 (code question):
   - Enter your GitHub repo URL: `https://github.com/yourusername/test-repo`
   - Click "Save"
   - Enter filename: `test.dart`
   - Enter code:
     ```dart
     int sum(int a, int b) {
       return a + b;
     }
     ```
   - Click "Execute & Submit"

4. Check your GitHub repository - you should see a new file `test.dart` with your code!

## What Happens

- ✅ Code gets uploaded to your GitHub repo
- ✅ Backend runs basic checks (length, safety, etc.)
- ✅ User gets score and feedback
- ✅ Quiz advances to next question

## Troubleshooting

- **"GitHub token not configured"**: Make sure you replaced the token in `simple_server.go`
- **"GitHub API error 401"**: Your token is invalid or expired
- **"GitHub API error 404"**: Repository doesn't exist or token doesn't have access
- **"invalid repo URL format"**: Use format `https://github.com/username/repo` or `username/repo`

## Security Note

- Never commit your GitHub token to version control
- Consider using environment variables in production
- The token gives full repo access, so keep it secure
