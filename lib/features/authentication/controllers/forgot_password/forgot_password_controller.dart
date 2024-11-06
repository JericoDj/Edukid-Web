import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';

class ForgetPasswordController extends GetxController {
  static ForgetPasswordController get instance => Get.find();

  final email = TextEditingController();
  GlobalKey<FormState> forgetPasswordFormKey = GlobalKey<FormState>();

  /// Send Reset Password Email
  sendPasswordResetEmail(BuildContext context) async {
    try {
      if (!forgetPasswordFormKey.currentState!.validate()) return;

      await AuthenticationRepository.instance.sendPasswordResetEmail(email.text.trim());

      // Navigate to reset password screen with GoRouter
      context.go('/resetPassword/${email.text.trim()}');
    } catch (e) {
      // Handle error if needed
    }
  }

  resendPasswordResetEmail(String email) async {
    try {
      MyFullScreenLoader.openLoadingDialog('Processing your request...', MyImages.loaders);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.sendPasswordResetEmail(email);

      MyFullScreenLoader.stopLoading();
      MyLoaders.successSnackBar(
        title: 'Email Sent',
        message: 'Email Link Sent to Reset your Password'.tr,
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
