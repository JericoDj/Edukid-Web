import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/loaders/animation_loader.dart';
import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

/// A utility class for managing a full-screen loading dialog.
class MyFullScreenLoader {
  /// Open a full-screen loading dialog with a given text and animation. /// This method doesn't return anything.
  ///
  /// Parameters:
  ///text: The text to be displayed in the loading dialog.
  /// - animation: The Lottie animation to be shown.
  static void openLoadingDialog(String text, String animation) {
    showDialog(
      context: Get.overlayContext!,
      // Use Get.overlay Context for overlay dialogs
      barrierDismissible: false,
      // The dialog can't be dismissed by tapping outside it
      builder: (_) =>
          PopScope(
            canPop: false, // Disable popping with the back button
            child: Container(
              color: MyHelperFunctions.isDarkMode(Get.context!)
                  ? MyColors.dark
                  : MyColors.white, width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  const SizedBox (height: 0), // Adjust the spacing as needed
                  MyAnimationLoaderWidget(text: text, animation: animation),
                ],
              ),
            ),
          ),
    );
  }
  static stopLoading() {
    Navigator.of(Get.overlayContext!).pop(); // close the dialing using the Navigator
  }
}