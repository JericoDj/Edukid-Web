import 'package:flutter/material.dart';


class Here extends StatefulWidget {
  @override
  State<Here> createState() => _HereState();
}

class _HereState extends State<Here> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text("Custom Scrollbar with Arrows"),
        ),
        body: CustomScrollbarWithArrows(),
      ),
    );
  }
}

class CustomScrollbarWithArrows extends StatefulWidget {
  @override
  _CustomScrollbarWithArrowsState createState() =>
      _CustomScrollbarWithArrowsState();
}

class _CustomScrollbarWithArrowsState extends State<CustomScrollbarWithArrows> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollUp() {
    _scrollController.animateTo(
      _scrollController.offset - 50,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollDown() {
    _scrollController.animateTo(
      _scrollController.offset + 50,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 30.0), // Padding for scrollbar and arrows
          child: Scrollbar(
            controller: _scrollController, // Attach ScrollController here
            thumbVisibility: true,
            child: ListView.builder(
              controller: _scrollController, // Attach ScrollController here
              itemCount: 50,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text("Item $index"),
                );
              },
            ),
          ),
        ),
        // Scrollbar background with gradient effect
        Positioned.fill(
          right: 0,
          child: Container(
            width: 30,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey.shade900,
                  Colors.grey.shade800,
                  Colors.grey.shade700,
                ],
              ),
            ),
          ),
        ),
        // Up Arrow Button
        Positioned(
          right: 4,
          top: 4,
          child: IconButton(
            icon: Icon(Icons.arrow_drop_up),
            onPressed: _scrollUp,
            color: Colors.grey.shade400,
          ),
        ),
        // Down Arrow Button
        Positioned(
          right: 4,
          bottom: 4,
          child: IconButton(
            icon: Icon(Icons.arrow_drop_down),
            onPressed: _scrollDown,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
