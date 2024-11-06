import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/helpers/helper_functions.dart';
import '../controllers/forgot_password/forgot_password_controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            onPressed: () => context.pop(), // Use context.pop() instead of Get.back()
            icon: const Icon(CupertinoIcons.clear),
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 800,
              child: Column(
                children: [
                  // Image
                  Image(
                    image: const AssetImage(MyImages.resetPasswordGIF),
                    height: 200,
                    width: 140,
                  ),
                  const SizedBox(height: 20),

                  // Title and Subtitle
                  Text(
                    MyTexts.forgetPasswordResultTitle,
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: MySizes.spaceBtwItems),
                  Text(
                    MyTexts.forgetPasswordResultSubTitle,
                    style: Theme.of(context).textTheme.labelMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: MySizes.spaceBtwItems * 2),

                  // Buttons
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'), // Use context.go() to navigate to login
                      child: const Text("Submit"),
                    ),
                  ),
                  const SizedBox(height: MySizes.spaceBtwItems),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => ForgetPasswordController.instance.sendPasswordResetEmail(context),
                      child: const Text("Resend Email"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
