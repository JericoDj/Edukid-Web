import 'package:flutter/material.dart';
import 'package:webedukid/features/bookings/status/processing.dart';
import 'package:webedukid/utils/constants/colors.dart';


class AnotherScreen extends StatelessWidget {
  const AnotherScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Another Screen'),
        backgroundColor: MyColors.primaryColor,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return const ProcessingBookingsScreen();
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: MyColors.primaryColor, // Button color
          ),
          child: Text('Click Here to Open Dialog'),
        ),
      ),
    );
  }
}
