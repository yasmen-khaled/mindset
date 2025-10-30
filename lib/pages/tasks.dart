import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'Quiz.dart'; // Import QuizPage instead
import 'games.dart'; // Import GamesPage
import 'task_ide.dart'; // Import TaskIDEPage

class LevelDetailPage extends StatefulWidget {
  final int levelIndex;
  final String levelTitle;
  final bool isLevelCompleted;
  final int completedTasksCount; // Number of completed tasks

  const LevelDetailPage({
    Key? key,
    required this.levelIndex,
    required this.levelTitle,
    this.isLevelCompleted = false,
    this.completedTasksCount = 0, // Default to 0 completed tasks
  }) : super(key: key);

  @override
  State<LevelDetailPage> createState() => _LevelDetailPageState();
}

class _LevelDetailPageState extends State<LevelDetailPage> {
  int _selectedIndex = 1; // Start with home selected

  void _onNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    if (index == 0) {
      // Show leaderboard coming soon
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Leaderboard coming soon!'),
          backgroundColor: Colors.blue,
        ),
      );
      return;
    }
    
    if (index == 1) {
      // Navigate to home page
      Navigator.of(context).popUntil((route) => route.isFirst);
      return;
    }
    
    if (index == 2) {
      // Navigate to games page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GamesPage(),
        ),
      );
      return;
    }
  }

  Widget _buildNavButton(IconData icon, {bool isSelected = false, bool isHome = false, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(isHome ? 24 : 20),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected 
            ? const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(isHome ? 30 : 25),
          border: Border.all(
            color: isSelected 
              ? const Color.fromARGB(255, 33, 150, 243)
              : Colors.white.withOpacity(0.2),
            width: isHome ? 3 : 2,
          ),
          boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color.fromARGB(255, 33, 150, 243).withOpacity(0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                )
              ]
            : [],
        ),
        child: Icon(
          icon,
          color: isSelected ? Colors.blue : Colors.white,
          size: isHome ? 48 : 38,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF1E88E5),
                  Color(0xFF0D47A1),
                ],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
              // Back button and title
                  Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Expanded(
                    child: Text(
                        widget.levelTitle,
                      style: TextStyle(
                        color: Colors.white,
                          fontSize: 24,
                        fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(width: 48), // Balance the back button
                  ],
                    ),
                  ),

              // Level content
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white,
                            width: 2.0,
                          ),
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: 6,
                          itemBuilder: (context, index) {
                        bool isUnlocked = index == 0;
                        double progress = index == 0 ? 0.8 : 0.0;
                        bool isFirstLevel = index == 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GestureDetector(
                              onTap: isUnlocked
                                ? () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => Dialog(
                                        backgroundColor: Colors.transparent,
                                        insetPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 40),
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.blue[900]?.withOpacity(0.98),
                                            borderRadius: BorderRadius.circular(24),
                                            border: Border.all(color: Colors.white, width: 2),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(0.3),
                                                blurRadius: 16,
                                                spreadRadius: 2,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              const SizedBox(height: 24),
                                              // Title
                                              Text(
                                                'Positive Thinking: Building Resilience',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 22,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                                textAlign: TextAlign.center,
                                              ),
                                              const SizedBox(height: 18),
                                              
                                              // Progress and stats bar
                                              Container(
                                                margin: EdgeInsets.symmetric(horizontal: 24),
                                                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                                decoration: BoxDecoration(
                                                  color: Colors.deepPurple[400]?.withOpacity(0.7),
                                                  borderRadius: BorderRadius.circular(16),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.monetization_on, color: Colors.yellow, size: 28),
                                                    SizedBox(width: 8),
                                                    Expanded(
                                                      child: LinearProgressIndicator(
                                                        value: 0.1,
                                                        backgroundColor: Colors.blue[900],
                                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                                        minHeight: 8,
                                                      ),
                                                    ),
                                                    SizedBox(width: 8),
                                                    SvgPicture.asset(
                                                      'Assets/items/smart.svg',
                                                      width: 22,
                                                      height: 22,
                                                      color: Colors.white,
                                                    ),
                                                    SizedBox(width: 2),
                                                    Text('30', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                    SizedBox(width: 8),
                                                    Text('10%', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                    SizedBox(width: 8),
                                                    // Non-clickable checkbox for video completion tracking
                                                    Container(
                                                      width: 24,
                                                      height: 24,
                                                      decoration: BoxDecoration(
                                                        border: Border.all(color: Colors.white, width: 2),
                                                        borderRadius: BorderRadius.circular(6),
                                                        color: Colors.transparent,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 20),
                                              
                                              // Character guide section
                                              Row(
                                                children: [
                                                  const SizedBox(width: 24),
                                                  // Nadir character
                                                  Container(
                                                    width: 60,
                                                    height: 60,
                                                    decoration: BoxDecoration(
                                                      color: Colors.white.withOpacity(0.1),
                                                      borderRadius: BorderRadius.circular(30),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(8.0),
                                                      child: SvgPicture.asset(
                                                        'Assets/charcters/nadir.svg',
                                                        width: 44,
                                                        height: 44,
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 12),
                                                  // Guide text
                                                  Expanded(
                                                    child: Container(
                                                      padding: EdgeInsets.all(12),
                                                      decoration: BoxDecoration(
                                                        color: Colors.white.withOpacity(0.1),
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      child: Text(
                                                        'Hi! I\'m Nadir, your guide. Watch this video to learn about building positive thinking habits!',
                                                        style: TextStyle(color: Colors.white, fontSize: 13),
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 24),
                                                ],
                                              ),
                                              const SizedBox(height: 20),
                                              
                                              // Video thumbnail (clickable)
                                              GestureDetector(
                                                onTap: () {
                                                  // Navigate to video player
                                                  Navigator.pop(context); // Close dialog first
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Opening video player...'),
                                                      backgroundColor: Colors.green,
                                                    ),
                                                  );
                                                  // TODO: Add video player navigation here
                                                },
                                                child: Container(
                                                  width: 200,
                                                  height: 120,
                                                  decoration: BoxDecoration(
                                                    color: Colors.black,
                                                    borderRadius: BorderRadius.circular(16),
                                                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                                                  ),
                                                  child: Stack(
                                                    alignment: Alignment.center,
                                                    children: [
                                                      // Video thumbnail background
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(14),
                                                          gradient: LinearGradient(
                                                            begin: Alignment.topLeft,
                                                            end: Alignment.bottomRight,
                                                            colors: [
                                                              Colors.blue.withOpacity(0.3),
                                                              Colors.purple.withOpacity(0.3),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                      // Play button
                                                      Container(
                                                        width: 50,
                                                        height: 50,
                                                        decoration: BoxDecoration(
                                                          color: Colors.white.withOpacity(0.9),
                                                          shape: BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.play_arrow,
                                                          color: Colors.blue[900],
                                                          size: 30,
                                                        ),
                                                      ),
                                                      // Duration badge
                                                      Positioned(
                                                        bottom: 8,
                                                        right: 8,
                                                        child: Container(
                                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                                          decoration: BoxDecoration(
                                                            color: Colors.black.withOpacity(0.7),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: Text(
                                                            '5:42',
                                                            style: TextStyle(color: Colors.white, fontSize: 12),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 18),
                                              
                                              // Video description
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                child: Text(
                                                  'Learn practical techniques to develop a positive mindset and build mental resilience. This video covers cognitive reframing, gratitude practices, and daily habits that promote optimistic thinking patterns.',
                                                  style: TextStyle(
                                                    color: Colors.white.withOpacity(0.9), 
                                                    fontSize: 15, 
                                                    fontWeight: FontWeight.w400,
                                                    height: 1.4,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                              
                                              // Action buttons
                                              Padding(
                                                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                                                child: Row(
                                                  children: [
                                                    // Cancel button
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () => Navigator.pop(context),
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all(Colors.grey[700]),
                                                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
                                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          )),
                                                        ),
                                                        child: Text(
                                                          'Back',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    // Start Task button
                                                    Expanded(
                                                      child: ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(context);
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) => TaskIDEPage(
                                                                taskId: 'task_${index + 1}',
                                                                taskTitle: 'Level One: Positive Thinking - Task ${index + 1}',
                                                                taskDescription: 'Complete the coding task to demonstrate your understanding of the concepts covered in the video.',
                                                                taskQuestion: 'Write a function that takes a list of positive affirmations and returns them in reverse order with each affirmation capitalized.',
                                                                requirements: [
                                                                  'Function must accept a list of strings',
                                                                  'Return a new list with items in reverse order',
                                                                  'Each affirmation must be fully capitalized',
                                                                  'Handle empty lists gracefully',
                                                                  'Function should be named "processAffirmations"',
                                                                ],
                                                                exampleInput: 'input = ["stay positive", "believe in yourself", "you are strong"]',
                                                                exampleOutput: 'output = ["YOU ARE STRONG", "BELIEVE IN YOURSELF", "STAY POSITIVE"]',
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                        style: ButtonStyle(
                                                          backgroundColor: MaterialStateProperty.all(Colors.green[600]),
                                                          padding: MaterialStateProperty.all(EdgeInsets.symmetric(vertical: 12)),
                                                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(12),
                                                          )),
                                                          elevation: MaterialStateProperty.all(4),
                                                        ),
                                                        child: Text(
                                                          'Start Task',
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontSize: 14,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(height: 24),
                                            ],
                                          ),
                                          ),
                                        ),
                                      );
                                    }
                                  : null,
                                child: Container(
                                  decoration: BoxDecoration(
                                color: isFirstLevel ? Colors.grey[800] : Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                border: isFirstLevel ? Border.all(
                                  color: Colors.white.withOpacity(0.8),
                                  width: 2,
                                ) : null,
                                boxShadow: isFirstLevel ? [
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.2),
                                    spreadRadius: 1,
                                    blurRadius: 8,
                                    offset: Offset(0, 0),
                                  ),
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.1),
                                    spreadRadius: 2,
                                    blurRadius: 12,
                                    offset: Offset(0, 0),
                                  ),
                                ] : null,
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                  children: [
                                    // Coin with task number
                                    Stack(
                                      children: [
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ],
                                        ),
                                        SizedBox(width: 12),
                                        // Progress section
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                          if (isFirstLevel) ...[
                                            // Level Title (only for first level)
                                              Text(
                                              'Level One: Positive Thinking',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                          ],
                                              // Progress bar
                                              ClipRRect(
                                                borderRadius: BorderRadius.circular(10),
                                                child: LinearProgressIndicator(
                                                  value: progress,
                                                  backgroundColor: Colors.blue[900],
                                                  valueColor: AlwaysStoppedAnimation<Color>(
                                                    Colors.green,
                                                  ),
                                                  minHeight: 8,
                                                ),
                                              ),
                                          if (isFirstLevel) ...[
                                              SizedBox(height: 4),
                                            // Stats (only for first level)
                                              Container(
                                                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                                decoration: BoxDecoration(
                                                  color: Colors.transparent,
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: Colors.white.withOpacity(0.5),
                                                    width: 2,
                                                  ),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.white.withOpacity(0.2),
                                                      spreadRadius: 1,
                                                      blurRadius: 8,
                                                      offset: Offset(0, 0),
                                                    ),
                                                  ],
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                  Icon(Icons.star, color: Colors.blue, size: 16),
                                                    SizedBox(width: 4),
                                                    Text(
                                                    '100,000',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                  Icon(Icons.star, color: Colors.blue, size: 16),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      '10%',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                            ],
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                    // Status indicator (Lock or Check)
                                          Container(
                                            width: 35,
                                            height: 35,
                                      decoration: BoxDecoration(
                                        color: isFirstLevel 
                                          ? Colors.grey[800]
                                          : (index == 0 
                                            ? Colors.transparent 
                                            : Colors.black.withOpacity(0.3)),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: isFirstLevel 
                                            ? Colors.white.withOpacity(0.8)
                                            : (index == 0 
                                              ? Colors.grey.withOpacity(0.5)
                                              : Colors.amber.withOpacity(0.5)),
                                          width: 2,
                                        ),
                                        boxShadow: isFirstLevel ? [
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.2),
                                            spreadRadius: 1,
                                            blurRadius: 8,
                                            offset: Offset(0, 0),
                                          ),
                                          BoxShadow(
                                            color: Colors.white.withOpacity(0.1),
                                            spreadRadius: 2,
                                            blurRadius: 12,
                                            offset: Offset(0, 0),
                                          ),
                                        ] : null,
                                      ),
                                      child: isFirstLevel && widget.isLevelCompleted
                                        ? Container(
                                            margin: EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[800],
                                              borderRadius: BorderRadius.circular(6),
                                              border: Border.all(
                                                color: Colors.white.withOpacity(0.5),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.2),
                                                  spreadRadius: 1,
                                                  blurRadius: 8,
                                                  offset: Offset(0, 0),
                                                ),
                                                BoxShadow(
                                                  color: Colors.white.withOpacity(0.1),
                                                  spreadRadius: 2,
                                                  blurRadius: 12,
                                                  offset: Offset(0, 0),
                                                ),
                                              ],
                                            ),
                                            child: Icon(
                                              Icons.check,
                                              size: 18,
                                              color: Colors.white.withOpacity(0.8),
                                            ),
                                          )
                                        : index == 0  // This is the level title
                                          ? Container(
                                              margin: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.lightBlue.withOpacity(0.7),
                                                  width: 1.5,
                                                ),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.lightBlue.withOpacity(0.3),
                                                    spreadRadius: 1,
                                                    blurRadius: 8,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ],
                                              ),
                                            )
                                        : index == 1  // First task (Task #2)
                                          ? Container(
                                              margin: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: Colors.transparent,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: Colors.grey.withOpacity(0.3),
                                                  width: 1.5,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.lock,
                                              color: Colors.amber,
                                              size: 20,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

              // Bottom navigation and Done button
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 8),
                  // Done button above navigation
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Container(
                      width: 200, // Fixed width
                      height: 40, // Smaller height
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: widget.isLevelCompleted 
                              ? Colors.red.withOpacity(0.3)
                              : Colors.white.withOpacity(0.3),
                            spreadRadius: 1,
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          ),
                          BoxShadow(
                            color: widget.isLevelCompleted 
                              ? Colors.red.withOpacity(0.2)
                              : Colors.white.withOpacity(0.2),
                            spreadRadius: 2,
                            blurRadius: 12,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: () async {
                          // Navigate to Quiz page
                          await Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => QuizPage()),
                          );
                          // When user returns from quiz (regardless of how), unlock next level
                          Navigator.pop(context, true); // Return true to unlock next level
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all(
                            widget.isLevelCompleted 
                              ? Colors.red 
                              : Color(0xFF4A4A4A),
                          ),
                          shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: widget.isLevelCompleted 
                                ? Colors.red.withOpacity(0.8)
                                : Colors.white.withOpacity(0.8),
                              width: 1.5,
                            ),
                          )),
                          elevation: MaterialStateProperty.all(8),
                          overlayColor: MaterialStateProperty.resolveWith(
                            (states) {
                              if (states.contains(MaterialState.pressed)) {
                                return widget.isLevelCompleted 
                                  ? Colors.red.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1);
                              }
                              return null;
                            },
                          ),
                        ),
                        child: Text(
                          'Done?',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            shadows: [
                              Shadow(
                                color: widget.isLevelCompleted 
                                  ? Colors.red.withOpacity(0.5)
                                  : Colors.white.withOpacity(0.5),
                                offset: Offset(0, 0),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Navigation buttons at bottom
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(
                          color: Colors.white.withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavButton(
                            Icons.emoji_events_outlined,
                            isSelected: _selectedIndex == 0,
                            onTap: () => _onNavTap(0),
                          ),
                          _buildNavButton(
                            Icons.home_rounded,
                            isSelected: _selectedIndex == 1,
                            isHome: true,
                            onTap: () => _onNavTap(1),
                          ),
                          _buildNavButton(
                            Icons.sports_esports_rounded,
                            isSelected: _selectedIndex == 2,
                            onTap: () => _onNavTap(2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}