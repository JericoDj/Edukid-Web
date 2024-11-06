import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/success_screen/sucess_screen.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';

class VerifyEmailController extends GetxController {
  static VerifyEmailController get instance => Get.find();

  @override
  void onInit() {
    sendEmailVerification();
    setTimerForAutoRedirect();
    super.onInit();
  }

  Future<void> sendEmailVerification() async {
    try {
      await AuthenticationRepository.instance.sendEmailVerification();

    } catch (e) {

    }
  }

  void setTimerForAutoRedirect() {
    Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {
        await FirebaseAuth.instance.currentUser?.reload();
        final user = FirebaseAuth.instance.currentUser;

        if (user?.emailVerified ?? false) {
          timer.cancel();
          Get.off(
                () => SuccessScreen(
              image: MyImages.accountGIF,
              title: 'Your Account is Successfully Created',
              subtitle: "Let's learn together",
              onPressed: () => AuthenticationRepository.instance.screenRedirect(Get.context!), // Pass context here
            ),
          );
        }
      },
    );
  }

  Future<void> checkEmailVerificationStatus(BuildContext context) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.emailVerified) {
      Get.off(
            () => SuccessScreen(
          image: MyImages.accountGIF,
          title: 'Your Account is Successfully Created',
          subtitle: 'Manually check account is verified',
          onPressed: () => AuthenticationRepository.instance.screenRedirect(context), // Pass context here
        ),
      );
    }
  }
}
