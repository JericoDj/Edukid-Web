// game_screen.dart
import 'package:flutter/material.dart';
import 'game_controller.dart';

class GameScreen extends StatefulWidget {
  final GameController gameController;

  GameScreen({required this.gameController});

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  String feedback = "";
  bool gameStarted = false;

  void startGame() {
    setState(() {
      gameStarted = true;
      feedback = "";
      widget.gameController.initializeGame();
    });
  }

  void checkAnswer(int userAnswer) {
    bool isCorrect = widget.gameController.checkAnswer(userAnswer);
    setState(() {
      feedback = isCorrect ? "Correct!" : "Incorrect. Try again.";
    });

    if (isCorrect) {
      bool hasNext = widget.gameController.nextQuestion();
      if (!hasNext) {
        setState(() {
          feedback = "Game Over! Your score: ${widget.gameController.currentScore}";
          gameStarted = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = widget.gameController.getCurrentQuestion();
    final options = currentQuestion?['options'] as List<int>?;

    return Scaffold(
      appBar: AppBar(
        title: Text("Game - ${widget.gameController.topic}"),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Playing Game for Level ${widget.gameController.levelIndex + 1}",
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.teal[800]),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Text(
                "Topic: ${widget.gameController.topic}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500, color: Colors.teal),
              ),
              SizedBox(height: 30),

              if (gameStarted && currentQuestion != null) ...[
                Text(
                  currentQuestion['question'],
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                if (options != null)
                  Column(
                    children: options.map((option) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6.0),
                        child: ElevatedButton(
                          onPressed: () => checkAnswer(option),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal[200],
                            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: Text(
                            option.toString(),
                            style: TextStyle(fontSize: 18, color: Colors.teal[900]),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                SizedBox(height: 20),

                Text(
                  feedback,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: feedback == "Correct!" ? Colors.green : Colors.red,
                  ),
                  textAlign: TextAlign.center,
                ),
              ] else
                ElevatedButton(
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Start Game",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              SizedBox(height: 30),

              if (!gameStarted && feedback.contains("Game Over"))
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                  ),
                  child: Text(
                    "Back to Levels",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
