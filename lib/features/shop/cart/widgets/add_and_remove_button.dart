import 'package:flutter/material.dart';

class MyAddRemoveButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MyAddRemoveButton({
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon),
      onPressed: onTap,
    );
  }
}