import 'package:flutter/cupertino.dart';

class TicketClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    double radius = 20.0; // Radius for curves
    Path path = Path();

    // Start from the top left
    path.moveTo(0, 0);
    path.lineTo(size.width, 0);

    // Top-right notch
    path.lineTo(size.width, size.height * 0.25);
    path.arcToPoint(Offset(size.width, size.height * 0.75), radius: Radius.circular(radius), clockwise: true);
    path.lineTo(size.width, size.height);

    // Bottom-right corner
    path.lineTo(0, size.height);

    // Bottom-left notch
    path.lineTo(0, size.height * 0.75);
    path.arcToPoint(Offset(0, size.height * 0.25), radius: Radius.circular(radius), clockwise: false);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}
