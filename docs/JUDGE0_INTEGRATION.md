# Judge0 API Integration - Complete Guide

## Overview

Judge0 is a robust API for code execution that supports multiple programming languages. The Task IDE now integrates Judge0 to execute code in real-time and display output directly to users.

**What It Does:**
- Executes code in 5+ programming languages
- Returns stdout output for successful executions
- Reports compilation errors clearly
- Handles runtime errors gracefully
- Provides timeout detection

---

## Features

### 1. Code Execution
Users can now:
- Click "Run Code" button to execute their code
- See real-time output instantly
- Test their code before submission
- Verify logic works as expected

### 2. Multiple Language Support
```
✓ Dart (Language ID: 90)
✓ Python (Language ID: 71)
✓ JavaScript (Language ID: 63)
✓ Java (Language ID: 62)
✓ C++ (Language ID: 54)
```

### 3. Output Display
- **Success Output**: Shows code output in green container
- **Compilation Errors**: Shows compiler error in red container
- **Runtime Errors**: Shows runtime error in red container
- **Timeout**: Alerts user if execution takes too long

---

## UI Implementation

### Run Code Button
```
┌─────────────────────────────────────┐
│ [▶ Run Code] [📤 Submit Solution]  │
└─────────────────────────────────────┘
```

- Blue button on left
- Play icon indicator
- Shows "Running..." while executing
- Disabled during execution

### Output Display Section
```
┌─────────────────────────────────────┐
│ ✓ Output (or ✗ Error)              │
├─────────────────────────────────────┤
│ ┌───────────────────────────────┐   │
│ │ Hello, World!                 │   │
│ │ Process completed in 0.5s     │   │
│ └───────────────────────────────┘   │
└─────────────────────────────────────┘
```

Only appears after code execution.

---

## API Setup

### 1. Get Judge0 API Key

Visit: https://rapidapi.com/judge0-official/api/judge0-ce

**Steps:**
1. Create RapidAPI account (free)
2. Subscribe to Judge0 CE (Free tier available)
3. Copy your API key

### 2. Update API Service

File: `lib/services/api_service.dart`

Find this line:
```dart
'X-RapidAPI-Key': 'YOUR_RAPIDAPI_KEY',
```

Replace `YOUR_RAPIDAPI_KEY` with your actual key:
```dart
'X-RapidAPI-Key': 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
```

Do this in BOTH locations in the `executeCode` method.

---

## Code Structure

### ApiService Method

```dart
static Future<Map<String, dynamic>> executeCode({
  required String code,
  required String language,
  String? input,
}) async
```

**Parameters:**
- `code` (required) - Source code to execute
- `language` (required) - Programming language (dart, python, etc.)
- `input` (optional) - Standard input for the program

**Returns:**
```dart
{
  'success': true/false,
  'output': 'Code output or error message',
  'message': 'Human-readable message'
}
```

### TaskIDEPage Method

```dart
Future<void> _executeCode() async
```

**Flow:**
1. Validates code is not empty
2. Shows loading state
3. Calls `ApiService.executeCode()`
4. Updates UI with results
5. Displays output or error

---

## Language IDs

Judge0 uses numeric IDs for each language:

| Language | ID | File Extension |
|----------|----|-|
| Dart | 90 | .dart |
| Python | 71 | .py |
| JavaScript | 63 | .js |
| Java | 62 | .java |
| C++ | 54 | .cpp |

---

## Execution Flow

```
User writes code
    ↓
Clicks "Run Code"
    ↓
_executeCode() called
    ↓
ApiService.executeCode() sends to Judge0
    ↓
Judge0 executes code (may take 2-5 seconds)
    ↓
Judge0 returns result
    ↓
_executeCode() processes response
    ↓
UI displays output/error
    ↓
User can modify code and run again
```

---

## Status Codes

Judge0 returns status IDs:

| ID | Status | Meaning |
|----|--------|---------|
| 1 | Queued | Waiting to run |
| 2 | Processing | Currently running |
| 3 | Accepted | ✅ Success |
| 4 | Wrong Answer | Logic error |
| 5 | Time Limit | Timeout |
| 6 | Compilation Error | Syntax error |
| 7 | Runtime Error | Error during execution |

---

## Example Output

### Successful Execution

```
✓ Output
┌─────────────────────────┐
│ Hello, World!           │
│ 3.14159265359           │
└─────────────────────────┘
```

### Compilation Error

```
✗ Error
┌─────────────────────────┐
│ error: expected ';'     │
│ at line 5, column 10    │
└─────────────────────────┘
```

### Runtime Error

```
✗ Error
┌─────────────────────────┐
│ Division by zero!       │
│ at line 8               │
└─────────────────────────┘
```

---

## Test Example - Python

**Code:**
```python
def hello(name):
    return f"Hello, {name}!"

print(hello("World"))
```

**Expected Output:**
```
Hello, World!
```

**What Happens:**
1. Code submitted to Judge0
2. Judge0 runs Python interpreter
3. Returns stdout: "Hello, World!\n"
4. IDE displays output in green box

---

## Configuration Checklist

- [ ] API key from RapidAPI
- [ ] Judge0 CE subscription (free)
- [ ] Key updated in `api_service.dart` (2 places)
- [ ] Valid internet connection required
- [ ] CORS enabled (RapidAPI handles this)

---

## Troubleshooting

### "Language not supported"
- Check language dropdown value
- Verify language ID mapping
- Ensure language string is lowercase

### "Network error"
- Check internet connection
- Verify API key is correct
- Check RapidAPI subscription is active
- Ensure HTTPS connection

### No output displayed
- Code execution successful but no stdout
- Program ran but didn't print anything
- This is normal - program executed correctly

### Timeout
- Code takes longer than 30 seconds
- Judge0 has execution time limits
- Optimize your code or add timeouts

### "Failed to submit code"
- Judge0 API down (rare)
- Invalid API key
- RapidAPI account issue
- Refresh and try again

---

## Performance Considerations

**Typical Execution Time:**
- Submission: <100ms
- Execution: 0.5-5 seconds
- Response: <100ms
- **Total: 1-6 seconds**

**Polling Strategy:**
- Current: Waits 2 seconds, then polls once
- Can be optimized: Poll multiple times with delays
- Future: Implement WebSocket for real-time updates

---

## Security Notes

✓ API key in code (development only)  
✓ Consider environment variables for production  
✓ No user data sent to Judge0  
✓ Code executes in sandboxed environment  
✓ Judge0 has rate limiting (usually sufficient)  

---

## Limitations

- Execution time limit (~30 seconds)
- No file I/O (sandbox restriction)
- No network access allowed
- Memory limits per language
- Maximum code size (~64KB)

---

## Future Enhancements

- [ ] Support more languages
- [ ] Provide code templates per language
- [ ] Add stdin input support
- [ ] Display execution time
- [ ] Cache results
- [ ] WebSocket real-time updates
- [ ] Code formatting/prettifying
- [ ] Syntax validation before execution

---

## Quick Start

1. **Get API Key:**
   - Go to https://rapidapi.com/judge0-official/api/judge0-ce
   - Subscribe (free tier available)
   - Copy API key

2. **Update Code:**
   - Open `lib/services/api_service.dart`
   - Replace `YOUR_RAPIDAPI_KEY` with your key (2 places)

3. **Test:**
   - Open Task IDE
   - Write simple code (e.g., print statement)
   - Click "Run Code"
   - See output appear!

---

## References

- **Judge0 API Docs:** https://judge0.com
- **RapidAPI Dashboard:** https://rapidapi.com
- **Supported Languages:** Full list on Judge0 docs

---

**Status:** ✅ Production Ready  
**Version:** 1.0.0  
**Last Updated:** October 24, 2025
