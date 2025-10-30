# Task Description Feature - Complete Guide

## Overview

The Task IDE now includes comprehensive task descriptions with:
- **Task Question** - The detailed problem statement
- **Requirements** - A checklist of what the solution must do
- **Examples** - Input/output examples to clarify expectations

This feature helps users understand exactly what they need to build before they start coding.

---

## UI Layout

The task IDE now displays information in this order:

```
┌─────────────────────────────────────┐
│ Header: Task Title & Code Editor    │
├─────────────────────────────────────┤
│ Task Description (Brief overview)   │
├─────────────────────────────────────┤
│ Task Question (Problem statement)   │  ← NEW: BLUE CONTAINER
├─────────────────────────────────────┤
│ Requirements (Checklist)            │  ← NEW: GREEN CONTAINER
├─────────────────────────────────────┤
│ Example (Input & Output)            │  ← NEW: ORANGE CONTAINER
├─────────────────────────────────────┤
│ Language & Filename selectors       │
├─────────────────────────────────────┤
│ Code Editor (Main editing area)     │
├─────────────────────────────────────┤
│ GitHub Repo Info                    │
├─────────────────────────────────────┤
│ Submit Solution Button              │
└─────────────────────────────────────┘
```

---

## TaskIDEPage Constructor Parameters

### Required Parameters

```dart
taskId: String              // Unique identifier for the task
taskTitle: String           // Display title
taskDescription: String     // Brief description
```

### Optional Parameters (NEW)

```dart
taskQuestion: String?                    // Detailed problem statement
requirements: List<String>?              // List of requirements
exampleInput: String?                    // Example input format
exampleOutput: String?                   // Expected output
```

---

## Usage Example

```dart
TaskIDEPage(
  taskId: 'task_1',
  taskTitle: 'Level One: Positive Thinking - Task 1',
  taskDescription: 'Complete the coding task to demonstrate your understanding.',
  
  // NEW: Task Question
  taskQuestion: 'Write a function that takes a list of positive affirmations and returns them in reverse order with each affirmation capitalized.',
  
  // NEW: Requirements List
  requirements: [
    'Function must accept a list of strings',
    'Return a new list with items in reverse order',
    'Each affirmation must be fully capitalized',
    'Handle empty lists gracefully',
    'Function should be named "processAffirmations"',
  ],
  
  // NEW: Examples
  exampleInput: 'input = ["stay positive", "believe in yourself", "you are strong"]',
  exampleOutput: 'output = ["YOU ARE STRONG", "BELIEVE IN YOURSELF", "STAY POSITIVE"]',
)
```

---

## Feature Breakdown

### 1. Task Question Section (Blue)

**Icon:** ❓ Help Outline  
**Color:** Blue (Blue[900] with opacity)

Displays the detailed problem statement that the user needs to solve.

```
┌─ Help Outline ─────────────────┐
│ TASK QUESTION                  │
├────────────────────────────────┤
│ Write a function that takes... │
│ ...and returns them in reverse │
│ ...with each capitalized       │
└────────────────────────────────┘
```

**When it appears:** Only if `taskQuestion` is provided  
**Font:** 12px, white, line height 1.5  
**Visible:** Always (not collapsible)

---

### 2. Requirements Section (Green)

**Icon:** ✓ Checklist  
**Color:** Green (Green[900] with opacity)

Displays a bulleted list of requirements the solution must meet.

```
┌─ Checklist ────────────────────┐
│ REQUIREMENTS                   │
├────────────────────────────────┤
│ • Function must accept list    │
│ • Return new list reversed     │
│ • Capitalize each item         │
│ • Handle empty lists           │
│ • Function name must be exact  │
└────────────────────────────────┘
```

**When it appears:** Only if `requirements` is provided  
**Bullet Style:** Green bullets (•)  
**Font:** 12px, white with 90% opacity  
**Spacing:** 6px between requirements  
**Max Items:** Unlimited (scrollable)

---

### 3. Example Section (Orange)

**Icon:** 📝 Notes  
**Color:** Orange (Orange[900] with opacity)

Displays example input and expected output to clarify task expectations.

