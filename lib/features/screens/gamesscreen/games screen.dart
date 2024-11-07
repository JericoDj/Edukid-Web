// levels_screen.dart
import 'package:flutter/material.dart';

import 'game_controller.dart';
import 'games.dart';

class LevelsScreen extends StatefulWidget {
  @override
  _LevelsScreenState createState() => _LevelsScreenState();
}

class _LevelsScreenState extends State<LevelsScreen> {
  int? selectedLevelIndex;
  String? selectedTopic;

  final List<String> levels = [
    "Level 1", "Level 2", "Level 3", "Level 4",
    "Level 5", "Level 6", "Level 7", "Level 8"
  ];

  final Map<int, List<String>> levelTopics = {
    0: ["addition", "counting", "division", "estimation", "geometry", "graphing", "mixed equations", "money", "multiplication", "number patterns", "number properties", "subtraction", "time"],
    1: ["addition", "comparison", "counting", "division", "estimation", "fraction", "geometry", "graphing", "measurement", "mixed equations", "money", "multiplication", "number patterns", "number properties", "subtraction", "time"],
    2: ["addition", "counting", "division", "fraction", "geometry", "graphing", "measurement", "mixed equations", "money", "multiplication", "number patterns", "number properties", "subtraction", "time"],
    3: ["addition", "comparison", "counting", "decimals", "division", "estimation", "fraction", "geometry", "graphing", "measurement", "mixed equations", "money", "multiplication", "number patterns", "number properties", "subtraction", "time"],
    4: ["addition", "algebra", "counting", "decimals", "division", "estimation", "fraction", "geometry", "measurement", "mixed equations", "money", "multiplication", "number patterns", "number properties", "ratios", "stats", "subtraction"],
    5: ["decimals", "division", "estimation", "fraction", "geometry", "mixed equations", "money", "multiplication", "number patterns", "number properties", "ratios"],
    6: ["addition", "algebra", "comparison", "decimals", "division", "estimation", "fraction", "geometry", "graphing", "measurement", "mixed equations", "money", "multiplication", "number patterns", "number properties", "ratios", "stats", "subtraction", "time"],
    7: ["algebra", "comparison", "division", "geometry", "graphing", "measurement", "mixed equations", "money", "number patterns", "number properties", "ratios", "stats", "time"]


  };

  void selectLevel(int index) {
    setState(() {
      selectedLevelIndex = index;
      selectedTopic = null;
    });
  }

  void selectTopic(String topic) {
    setState(() {
      selectedTopic = topic;
    });
  }

  void createGame() {
    if (selectedLevelIndex != null && selectedTopic != null) {
      // Initialize GameController with the selected level and topic
      GameController gameController = GameController(
        levelIndex: selectedLevelIndex!,
        topic: selectedTopic!,
      );

      // Navigate to GameScreen with the GameController instance
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameScreen(gameController: gameController),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Educational Levels"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: levels.length,
                itemBuilder: (context, index) {
                  final isSelected = selectedLevelIndex == index;

                  return GestureDetector(
                    onTap: () {
                      selectLevel(index);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.black : Colors.teal,
                        ),
                        color: isSelected ? Colors.amber : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          levels[index],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.teal,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 20),

              if (selectedLevelIndex != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.teal[400],
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Topics for ${levels[selectedLevelIndex!]}',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 12),

                      Wrap(
                        spacing: 16.0,
                        runSpacing: 8.0,
                        children: levelTopics[selectedLevelIndex]!
                            .map((topic) => GestureDetector(
                          onTap: () {
                            selectTopic(topic);
                          },
                          child: Container(
                            width: MediaQuery.of(context).size.width / 4 - 32,
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 10.0),
                            decoration: BoxDecoration(
                              color: selectedTopic == topic
                                  ? Colors.amber
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.teal[800]!,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              topic,
                              style: TextStyle(
                                color: selectedTopic == topic
                                    ? Colors.white
                                    : Colors.teal[800],
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ))
                            .toList(),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                Center(
                  child: ElevatedButton(
                    onPressed: selectedTopic != null ? createGame : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Create Game",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
