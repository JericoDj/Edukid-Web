import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../common/widgets/loaders/animation_loader.dart';
import '../constants/colors.dart';
import '../helpers/helper_functions.dart';

/// A utility class for managing a full-screen loading dialog.
class MyFullScreenLoader {
  /// Opens a full-screen loading dialog with a given text and animation.
  /// This method doesn't return anything.
  ///
  /// Parameters:
  /// - text: The text to be displayed in the loading dialog.
  /// - animation: The Lottie animation to be shown.
  static void openLoadingDialog(String text, String animation,
      {BuildContext? context}) {
    // Fallback to provided context if overlayContext is null
    final effectiveContext = Get.overlayContext ?? context;

    if (effectiveContext == null) {
      Future.delayed(const Duration(milliseconds: 100), () {
        openLoadingDialog(text, animation, context: context);
      });
      return;
    }

    showDialog(
      context: effectiveContext,
      barrierDismissible: false, // Prevent dismissal by tapping outside
      builder: (_) =>
          WillPopScope(
            onWillPop: () async => false, // Disable back button
            child: Container(
              color: MyHelperFunctions.isDarkMode(effectiveContext) ? MyColors
                  .dark : MyColors.white,
              width: double.infinity,
              height: double.infinity,
              child: Column(
                children: [
                  const SizedBox(height: 0), // Adjust spacing if needed
                  MyAnimationLoaderWidget(text: text, animation: animation),
                ],
              ),
            ),
          ),
    );
  }

  /// Stops the loading dialog by closing it with Navigator.
  /// Stops the loading dialog by closing it with Navigator.
  static void stopLoading({BuildContext? context}) {
    // Use either the provided context or Get.overlayContext if available
    final effectiveContext = context ?? Get.overlayContext;

    if (effectiveContext == null) {
      debugPrint("Overlay context is null. Cannot close loading dialog.");
      return;
    }

    // Only close if a dialog is open
    if (Navigator.of(effectiveContext).canPop()) {
      Navigator.of(effectiveContext).pop();
    } else {
      debugPrint("No dialog open to close.");
    }
  }

}