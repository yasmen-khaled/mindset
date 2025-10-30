# Task IDE - Quick Start Guide

## 🚀 Feature Overview

The Task IDE allows users to write and submit code solutions after watching educational videos in the Mindset app. It's an interactive, IDE-like environment integrated with GitHub repositories.

## 📋 Step-by-Step Usage

### For Users

#### 1. Watch Video Content
- Navigate to the Tasks page
- Click on a task to open the video dialog
- Watch the educational video about the topic

#### 2. Start Coding Task
- Click the green "Start Task" button
- The Task IDE interface opens

#### 3. Write Code
```
✓ Select programming language (Dart, Python, JavaScript, Java, C++)
✓ Enter code in the text editor
✓ Filename auto-updates based on selected language
✓ Write your solution
```

#### 4. Submit Solution
```
1. Review your code
2. Click "Submit Solution" button
3. Wait for validation
4. View results and score
```

#### 5. View Results
- Success dialog shows points earned
- Error messages explain validation failures
- Click "Return" to return to tasks

---

## 🔧 Configuration Requirements

### Prerequisites

1. **Backend Setup**
   - Must have `/submit_code` endpoint configured
   - Endpoint must validate code and return scores
   - See `docs/TASK_IDE_IMPLEMENTATION.md` for endpoint specs

2. **User Settings**
   - GitHub repo URL must be set in profile settings
   - Optional: GitHub personal access token

### Configuration Steps

#### Set GitHub Repository (In App Settings)

```
1. User Profile Settings
2. Look for "GitHub Repository" field
3. Enter repo URL: https://github.com/username/repo
4. Save settings
5. Repo is now available for task submissions
```

---

## 📱 UI Components

### Main IDE Screen

```
┌─────────────────────────────────────┐
│ ← Task Title | Code Editor         │
├─────────────────────────────────────┤
│ Task Description                    │
├─────────────────────────────────────┤
│ ❓ Task Question                    │
│    Write a function that...         │
├─────────────────────────────────────┤
│ ✓ Requirements                      │
│   • Function must accept list       │
│   • Return new list reversed        │
│   • Capitalize each item            │
├─────────────────────────────────────┤
│ 📝 Example                          │
│    Input: [...]                     │
│    Expected Output: [...]           │
├─────────────────────────────────────┤
│ [Language ▼] [Filename input]       │
├─────────────────────────────────────┤
│ ┌─────────────────────────────────┐ │
│ │ // Code editor                  │ │
│ │ // Write your solution here     │ │
│ │                                 │ │
│ │                                 │ │
│ └─────────────────────────────────┘ │
├─────────────────────────────────────┤
│ Repository Info or Warning          │
├─────────────────────────────────────┤
│ [📤 Submit Solution]                │
├─────────────────────────────────────┤
│ 🏆    🏠    🎮                      │
└─────────────────────────────────────┘
```

### Success Dialog

```
┌─────────────────────────────────────┐
│ ✓ Check Mark Icon                   │
│                                     │
│ Task completed!                     │
│                                     │
│ Points earned: 100                  │
│                                     │
│ [          Return           ]       │
└─────────────────────────────────────┘
```

---

## 🌐 Supported Languages

| Language   | Extension | File Example |
|-----------|-----------|--------------|
| Dart      | `.dart`   | solution.dart |
| Python    | `.py`     | solution.py |
| JavaScript| `.js`     | solution.js |
| Java      | `.java`   | solution.java |
| C++       | `.cpp`    | solution.cpp |

---

## 🎯 Example Workflow

### Scenario: Complete a Python Task

```
1. User navigates to Tasks page
   ↓
2. Clicks on "Level One: Positive Thinking - Task 1"
   ↓
3. Video dialog opens showing video content
   ↓
4. User watches the video (educational content)
   ↓
5. Clicks green "Start Task" button
   ↓
6. TaskIDEPage opens
   ↓
7. User:
   - Selects "PYTHON" from language dropdown
   - Sees filename auto-change to "solution.py"
   - Enters Python code in editor
   - Example: prints a greeting
   ↓
8. User clicks "Submit Solution"
   ↓
9. Loading spinner appears while submitting
   ↓
10. Backend validates code:
    - Checks syntax
    - Verifies logic
    - Calculates score
    ↓
11. Success! Dialog shows "Points earned: 85"
    ↓
12. User clicks "Return" to return
```

---

## ⚠️ Error Messages & Solutions

### Error: "Please enter code"
**Problem:** User tried to submit without writing code
**Solution:** Write code in the editor before submitting

### Error: "Error: Failed to load user data"
**Problem:** User data failed to load
**Solution:** Re-open the IDE or restart the app

### Warning: "GitHub repository not set..."
**Problem:** No GitHub repo configured
**Solution:** Go to Settings → Add GitHub repo URL

### Error: Backend validation failed
**Problem:** Code doesn't meet requirements
**Solution:** Review error message and fix code

---

## 💾 Data Persistence

### What Gets Saved
- User auth token (in SharedPreferences)
- GitHub repo URL (in SharedPreferences)
- Phone number (in SharedPreferences)

### What Doesn't Get Saved
- Code written in editor (cleared on exit)
- File submissions (processed and cleared)
- Draft code (not auto-saved)

---

## 🔐 Security Notes

✓ All code is sent over HTTPS
✓ Authentication via bearer tokens
✓ User phone number transmitted securely
✓ GitHub tokens (if used) encrypted locally
✓ No code stored without user permission

---

## 🐛 Troubleshooting

### IDE Won't Load
```
1. Check internet connection
2. Verify backend is running
3. Check auth token is valid
4. Restart app
```

### Submit Button Disabled
```
1. Write code first (at least 1 character)
2. Check auth token in settings
3. Verify network connection
```

### Language Won't Change
```
1. Tap language dropdown
2. Select desired language
3. Filename should auto-update
4. If not, reload IDE
```

### Repo Info Not Showing
```
1. Go to Settings
2. Add GitHub repo URL
3. Come back to IDE
4. Should display repo info
```

---

## 📚 Additional Resources

- **Full Documentation:** `docs/TASK_IDE_IMPLEMENTATION.md`
- **Backend Specs:** `backend/README.md`
- **API Reference:** `backend/SETUP_GUIDE.md`

---

## ✨ Tips & Tricks

1. **Quick Language Switch**
   - Filename auto-updates when you change language
   - No need to manually edit filename

2. **Copy-Paste Works**
   - Use Ctrl+C / Cmd+C to copy code
   - Use Ctrl+V / Cmd+V to paste

3. **Multi-Line Support**
   - Editor supports unlimited lines
   - Paste entire code blocks at once

4. **Return to Home**
   - Click 🏠 icon to go to home
   - Your code draft will not be saved
   - IDE state resets on navigation

---

**Version:** 1.0.0  
**Last Updated:** October 24, 2025  
**Language:** Arabic & English
