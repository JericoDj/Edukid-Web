import 'package:flutter/material.dart';

class UserWorksheets extends StatelessWidget {
  const UserWorksheets({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'User Worksheets Widget',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
