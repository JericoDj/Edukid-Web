import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../common/widgets/loaders/loaders.dart';


import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../personalization/controllers/user_controller.dart';


class LoginController extends GetxController {
  // Variables
  final rememberMe = false.obs;
  final hidePassword = true.obs;
  final imageUploading = false.obs;
  final localStorage = GetStorage();
  final email = TextEditingController();
  final password = TextEditingController();
  GlobalKey<FormState> loginFormKey = GlobalKey<FormState>();
  final userController = Get.put(UserController());

  @override
  void onInit() {
    final rememberedEmail = localStorage.read('REMEMBER_ME_EMAIL');
    final rememberedPassword = localStorage.read('REMEMBER_ME_PASSWORD');

    if (rememberedEmail != null) {
      email.text = rememberedEmail;
    }

    if (rememberedPassword != null) {
      password.text = rememberedPassword;
    }

    // Manually check 'Remember Me' value on app startup
    if (!rememberMe.value) {
      localStorage.remove('REMEMBER_ME_EMAIL');
      localStorage.remove('REMEMBER_ME_PASSWORD');
    }

    super.onInit();
  }

  /// Email and Password SignIn
  Future<void> emailAndPasswordSignIn() async {
    try {
      // Start Loading
      MyFullScreenLoader.openLoadingDialog('Logging you in...', MyImages.loaders);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Form Validation
      if (loginFormKey.currentState != null && !loginFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      // Save Data if Remember Me is selected
      if (rememberMe.value) {
        localStorage.write('REMEMBER_ME_EMAIL', email.text.trim());
        localStorage.write('REMEMBER_ME_PASSWORD', password.text.trim());
      } else {
        // Delete email and password from local storage if not remembered
        localStorage.remove('REMEMBER_ME_EMAIL');
        localStorage.remove('REMEMBER_ME_PASSWORD');
      }

      // Login user using Email & Password Authentication
      final userCredentials = await AuthenticationRepository.instance.loginWithEmailAndPassword(
        email.text.trim(),
        password.text.trim(),
      );

      // Remove Loader
      MyFullScreenLoader.stopLoading();

      // Redirect
      AuthenticationRepository.instance.screenRedirect();
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }

  /// Google Sign in
  Future<void> googleSignIn() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Logging you in...', MyImages.loaders);

      // Check Internet Connectivity
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      print("Starting Google Sign-In");
      // Google Sign-In process
      final userCredentials = await AuthenticationRepository.instance.signInWithGoogle();

      String? userEmail = userCredentials.user?.email;
      print("Google Sign-In completed, user: $userEmail");
      if (userEmail != null) {
        if (await AuthenticationRepository.instance.isEmailAlreadyRegistered(userEmail.trim())) {
          MyFullScreenLoader.stopLoading();
          AuthenticationRepository.instance.screenRedirect();
          return;
        }

        // Save User Record only if the email is not already registered
        await userController.saveUserRecord(userCredentials);

        MyFullScreenLoader.stopLoading();
        AuthenticationRepository.instance.screenRedirect();
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    }
  }
}
