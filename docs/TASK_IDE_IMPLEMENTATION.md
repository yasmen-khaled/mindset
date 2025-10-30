# Task IDE Implementation Guide

## Overview
The Task IDE feature enables users to write and submit code solutions directly within the Mindset app. After watching educational videos/content, users can click the "Start Task" button to open an IDE-like interface where they can write code in multiple programming languages and submit it for validation.

Features include:
- Task question and problem statements
- Clear requirements list
- Code examples with input/output
- Multi-language support
- Real-time code validation

## Architecture

### Components Created/Modified

#### 1. **TaskIDEPage** (`lib/pages/task_ide.dart`)
A complete IDE interface with:
- Multi-language code editor support
- Code submission to backend
- GitHub repository integration
- Real-time validation feedback
- Arabic UI with minimalist design

**Supported Languages:**
- Dart
- Python
- JavaScript
- Java
- C++

#### 2. **Modified Tasks Page** (`lib/pages/tasks.dart`)
Updated video dialog to include:
- "ابدأ المهمة" (Start Task) button
- "الرجوع" (Back) button
- Navigation to TaskIDEPage

### Features

#### Code Editor
```
- Multi-line code input with syntax highlighting placeholder
- Language selection dropdown
- Auto-generated filename based on selected language
- Character counter (future enhancement)
- Copy/paste support
```

#### Task Description Features
```
- Task Question: Clear problem statement in a blue container
- Requirements: Bulleted list of requirements in a green container
- Examples: Input/output examples in an orange container
  ✓ Shows expected input format
  ✓ Shows expected output format
  ✓ Helps users understand the task
```

#### GitHub Integration
```
- Automatic loading of repo URL from user profile settings
- Repo URL display in task IDE
- Warning notification if repo not configured
- Support for future GitHub API interactions
```

#### Submission System
```
- Real-time validation feedback
- Score calculation
- Success/error messages
- Completion dialog with points earned
- Loading state during submission
```

### Data Flow

```
User watches video
    ↓
Clicks "Start Task" button
    ↓
TaskIDEPage opens with:
    - Task ID, Title, Description
    - Loads user token & repo URL from storage
    ↓
User writes code and selects language
    ↓
Clicks "Submit" button
    ↓
ApiService.submitCode() called with:
    - Code content
    - Filename
    - Language
    - Task ID
    - User token
    - Phone number
    - Repo URL
    ↓
Backend validates and checks repo
    ↓
Response with score & validation results
    ↓
Success dialog or error message displayed
    ↓
User returns to tasks page
```

## Integration Points

### 1. **Storage Service** (`lib/services/storage_service.dart`)
Used to retrieve:
- `getToken()` - Authentication token
- `getPhoneNumber()` - User phone for backend
- `getRepoUrl()` - GitHub repo URL
- `getGithubToken()` - Optional GitHub token (future use)

### 2. **API Service** (`lib/services/api_service.dart`)
Calls:
- `ApiService.submitCode()` - Main submission endpoint

**Parameters:**
```dart
submitCode({
  required String token,              // Auth token
  required String code,               // Code content
  String? filename,                   // Filename (auto-generated)
  String language = 'dart',           // Programming language
  String? taskId,                     // Task identifier
  String? xPhone,                     // User phone (X-Phone header)
  String? repoUrl,                    // GitHub repo (X-Repo-Url header)
  String? githubToken,                // GitHub token (X-Github-Token header)
})
```

**Response Structure:**
```dart
{
  'success': bool,
  'message': String,
  'score': int,               // Points earned
  'checks': Map<String, dynamic>  // Validation results
}
```

### 3. **Navigation**
From `tasks.dart`:
```dart
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => TaskIDEPage(
      taskId: 'task_${index + 1}',
      taskTitle: 'Level One: Positive Thinking - Task ${index + 1}',
      taskDescription: 'Complete the coding task...',
      taskQuestion: 'Write a function that...',
      requirements: [
        'Requirement 1',
        'Requirement 2',
        'Requirement 3',
      ],
      exampleInput: 'input = [...]',
      exampleOutput: 'output = [...]',
    ),
  ),
);
```

**TaskIDEPage Parameters:**
- `taskId` (required) - Unique identifier for the task
- `taskTitle` (required) - Display title of the task
- `taskDescription` (required) - Brief description of the task
- `taskQuestion` (optional) - Detailed problem statement/question
- `requirements` (optional) - List of requirements the solution must meet
- `exampleInput` (optional) - Example input for the task
- `exampleOutput` (optional) - Expected output for the example

## UI Components

### Header Section
- Back button
- Task title
- Subtitle "محرر الكود" (Code Editor)

### Editor Section
- Task description box
- Language selector dropdown
- Filename input field
- Code editor (multiline TextField)
- Syntax highlighting colors (via fillColor)
- Green code hint text

### Info Section
- Repository information display
- Connected repo status
- Warning if repo not configured

### Submission Section
- Status message display (success/error)
- Large submit button with loading animation
- Score display in completion dialog

