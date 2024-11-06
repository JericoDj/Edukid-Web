import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

import '../../../../common/data/repositories.authentication/auth_controller.dart';
import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../personalization/controllers/user_controller.dart';

class LoginController extends GetxController {
  final AuthController authController = Get.find<AuthController>(); // Access AuthController
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

    // Load saved email and password if 'Remember Me' was checked
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
      final userCredential = await AuthenticationRepository.instance
          .loginWithEmailAndPassword(email.text, password.text);

      if (userCredential.user != null) {
        userController.setUser(userCredential.user);

        if (rememberMe.value) {
          localStorage.write('REMEMBER_ME_EMAIL', email.text);
          localStorage.write('REMEMBER_ME_PASSWORD', password.text);
        }

        authController.login(); // Update auth status
        context.go('/home'); // Navigate to home
      } else {
        throw 'Login failed: No user data available';
      }
    } catch (e) {
      print("Login error: $e");
    }
  }

  Future<void> googleSignIn(BuildContext context) async {
    try {
      final userCredential = await AuthenticationRepository.instance.signInWithGoogle(context);

      if (userCredential.user != null) {
        userController.setUser(userCredential.user);

        authController.login(); // Update auth status
        context.go('/home'); // Navigate to home
      } else {
        throw 'Google Sign-In failed: No user data available';
      }
    } catch (e) {
      print("Google Sign-In error: $e");
    }
  }
}
