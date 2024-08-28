import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
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
            vertical: MySizes.spaceBtwSections),
        child: Column(
          children: [
            // Email
            TextFormField(
              controller: controller.email,
              validator: (value) => MyValidator.validateEmail(value),
              decoration: const InputDecoration(
                  prefixIcon: Icon(
                    Iconsax.direct_right,
                    color: MyColors.darkGrey,
                  ),
                  labelText: "Email",
                  labelStyle: TextStyle(color: MyColors.grey)),
            ),
            const SizedBox(height: MySizes.spaceBtwInputItems),

            // Password
            Obx(
                  () => TextFormField(
                controller: controller.password,
                validator: (value) =>
                    MyValidator.validateEmptyText('Password', value),
                obscureText: controller.hidePassword.value,
                decoration: InputDecoration(
                    prefixIcon: const Icon(
                      Iconsax.lock,
                      color: MyColors.darkGrey,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        controller.hidePassword.value
                            ? Iconsax.eye
                            : Iconsax.eye_slash,
                        color: MyColors.darkGrey,
                      ),
                      onPressed: () => controller.hidePassword.value =
                      !controller.hidePassword.value,
                    ),
                    labelText: "Password",
                    labelStyle: const TextStyle(color: MyColors.grey)),
              ),
            ),
            const SizedBox(height: MySizes.spaceBtwInputItems / 2),

            // Remember Me & Forget Password
            Row(
              children: [
                Obx(
                      () => Checkbox(
                    value: controller.rememberMe.value,
                    onChanged: (value) => controller.rememberMe
                        .value = !controller.rememberMe.value,
                  ),
                ),
                const Text("Remember Me"),
                const Spacer(),
                TextButton(
                    onPressed: () =>
                        Get.to(() => const ForgetPasswordScreen()),
                    child: const Text("Forgot Password")),
              ],
            ),

            // Sign In Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () =>
                    controller.emailAndPasswordSignIn(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text("Sign In",
                    style: TextStyle(color: Colors.white)),
              ),
            ),

            // Create Account Button
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.to(() => const SignUpScreen()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("Create Account",
                    style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
