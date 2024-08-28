import 'package:flutter/material.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/constants/colors.dart'; // Import MyColors

class WorksheetDownloadble extends StatefulWidget {
  const WorksheetDownloadble({
    Key? key,
  }) : super(key: key);

  @override
  _WorksheetDownloadbleState createState() => _WorksheetDownloadbleState();
}

class _WorksheetDownloadbleState extends State<WorksheetDownloadble> {
  bool isLongPressed = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start of the row
      children: [
        // Folder widget
        Expanded(
          child: GestureDetector(
            onLongPressStart: (details) {
              setState(() {
                isLongPressed = true; // Set long press state to true when long press starts
              });
            },
            onLongPressEnd: (details) {
              setState(() {
                isLongPressed = false; // Set long press state to false when long press ends
              });
            },
            child: AnimatedSwitcher(
              duration: Duration(milliseconds: 300), // Set the duration of the animation
              child: isLongPressed
                  ? Image.asset(
                'assets/images/Part 1/Cover1_-_C1P1.png', // Change image based on long press state
                key: ValueKey<bool>(isLongPressed), // Set key to switch images correctly

                fit: BoxFit.cover,
              )
                  : Image.asset(
                'assets/images/Part 1/Cover_page_C1P1.png', // Change image based on long press state
                key: ValueKey<bool>(isLongPressed), // Set key to switch images correctly

                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        // Details
        SizedBox(width: MySizes.spaceBtwItems,),
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start, // Align content to the start
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  'Primary 3',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                // Subtitle
                Text(
                  'Counting - Whole Numbers to 10 000',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: MySizes.spaceBtwItems), // Adjust spacing between subtitle and buttons
                // View Worksheet button
                ElevatedButton(
                  onPressed: () {
                    // Implement download functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor, // Set button color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: MySizes.defaultspace , right: MySizes.defaultspace), // Add padding
                    child: Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.white, // Set text color
                      ),
                    ),
                  ),
                ),
                SizedBox(height: MySizes.spaceBtwItems), // Adjust spacing between buttons
                // Download button
                ElevatedButton(
                  onPressed: () {
                    // Implement download functionality here
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: MyColors.primaryColor, // Set button color
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: MySizes.defaultspace , right: MySizes.defaultspace), // Add padding
                    child: Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.white, // Set text color
                      ),
                    ),
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