```
┌─ Notes ────────────────────────┐
│ EXAMPLE                        │
├────────────────────────────────┤
│ Input:                         │
│ ┌──────────────────────────┐   │
│ │ input = ["stay positive",│   │
│ │  "believe in yourself",  │   │
│ │  "you are strong"]       │   │
│ └──────────────────────────┘   │
│                                │
│ Expected Output:               │
│ ┌──────────────────────────┐   │
│ │ output = ["YOU ARE      │   │
│ │  STRONG", "BELIEVE IN   │   │
│ │  YOURSELF", "STAY       │   │
│ │  POSITIVE"]             │   │
│ └──────────────────────────┘   │
└────────────────────────────────┘
```

**When it appears:** Only if both `exampleInput` AND `exampleOutput` are provided  
**Font:** 11px monospace (Courier)  
**Input Background:** Black with 30% opacity  
**Output Background:** Black with 30% opacity  
**Labels:** Orange[200] color

---

## Color Coding

| Section | Color | Icon | Purpose |
|---------|-------|------|---------|
| Question | Blue | ❓ | Understand the problem |
| Requirements | Green | ✓ | Know what to implement |
| Example | Orange | 📝 | See expected behavior |
| Code Editor | Dark Gray | - | Write solution |

---

## Styling Details

### Task Question Container
- Background: `Colors.blue[900]?.withOpacity(0.3)`
- Border: 1px `Colors.blue.withOpacity(0.5)`
- Radius: 12px
- Padding: 12px all sides

### Requirements Container
- Background: `Colors.green[900]?.withOpacity(0.2)`
- Border: 1px `Colors.green.withOpacity(0.4)`
- Radius: 12px
- Padding: 12px all sides
- Item Spacing: 6px bottom

### Example Container
- Background: `Colors.orange[900]?.withOpacity(0.2)`
- Border: 1px `Colors.orange.withOpacity(0.4)`
- Radius: 12px
- Padding: 12px all sides
- Code Background: `Colors.black.withOpacity(0.3)`

---

## Best Practices

### Writing Task Questions
✓ Be specific and clear  
✓ Explain what the function/code should do  
✓ Mention any edge cases  
✓ Keep it concise but complete

Example:
```
"Write a function that converts a string to uppercase and removes all vowels."
```

### Writing Requirements
✓ Use bullet points  
✓ Each requirement should be testable  
✓ Be specific about function names, types  
✓ Include error handling requirements  
✓ Mention performance considerations if relevant

Examples:
```
• Function must be named "processString"
• Accept string parameter
• Return uppercase string
• Remove all vowels (a, e, i, o, u, A, E, I, O, U)
• Handle null input gracefully
• Preserve word spacing
```

### Writing Examples
✓ Use realistic examples  
✓ Show both simple and complex cases  
✓ Format clearly with proper syntax  
✓ Show complete input and output  
✓ Include data structure format

Examples:
```
Input:  input = ["apple", "banana", "cherry"]
Output: output = ["APPLE", "BANANA", "CHERRY"]
```

---

## Implementation Notes

### Conditional Rendering
Each section only renders if its data is provided:

```dart
if (widget.taskQuestion != null) {
  // Show Task Question
}

if (widget.requirements != null && widget.requirements!.isNotEmpty) {
  // Show Requirements
}

if (widget.exampleInput != null && widget.exampleOutput != null) {
  // Show Example
}
```

### Spacing
- Between sections: 12-16px `SizedBox`
- Inside sections: 8-12px padding
- Between list items: 6px

### Scrolling
All sections are within a `SingleChildScrollView` so they scroll together with the code editor and other elements.

---

## Future Enhancements

- [ ] Collapsible sections
- [ ] Copy example code to editor
- [ ] Test cases visualization
- [ ] Hints system
- [ ] Difficulty level badge
- [ ] Time estimate display
- [ ] Video tutorial link

---

## Compatibility

- **Dart Version:** 3.0+
- **Flutter Version:** 3.10+
- **Min SDK:** Android 21, iOS 11

---

## Support

For questions about task descriptions, refer to:
- `docs/TASK_IDE_IMPLEMENTATION.md` - Full technical details
- `docs/TASK_IDE_QUICK_START.md` - User guide
- `lib/pages/task_ide.dart` - Source code

---

**Version:** 1.0.0  
**Last Updated:** October 24, 2025  
**Status:** Production Ready ✅
