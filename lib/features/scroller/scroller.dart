import 'package:flutter/material.dart';

class CustomScroller extends StatefulWidget {
  final Widget child;
  final Axis scrollDirection;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final bool reverse;
  final Color? scrollbarColor;
  final double scrollbarThickness;
  final double arrowSize;

  const CustomScroller({
    Key? key,
    required this.child,
    this.scrollDirection = Axis.vertical,
    this.physics,
    this.padding,
    this.reverse = false,
    this.scrollbarColor = Colors.grey,
    this.scrollbarThickness = 6.0,
    this.arrowSize = 16.0,
  }) : super(key: key);

  @override
  _CustomScrollerState createState() => _CustomScrollerState();
}

class _CustomScrollerState extends State<CustomScroller> {
  final ScrollController _controller = ScrollController();
  double _thumbHeight = 50;
  double _thumbPosition = 0;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_updateThumbPosition);
  }

  @override
  void dispose() {
    _controller.removeListener(_updateThumbPosition);
    _controller.dispose();
    super.dispose();
  }

  void _updateThumbPosition() {
    setState(() {
      double maxScrollExtent = _controller.position.maxScrollExtent;
      double currentScroll = _controller.position.pixels;
      double viewportHeight = _controller.position.viewportDimension;

      // Calculate thumb height and position
      _thumbHeight = (viewportHeight / (maxScrollExtent + viewportHeight)) * viewportHeight;
      _thumbPosition = (currentScroll / maxScrollExtent) * (viewportHeight - _thumbHeight);
    });
  }

  void _scrollUp() {
    _controller.animateTo(
      _controller.offset - 100.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _scrollDown() {
    _controller.animateTo(
      _controller.offset + 100.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          controller: _controller,
          padding: widget.padding,
          reverse: widget.reverse,
          scrollDirection: widget.scrollDirection,
          physics: widget.physics ?? BouncingScrollPhysics(),
          child: widget.child,
        ),
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            width: widget.scrollbarThickness,
            decoration: BoxDecoration(
              color: widget.scrollbarColor,
            ),
            child: Column(
              children: [
                // Up Arrow Button
                GestureDetector(
                  onTap: _scrollUp,
                  child: Container(
                    width: widget.scrollbarThickness,
                    height: widget.arrowSize,
                    color: widget.scrollbarColor,
                    child: Icon(Icons.arrow_drop_up, size: widget.arrowSize, color: Colors.white),
                  ),
                ),
                // Scroll Bar Track and Thumb
                Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: widget.scrollbarColor!.withOpacity(0.6),
                      ),
                      Positioned(
                        top: _thumbPosition,
                        child: GestureDetector(
                          onVerticalDragUpdate: (details) {
                            double maxScrollExtent = _controller.position.maxScrollExtent;
                            double viewportHeight = _controller.position.viewportDimension;

                            double newScrollPosition = (_controller.offset + (details.primaryDelta ?? 0))
                                .clamp(0.0, maxScrollExtent);

                            _controller.jumpTo(newScrollPosition);
                          },
                          child: Container(
                            width: widget.scrollbarThickness,
                            height: _thumbHeight,
                            color: widget.scrollbarColor!.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Down Arrow Button
                GestureDetector(
                  onTap: _scrollDown,
                  child: Container(
                    width: widget.scrollbarThickness,
                    height: widget.arrowSize,
                    color: widget.scrollbarColor,
                    child: Icon(Icons.arrow_drop_down, size: widget.arrowSize, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