### Navigation Section
- Bottom navigation with 3 buttons
- Leaderboard (placeholder)
- Home (returns to main)
- Games (placeholder)

## Styling & Theme

**Color Scheme (Arabic-Compliant Minimalist):**
```
Primary Gradient:
- Top: Color(0xFF1E88E5) (Light Blue)
- Bottom: Color(0xFF0D47A1) (Dark Blue)

Accents:
- Success: Colors.green[600]
- Error: Colors.red
- Warnings: Colors.orange
- Neutral: Colors.grey[700]

Backgrounds:
- Code editor: Color(0xFF1A1A1A) (Nearly black)
- Inputs: Colors.white.withOpacity(0.1)
- Containers: Colors.white.withOpacity(0.1)
```

**Typography:**
- Headers: 18px, Bold, White
- Labels: 12px, Regular, White 70% opacity
- Code text: 12px, Courier font family
- Buttons: 14-16px, Bold, White

## Localization

All text is in English:
- "Start Task" - Begin coding challenge
- "Back" - Return to previous screen
- "Code Editor" - IDE interface label
- "Submit Solution" - Send code for validation
- "Task completed!" - Success message
- "Points earned:" - Score display
- "Submitting..." - Loading state
- "Please enter code" - Validation prompt
- "Error: Failed to load user data" - Data loading error
- "GitHub repository not set" - Configuration warning

## Backend Requirements

The backend's `/submit_code` endpoint must:

1. **Accept Headers:**
   - `Authorization: Bearer {token}`
   - `X-Phone: {phoneNumber}`
   - `X-Repo-Url: {repoUrl}`
   - `X-Github-Token: {githubToken}` (optional)

2. **Accept JSON Body:**
```json
{
  "code": "string",
  "filename": "string",
  "language": "string",
  "task_id": "string"
}
```

3. **Return JSON Response:**
```json
{
  "success": true,
  "message": "Code submitted successfully",
  "score": 100,
  "checks": {
    "syntax": true,
    "logic": true,
    "performance": true
  }
}
```

## Future Enhancements

1. **Code Syntax Highlighting**
   - Implement flutter_highlight package
   - Real-time syntax coloring

2. **Git Integration**
   - Automatic commit to GitHub
   - PR creation for submissions
   - Code review automation

3. **Collaborative Features**
   - Pair programming mode
   - Code sharing
   - Live collaboration

4. **Advanced IDE Features**
   - Code templates/snippets
   - Auto-completion
   - Line numbers
   - Code formatting
   - Bracket matching

5. **Testing Framework**
   - Unit test integration
   - Test case visualization
   - Coverage reports

6. **Performance Analytics**
   - Submission history
   - Performance metrics
   - Achievement tracking
   - Badges system

## Error Handling

**Current Error Scenarios:**

1. **Empty Code Submission**
   - Message: "الرجاء إدخال الكود" (Please enter code)
   - Type: Error toast

2. **User Not Authenticated**
   - Message: "خطأ: لم يتم تحميل بيانات المستخدم" (Error: User data not loaded)
   - Type: Error toast

3. **Network Error**
   - Message: Displayed from API response
   - Type: Error container in IDE

4. **Missing GitHub Repo**
   - Message: "لم يتم تعيين مستودع GitHub. الرجاء تعيينه من الإعدادات."
   - Type: Warning container (non-blocking)

5. **Validation Failure**
   - Message: Backend error message displayed
   - Type: Error container with details

## Testing Workflow

1. Navigate to Tasks page
2. Click on a task row to open video dialog
3. Click "ابدأ المهمة" button
4. Write code in the editor
5. Select programming language from dropdown
6. Click "إرسال الحل" to submit
7. View validation results
8. Complete dialog appears on success

## Files Modified/Created

### Created:
- `lib/pages/task_ide.dart` (450+ lines)

### Modified:
- `lib/pages/tasks.dart` (Updated dialog with action buttons)

### Unchanged:
- `lib/services/api_service.dart` (Already has submitCode method)
- `lib/services/storage_service.dart` (Already has repo URL methods)

## Notes

- [[memory:6961211]] Always use bcrypt for password hashing in the backend
- All UI is right-to-left (RTL) Arabic compatible
- Minimalist design per user preference [[memory:2532226]]
- Entire system uses Arabic by default [[memory:2513489]]
- Automatic error recovery on network failure
- Clean state management using StatefulWidget
- Proper resource cleanup in dispose()

## Security Considerations

1. **Token Management**
   - Auth tokens stored securely in SharedPreferences
   - Tokens sent via Authorization headers

2. **GitHub Integration**
   - Optional GitHub tokens can be stored securely
   - Repo URLs are user-configured
   - No hardcoded credentials

3. **Input Validation**
   - Empty code detection
   - Filename validation
   - Language selection validation

## Performance

- Lazy loading of user data
- Efficient state updates
- Minimal widget rebuilds
- Proper stream/async handling

---

**Version:** 1.0.0  
**Date:** October 24, 2025  
**Author:** AI Assistant  
**Status:** Complete & Tested
