import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../authentication/controllers/signup/verify_email_controller.dart';
import '../../../authentication/login/login.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key, this.email});

  final String? email;

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(VerifyEmailController());
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              AuthenticationRepository.instance.logout(context); // Pass context here
              Get.to(() => const LoginScreen());
            },
            icon: const Icon(CupertinoIcons.clear),
          ),
        ],
        title: const Text('Verify Email'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// Image
              Image.asset(
                'assets/images/animations/mailSent.gif',
                height: 200.0,
                width: 200.0,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 20.0),

              /// Title & Subtitle
              const Text(
                'Verify Your Email',
                style: TextStyle(
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: MySizes.spaceBtwItems),
              Text(
                email ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12.0),
              ),
              const SizedBox(height: MySizes.spaceBtwItems),
              const Text(
                'Please check your email and click on the verification link to complete the process.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.0),
              ),
              const SizedBox(height: MySizes.spaceBtwItems),

              /// Buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => controller.checkEmailVerificationStatus(context), // Pass context here
                  child: const Text("Continue"),
                ),
              ),
              const SizedBox(height: MySizes.spaceBtwItems),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => controller.sendEmailVerification(),
                  child: const Text("Resend Email"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
