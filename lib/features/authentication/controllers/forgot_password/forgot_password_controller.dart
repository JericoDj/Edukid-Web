import 'package:get/get.dart';
import 'package:flutter/material.dart';

import '../../../../common/widgets/loaders/loaders.dart';

import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../password_configuration/reset_password.dart';


class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  /// Variables
  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Send Reset Password EMail
  sendPasswordResetEmail() async {
    try {
// Start Loading
      MyFullScreenLoader.openLoadingDialog(
          'Processing your request...', MyImages.loaders);

// Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;}

// Form Validation
      if (!forgetPasswordFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Send EMail to Reset Password
      await AuthenticationRepository.instance
          .sendPasswordResetEmail(email.text.trim());

      // Remove Loader
      MyFullScreenLoader.stopLoading();

      // Show Success Screen
      MyLoaders.successSnackBar(
          title: 'Email Sent',
          message: 'Email Link Sent to Reset your Password'.tr);

      // Redirect
      Get.to(() => ResetPasswordScreen(email: email.text.trim()));

    } catch (e) {
      // Remove Loader
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }

    resendPasswordResetEmail(String email) async {
      try {
// Start Loading
        MyFullScreenLoader.openLoadingDialog(
            'Processing your request...', MyImages.loaders);
// Check Internet Connectivity
        final isConnected = await NetworkManager.instance.isConnected();
        if (!isConnected) {
          MyFullScreenLoader.stopLoading();
          return;
        }

        // Send Email to Reset Password
        await AuthenticationRepository.instance.sendPasswordResetEmail(email);
// Remove Loader
        MyFullScreenLoader.stopLoading();
// Show Success Screen
        MyLoaders.successSnackBar(
            title: 'Email Sent',
            message: 'Email Link Sent to Reset your Password'.tr);
      } catch (e) {
        // Remove Loader
        MyFullScreenLoader.stopLoading();
        MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
      }
    }
  }
}
