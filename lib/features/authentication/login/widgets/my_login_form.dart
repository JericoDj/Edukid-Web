import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/validators/validation.dart';
import '../../../authentication/controllers/login/login_controller.dart';
import '../../../screens/signup/widgets/signup.dart';
import '../../password_configuration/forget_password.dart';

class MyLoginForm extends StatelessWidget {
  const MyLoginForm({
    super.key,
    required this.controller,
  });

  final LoginController controller;

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            vertical: MySizes.spaceBtwSections / 2), // Reduced padding
        child: Column(
          children: [
            // Email
            SizedBox(
              width: 400, // Set the width of the TextFormField
              child: TextFormField(
                controller: controller.email,
                validator: (value) => MyValidator.validateEmail(value),
                decoration: const InputDecoration(
                    prefixIcon: Icon(
                      Iconsax.direct_right,
                      color: MyColors.darkGrey,
                      size: 18, // Smaller icon size
                    ),
                    labelText: "Email",
                    labelStyle: TextStyle(color: MyColors.grey, fontSize: 14)), // Smaller text size
              ),
            ),
            const SizedBox(height: MySizes.spaceBtwInputItems / 2), // Reduced spacing

            // Password
            SizedBox(
              width: 400, // Set the width of the TextFormField
              child: Obx(
                    () => TextFormField(
                  controller: controller.password,
                  validator: (value) =>
                      MyValidator.validateEmptyText('Password', value),
                  obscureText: controller.hidePassword.value,
                  decoration: InputDecoration(
                      prefixIcon: const Icon(
                        Iconsax.lock,
                        color: MyColors.darkGrey,
                        size: 18, // Smaller icon size
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          controller.hidePassword.value
                              ? Iconsax.eye
                              : Iconsax.eye_slash,
                          color: MyColors.darkGrey,
                          size: 18, // Smaller icon size
                        ),
                        onPressed: () => controller.hidePassword.value =
                        !controller.hidePassword.value,
                      ),
                      labelText: "Password",
                      labelStyle: const TextStyle(color: MyColors.grey, fontSize: 14)), // Smaller text size
                ),
              ),
            ),
            const SizedBox(height: MySizes.spaceBtwInputItems), // Reduced spacing

            // Remember Me & Forget Password
            SizedBox(
              width: 250, // Set the width of the row
              child: Row(
                children: [
                  Obx(
                        () => Checkbox(
                      value: controller.rememberMe.value,
                      onChanged: (value) => controller.rememberMe
                          .value = !controller.rememberMe.value,
                    ),
                  ),
                  const Text("Remember Me", style: TextStyle(fontSize: 12)), // Smaller text size
                  const Spacer(),
                  TextButton(
                    onPressed: () => context.go('/forgotPassword'),
                    child: const Text("Forgot Password", style: TextStyle(fontSize: 12)), // Smaller text size
                  ),
                ],
              ),
            ),
            SizedBox(height: MySizes.spaceBtwItems / 2),

            // Sign In Button
            SizedBox(
              width: 150,
              height: 40, // Reduced button height
              child: ElevatedButton(
                onPressed: () => controller.emailAndPasswordSignIn(context), // Pass context here
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text("Sign In",
                    style: TextStyle(color: Colors.white, fontSize: 14)), // Smaller text size
              ),
            ),

            // Create Account Button
            const SizedBox(height: 12), // Reduced spacing
            SizedBox(
              width: 150,
              height: 40, // Reduced button height
              child: OutlinedButton(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Create Account",
                    style: TextStyle(color: Colors.white, fontSize: 14)), // Smaller text size
              ),
            ),
          ],
        ),
      ),
    );
  }
}
