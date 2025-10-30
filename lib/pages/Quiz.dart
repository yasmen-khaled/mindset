import 'package:flutter/material.dart';
import 'Result.dart'; // Import result page
import 'games.dart'; // Import GamesPage
import 'dart:async';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({Key? key}) : super(key: key);

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  int currentQuestion = 0; // Start from 0
  final int totalQuestions = 5; // 5 questions total
  bool isCompleted = false;

  int remainingSeconds = 60; // 60 seconds total
  Timer? _timer;
  bool canGoToResult = false;
  int _selectedIndex = 1; // Start with home selected

  // Code question state
  final TextEditingController _filenameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _repoUrlController = TextEditingController();
  bool _isSubmitting = false;
  String? _submitMessage;
  int? _submitScore;
  String? _currentRepoUrl;
  // Map<String, dynamic>? _submitChecks; // reserved for future detailed check display

  @override
  void initState() {
    super.initState();
    _startTimer();
    _loadRepoUrl();
  }

  Future<void> _loadRepoUrl() async {
    final repoUrl = await StorageService.getRepoUrl();
    setState(() {
      _currentRepoUrl = repoUrl;
      _repoUrlController.text = repoUrl ?? '';
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        setState(() {
          canGoToResult = true;
        });
        // Auto navigate to result page when total time is up
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ResultPage()),
        ).then((result) {
          // When user returns from result page, go back to tasks page
          if (result == true) {
            Navigator.pop(context, true);
          }
        });
      }
    });
  }

  void _moveToNextQuestion() {
    if (currentQuestion < totalQuestions - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      // All questions completed
      _timer?.cancel();
      setState(() {
        isCompleted = true;
        canGoToResult = true;
      });
      // Auto navigate to result page
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ResultPage()),
      ).then((result) {
        // When user returns from result page, go back to tasks page
        if (result == true) {
          Navigator.pop(context, true);
        }
      });
    }
  }



  @override
  void dispose() {
    _timer?.cancel();
    _filenameController.dispose();
    _codeController.dispose();
    _repoUrlController.dispose();
    super.dispose();
  }

  String get timerText {
    final minutes = (remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  String _getQuestionText() {
    final questions = [
      'What is the most important factor in developing a positive mindset?',
      'Which technique helps you reframe negative thoughts?',
      'How often should you practice gratitude exercises?',
      'Code Task: Write a Dart function sum(a, b) that returns a+b.',
      'Which habit contributes most to mental resilience?',
    ];
    return questions[currentQuestion];
  }

  String _getAnswerText(int optionIndex) {
    final answers = [
      // Question 1 answers
      [
        'A) Self-awareness and mindfulness',
        'B) Avoiding all negative situations',
        'C) Constant positive affirmations',
        'D) Ignoring problems completely'
      ],
      // Question 2 answers
      [
        'A) Cognitive behavioral therapy techniques',
        'B) Suppressing all negative emotions',
        'C) Distraction and avoidance',
        'D) Blaming external circumstances'
      ],
      // Question 3 answers
      [
        'A) Daily, preferably in the morning',
        'B) Only when feeling sad',
        'C) Once a week is enough',
        'D) Only during holidays'
      ],
      // Question 4 answers
      [
        'A) Learn from the experience and adapt',
        'B) Give up and avoid similar situations',
        'C) Blame others for the setback',
        'D) Pretend the setback never happened'
      ],
      // Question 5 answers
      [
        'A) Regular self-reflection and growth',
        'B) Avoiding all challenges',
        'C) Seeking constant validation',
        'D) Comparing yourself to others'
      ],
    ];
    return answers[currentQuestion][optionIndex];
  }

  void answerQuestion() {
    // When user answers, move to next question immediately
    _moveToNextQuestion();
  }

  bool _isCodeQuestion() {
    // Here, index 3 is a code question
    return currentQuestion == 3;
  }

  Future<void> _executeCode() async {
    if (_isSubmitting) return;
    final filename = _filenameController.text.trim();
    final code = _codeController.text;
    if (filename.isEmpty || code.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter filename and code')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
      _submitMessage = null;
      _submitScore = null;
      // _submitChecks = null;
    });

    final token = await StorageService.getToken() ?? '';
    final phone = await StorageService.getPhoneNumber() ?? '';
    final repoUrl = await StorageService.getRepoUrl() ?? '';
    final ghToken = await StorageService.getGithubToken() ?? '';
    final resp = await ApiService.submitCode(
      token: token,
      code: code,
      filename: filename,
      language: 'dart',
      taskId: 'quiz_q${currentQuestion + 1}',
      xPhone: phone,
      repoUrl: repoUrl,
      githubToken: ghToken,
    );

    setState(() {
      _isSubmitting = false;
      _submitMessage = resp['message'];
      _submitScore = resp['score'];
      // _submitChecks = resp['checks'] != null ? Map<String, dynamic>.from(resp['checks']) : null;
    });

    // Auto-next after short delay
    await Future.delayed(Duration(milliseconds: 800));
    _moveToNextQuestion();
  }

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
      backgroundColor: const Color(0xFF0D47A1),
      body: SafeArea(
        child: Column(
          children: [
            // الشريط العلوي (نجوم، شخصية، قلوب)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
              child: Row(
                children: [
                  // نجوم
                  Row(
                    children: [
                      Icon(Icons.star, color: Colors.blue[200], size: 32),
                      SizedBox(width: 4),
                      Text('30', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Spacer(),
                  // شخصية (أيقونة افتراضية)
                  CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 22,
                    child: Icon(Icons.emoji_emotions, color: Colors.blue[700], size: 32),
                  ),
                  SizedBox(width: 12),
                  // نسبة مئوية
                  Text('200%', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  SizedBox(width: 16),
                  // قلوب
                  Row(
                    children: [
                      Icon(Icons.favorite, color: Colors.cyanAccent, size: 28),
                      SizedBox(width: 4),
                      Text('5', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Spacer(),
                  // إعدادات
                  Icon(Icons.settings, color: Colors.white, size: 28),
                ],
              ),
            ),
            // مربع السؤال في المنتصف
            Expanded(
              child: Center(
                child: isCompleted
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.9,
                            padding: EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(28),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.emoji_emotions, color: Colors.green, size: 60),
                                SizedBox(height: 16),
                                Text(
                                  'مبروك! لقد أنهيت جميع الأسئلة بنجاح.',
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blue[900]),
                                  textAlign: TextAlign.center,
                                ),
                                SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.emoji_emotions, color: Colors.amber, size: 40),
                                    SizedBox(width: 8),
                                    Icon(Icons.emoji_emotions, color: Colors.blue, size: 40),
                                    SizedBox(width: 8),
                                    Icon(Icons.emoji_emotions, color: Colors.pink, size: 40),
                                  ],
                                ),
                                SizedBox(height: 32),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  icon: Icon(Icons.home, color: Colors.white, size: 28),
                                  label: Text('العودة للرئيسية', style: TextStyle(fontSize: 18, color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue[700],
                                    padding: EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )
                    : Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // رأس السؤال: رقم السؤال، شريط التقدم، المؤقت
                            Row(
                              children: [
                                Text('${currentQuestion + 1}/$totalQuestions', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.bold)),
                                SizedBox(width: 8),
                                Expanded(
                                  child: LinearProgressIndicator(
                                    value: (currentQuestion + 1) / totalQuestions,
                                    backgroundColor: Colors.grey[300],
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                                    minHeight: 8,
                                  ),
                                ),
                                SizedBox(width: 8),
                                // Overall timer
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.red[100],
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.timer, size: 16, color: Colors.red[700]),
                                      SizedBox(width: 2),
                                      Text(timerText, style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold, fontSize: 12)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 24),
                            // Question text
                            Text(
                              _getQuestionText(),
                              style: TextStyle(fontSize: 16, color: Colors.black, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24),
                            // Answers or code editor depending on question type
                            if (!_isCodeQuestion())
                              Column(
                                children: [
                                  for (int i = 0; i < 4; i++)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                                      child: Container(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          onPressed: answerQuestion,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            elevation: 2,
                                            padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(16),
                                              side: BorderSide(color: Colors.grey[300]!, width: 1.5),
                                            ),
                                          ),
                                          child: Container(
                                            width: double.infinity,
                                            child: Text(
                                              _getAnswerText(i),
                                              style: TextStyle(
                                                color: Colors.black,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                              textAlign: TextAlign.left,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                ],
                              )
                            else
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Repo is configured in Profile → GitHub Repository
                                  if (_currentRepoUrl != null && _currentRepoUrl!.isNotEmpty) ...[
                                    Text('Using repo: $_currentRepoUrl', style: TextStyle(color: Colors.green[700], fontSize: 12)),
                                    SizedBox(height: 12),
                                  ],
                                  TextField(
                                    controller: _filenameController,
                                    decoration: InputDecoration(
                                      hintText: 'filename.dart',
                                      prefixIcon: Icon(Icons.insert_drive_file_outlined),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide(color: Colors.grey[300]!),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  Container(
                                    constraints: BoxConstraints(minHeight: 140),
                                    child: TextField(
                                      controller: _codeController,
                                      maxLines: null,
                                      style: TextStyle(fontFamily: 'monospace'),
                                      decoration: InputDecoration(
                                        hintText: 'Write your Dart code here...\nExample:\nint sum(int a, int b) {\n  return a + b;\n}',
                                        alignLabelWithHint: true,
                                        filled: true,
                                        fillColor: Colors.grey[50],
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(12),
                                          borderSide: BorderSide(color: Colors.grey[300]!),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    height: 48,
                                    child: ElevatedButton.icon(
                                      onPressed: _isSubmitting ? null : _executeCode,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue[700],
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                      ),
                                      icon: _isSubmitting
                                          ? SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                          : Icon(Icons.play_arrow_rounded, color: Colors.white),
                                      label: Text(_isSubmitting ? 'Executing...' : 'Execute & Submit', style: TextStyle(color: Colors.white)),
                                    ),
                                  ),
                                  if (_submitMessage != null) ...[
                                    const SizedBox(height: 8),
                                    Text(_submitMessage!, style: TextStyle(color: Colors.green[800], fontWeight: FontWeight.w600)),
                                  ],
                                  if (_submitScore != null) ...[
                                    const SizedBox(height: 4),
                                    Text('Score: ${_submitScore}', style: TextStyle(color: Colors.black87)),
                                  ],
                                ],
                              ),
                          ],
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
      ),
    );
  }
}
