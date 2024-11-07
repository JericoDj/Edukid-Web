// game_controller.dart

class GameController {
  final int levelIndex;
  final String topic;
  List<Map<String, dynamic>>? questions;
  int currentQuestionIndex = 0;
  int currentScore = 0;

  GameController({required this.levelIndex, required this.topic}) {
    initializeGame();
  }

  void initializeGame() {
    // Initialize questions based on the selected level and topic
    questions = questionsData[levelIndex]?[topic];
    currentQuestionIndex = 0;
    currentScore = 0;
  }

  Map<String, dynamic>? getCurrentQuestion() {
    if (questions == null || currentQuestionIndex >= questions!.length) {
      return null;
    }
    return questions![currentQuestionIndex];
  }

  bool checkAnswer(int userAnswer) {
    if (questions == null) return false;
    final correctAnswer = questions![currentQuestionIndex]["answer"];
    bool isCorrect = userAnswer == correctAnswer;
    if (isCorrect) currentScore++;
    return isCorrect;
  }

  bool nextQuestion() {
    if (questions == null || currentQuestionIndex + 1 >= questions!.length) {
      return false; // No more questions
    }
    currentQuestionIndex++;
    return true;
  }
}

// Sample question data for each level and topic
final Map<int, Map<String, List<Map<String, dynamic>>>> questionsData = {
  0: { // Level 1
    "addition": [
      {"question": "What is 2 + 3?", "answer": 5, "options": [3, 4, 5, 6]},
      {"question": "What is 7 + 8?", "answer": 15, "options": [10, 15, 18, 20]},
    ],
    "counting": [
      {"question": "How many apples are there if you add 3 more to 5?", "answer": 8, "options": [7, 8, 9, 10]},
      {"question": "Count the number of stars in the sky (assuming a small number)", "answer": 6, "options": [5, 6, 7, 8]},
    ],
    "division": [
      {"question": "What is 10 divided by 2?", "answer": 5, "options": [3, 4, 5, 6]},
      {"question": "What is 15 divided by 3?", "answer": 5, "options": [4, 5, 6, 7]},
    ],
    "estimation": [
      {"question": "Estimate the sum of 52 and 48", "answer": 100, "options": [90, 100, 110, 120]},
      {"question": "Approximately, what is 20 + 33?", "answer": 50, "options": [40, 50, 60, 70]},
    ],
    "geometry": [
      {"question": "How many sides does a triangle have?", "answer": 3, "options": [3, 4, 5, 6]},
      {"question": "How many sides does a square have?", "answer": 4, "options": [3, 4, 5, 6]},
    ],
    "graphing": [
      {"question": "If you plot the points (1, 2) and (3, 4), what is the distance between them?", "answer": 2, "options": [1, 2, 3, 4]},
      {"question": "In a bar graph, if Category A has 3 bars and Category B has 5, which is greater?", "answer": 5, "options": [3, 4, 5, 6]},
    ],
    "mixed equations": [
      {"question": "What is 3 + 4 * 2?", "answer": 11, "options": [11, 12, 13, 14]},
      {"question": "Solve: 8 / 4 + 6", "answer": 8, "options": [6, 7, 8, 9]},
    ],
    "money": [
      {"question": "If you have 3 coins worth \$1 each, how much do you have?", "answer": 3, "options": [1, 2, 3, 4]},
      {"question": "If you spend \$2 out of \$5, how much is left?", "answer": 3, "options": [2, 3, 4, 5]},
    ],
    "multiplication": [
      {"question": "What is 3 * 4?", "answer": 12, "options": [10, 11, 12, 13]},
      {"question": "What is 5 * 6?", "answer": 30, "options": [25, 30, 35, 40]},
    ],
    "number patterns": [
      {"question": "What comes next in the sequence: 2, 4, 6, ...?", "answer": 8, "options": [6, 7, 8, 9]},
      {"question": "What is the next odd number after 7?", "answer": 9, "options": [8, 9, 10, 11]},
    ],
    "number properties": [
      {"question": "Is 7 an odd or even number?", "answer": 1, "options": [1, 0]}, // Assuming 1 for odd, 0 for even
      {"question": "What is the smallest prime number?", "answer": 2, "options": [1, 2, 3, 4]},
    ],
    "subtraction": [
      {"question": "What is 10 - 4?", "answer": 6, "options": [5, 6, 7, 8]},
      {"question": "What is 8 - 3?", "answer": 5, "options": [4, 5, 6, 7]},
    ],
    "time": [
      {"question": "If it's 3 PM now, what time will it be in 2 hours?", "answer": 5, "options": [4, 5, 6, 7]},
      {"question": "How many minutes are there in an hour?", "answer": 60, "options": [50, 55, 60, 65]},
    ],
  },
  1: { // Level 2
    "addition": [
      {"question": "What is 10 + 15?", "answer": 25, "options": [20, 25, 30, 35]},
      {"question": "What is 20 + 30?", "answer": 50, "options": [40, 45, 50, 55]},
    ],
    "comparison": [
      {"question": "Which is greater: 20 or 15?", "answer": 20, "options": [15, 18, 20, 22]},
      {"question": "Is 5 less than 10?", "answer": 1, "options": [1, 0]}, // Assuming 1 for true, 0 for false
    ],
    // Additional topics for Level 2
  },
  // Add other levels here
};
