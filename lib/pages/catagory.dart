import 'package:flutter/material.dart';
import 'tasks.dart';
import 'games.dart';

class LevelTopicsPage extends StatelessWidget {
  const LevelTopicsPage({Key? key}) : super(key: key);

  Widget _buildNavIcon({
    required IconData icon,
    required Color color,
    required bool isHome,
  }) {
    return StatefulBuilder(
      builder: (context, setState) {
        bool isPressed = false;
        return GestureDetector(
          onTapDown: (_) => setState(() => isPressed = true),
          onTapUp: (_) => setState(() => isPressed = false),
          onTapCancel: () => setState(() => isPressed = false),
              onTap: () {
                if (isHome) {
                  Navigator.pushReplacementNamed(context, '/home');
                } else if (icon == Icons.games) {
              // Navigate to games page
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => GamesPage()),
              );
            } else if (icon == Icons.emoji_events) {
              // Navigate to leaderboard/achievements (you can implement this later)
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Leaderboard coming soon!'),
                  backgroundColor: Colors.blue,
                ),
              );
            }
          },
          child: TweenAnimationBuilder(
            duration: Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1, end: isPressed ? 1.2 : 1),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  padding: EdgeInsets.all(isHome ? 16 : 12),
                  decoration: BoxDecoration(
                    color: Colors.cyan.withOpacity(0.2),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: isPressed ? color.withOpacity(0.5) : color.withOpacity(0.3),
                        spreadRadius: isPressed ? 4 : 2,
                        blurRadius: isPressed ? 12 : 8,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: isHome ? 40 : 30,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // استخدم متغير لحفظ حالة المراحل المفتوحة
    // المرحلة الأولى دائماً مفتوحة، والباقي تفتح عند إنهاء السابقة
    List<bool> unlockedLevels = List.generate(6, (i) => i == 0);

    return StatefulBuilder(
      builder: (context, setState) {
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
                  // Title
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: Text(
                      'title here',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Level list
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
                            double progress = index == 0 ? 0.8 :
                                              index == 1 ? 0.4 : 0.0;
                            bool isUnlocked = unlockedLevels[index];

                            return GestureDetector(
                              onTap: isUnlocked
                                  ? () async {
                                      // انتقل إلى صفحة التفاصيل وانتظر العودة
                                      final result = await Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LevelDetailPage(
                                            levelIndex: index,
                                            levelTitle: index == 0 ? 'Level One: Positive Thinking' :
                                                      index == 1 ? 'Level Two: Self Confidence' :
                                                      index == 2 ? 'Level Three: Time Management' :
                                                      index == 3 ? 'Level Four: Communication' :
                                                      index == 4 ? 'Level Five: Problem Solving' :
                                                      'Level Six: Leadership',
                                            isLevelCompleted: progress >= 1.0,
                                          ),
                                        ),
                                      );
                                      // إذا أنهى المستخدم المرحلة، افتح المرحلة التالية
                                      if (result == true && index + 1 < unlockedLevels.length) {
                                        setState(() {
                                          unlockedLevels[index + 1] = true;
                                        });
                                        // Return to home page with completion result, passing the completed level index
                                        Navigator.pop(context, index + 1); // Return the newly unlocked level number
                                      }
                                    }
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        // Coin
                                        Container(
                                          width: 40,
                                          height: 40,
                                          decoration: BoxDecoration(
                                            color: Colors.amber,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Progress section
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Level Title
                                              Text(
                                                index == 0 ? 'Level One: Positive Thinking' :
                                                index == 1 ? 'Level Two: Self Confidence' :
                                                index == 2 ? 'Level Three: Time Management' :
                                                index == 3 ? 'Level Four: Communication' :
                                                index == 4 ? 'Level Five: Problem Solving' :
                                                'Level Six: Leadership',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              SizedBox(height: 8),
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
                                              SizedBox(height: 4),
                                              // Stats
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
                                                    Icon(Icons.star, color: Colors.yellow, size: 16),
                                                    SizedBox(width: 4),
                                                    Text(
                                                      index == 0 ? '100,000' : 
                                                      index == 1 ? '13' : '0',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                      ),
                                                    ),
                                                    SizedBox(width: 12),
                                                    Icon(Icons.star, color: Colors.yellow, size: 16),
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
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        // Lock icon or check status
                                        if (!isUnlocked)
                                          Icon(Icons.lock, color: Colors.amber)
                                        else
                                          Container(
                                            width: 35,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: progress >= 1.0 ? Colors.white.withOpacity(0.1) : Colors.transparent,
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(
                                                color: progress >= 1.0 ? Colors.white : Colors.grey.withOpacity(0.3),
                                                width: 2.5,
                                              ),
                                            ),
                                            child: Container(
                                              margin: EdgeInsets.all(2),
                                              decoration: BoxDecoration(
                                                color: progress >= 1.0 ? Colors.white : Colors.transparent,
                                                borderRadius: BorderRadius.circular(6),
                                                border: Border.all(
                                                  color: progress >= 1.0 ? Colors.white : Colors.grey.withOpacity(0.3),
                                                  width: 2,
                                                ),
                                                boxShadow: progress >= 1.0 ? [
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.9),
                                                    spreadRadius: 2,
                                                    blurRadius: 6,
                                                    offset: Offset(0, 0),
                                                  ),
                                                  BoxShadow(
                                                    color: Colors.white.withOpacity(0.5),
                                                    spreadRadius: 3,
                                                    blurRadius: 10,
                                                    offset: Offset(0, 0),
                                                  ),
                                                ] : null,
                                              ),
                                              child: Icon(
                                                Icons.check,
                                                size: 18,
                                                color: progress >= 1.0 ? Colors.black : Colors.grey.withOpacity(0.3),
                                              ),
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

                  // Bottom navigation
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildNavIcon(
                          icon: Icons.emoji_events,
                          color: Colors.cyan,
                          isHome: false,
                        ),
                        _buildNavIcon(
                          icon: Icons.home,
                          color: Colors.cyan,
                          isHome: true,
                        ),
                        _buildNavIcon(
                          icon: Icons.games,
                          color: Colors.cyan,
                          isHome: false,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}