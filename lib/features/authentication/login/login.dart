
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/authentication/login/widgets/my_login_form.dart';
import 'package:webedukid/features/authentication/login/widgets/my_login_header.dart';
import 'package:webedukid/features/authentication/login/widgets/social_Media_Login.dart';

import '../../../common/widgets/divider_signinwith_text.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/login/login_controller.dart';


class LoginScreen extends StatelessWidget {
  const LoginScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LoginController());
    final dark = MyHelperFunctions.isDarkMode(context);
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      key: controller.loginFormKey,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth > 800 ? 100 : 20, // Adjust padding for larger screens
          ),
          child: Column(
            children: [
              MyLoginHeader(dark: dark),
              MyLoginForm(controller: controller),
              const MyFormDivider(dividerText: "Sign in with"),
              const SizedBox(height: MySizes.spaceBtwItems),
              const MySocialButtons(),
            ],
          ),
        ),
      ),
    );
  }
}
