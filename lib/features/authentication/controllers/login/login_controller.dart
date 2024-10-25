import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  @override
  void onInit() {
    Get.lazyPut(() => NetworkManager());
    final rememberedEmail = localStorage.read('REMEMBER_ME_EMAIL');
    final rememberedPassword = localStorage.read('REMEMBER_ME_PASSWORD');

    if (rememberedEmail != null) email.text = rememberedEmail;
    if (rememberedPassword != null) password.text = rememberedPassword;

    if (!rememberMe.value) {
      localStorage.remove('REMEMBER_ME_EMAIL');
      localStorage.remove('REMEMBER_ME_PASSWORD');
    }

    super.onInit();
  }

  Future<void> emailAndPasswordSignIn(BuildContext context) async {
    try {
      if (Get.overlayContext != null) {
        MyFullScreenLoader.openLoadingDialog('Logging you in...', 'assets/animations/loading.json');
      }

      final userCredential = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text, password.text);

      if (userCredential.user != null) {
        userController.setUser(userCredential.user);
        if (rememberMe.value) {
          localStorage.write('REMEMBER_ME_EMAIL', email.text);
          localStorage.write('REMEMBER_ME_PASSWORD', password.text);
        }

        MyFullScreenLoader.stopLoading();
        context.go('/home');

        if (Get.overlayContext != null) {
          Get.snackbar("Success", "Logged in successfully", snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        throw 'Login failed: No user data available';
      }
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      if (Get.overlayContext != null) {
        Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> googleSignIn(BuildContext context) async {
    try {
      if (Get.overlayContext != null) {
        MyFullScreenLoader.openLoadingDialog('Logging you in...', MyImages.loaders);
      }

      final userCredential = await AuthenticationRepository.instance.signInWithGoogle(context);

      if (userCredential.user != null) {
        userController.setUser(userCredential.user);
        MyFullScreenLoader.stopLoading();
        context.go('/home');

        if (Get.overlayContext != null) {
          Get.snackbar("Success", "Google Sign-In successful", snackPosition: SnackPosition.BOTTOM);
        }
      } else {
        throw 'Google Sign-In failed: No user data available';
      }
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      if (Get.overlayContext != null) {
        Get.snackbar("Error", e.toString(), snackPosition: SnackPosition.BOTTOM);
      }
    }
  }
}
