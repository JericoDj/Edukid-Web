
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/signup/widgets/signupcheckboxandprivacy.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../../utils/validators/validation.dart';
import '../../../authentication/controllers/signup/signup_controller.dart';

class SignUpForm extends StatelessWidget {
  const SignUpForm({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    final controller = Get.put(SignupController());

    return Form(
        key: controller.signupFormKey,
        child: Column(children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                    controller: controller.firstName,
                    validator: (value) =>
                        MyValidator.validateEmptyText('First name', value),
                    expands: false,
                    decoration: const InputDecoration(
                        labelText: "First Name",
                        labelStyle: TextStyle(color: MyColors.grey),
                        prefixIcon: Icon(Iconsax.user))),
              ),
              const SizedBox(width: MySizes.spaceBtwInputItems),
              Expanded(
                child: TextFormField(
                    controller: controller.lastName,
                    validator: (value) =>
                        MyValidator.validateEmptyText('Last name', value),
                    decoration: const InputDecoration(
                        labelText: "Last Name",
                        labelStyle: TextStyle(color: MyColors.grey),
                        prefixIcon: Icon(Iconsax.user))),
              ),
            ],
          ),
          const SizedBox(height: MySizes.spaceBtwInputItems),

          TextFormField(
            controller: controller.username,
            validator: (value) =>
                MyValidator.validateEmptyText('Username', value),
            expands: false,
            decoration: const InputDecoration(
              labelText: "Username",
              labelStyle: TextStyle(color: MyColors.grey),
              prefixIcon: Icon(Iconsax.user_cirlce_add),
            ),
          ),
          const SizedBox(height: MySizes.spaceBtwInputItems),
          TextFormField(
            controller: controller.email,
            validator: (value) => MyValidator.validateEmail(value),
            expands: false,
            decoration: const InputDecoration(
              labelText: "Email",
              labelStyle: TextStyle(color: MyColors.grey),
              prefixIcon: Icon(Iconsax.message),
            ),
          ),
          const SizedBox(height: MySizes.spaceBtwInputItems),
          TextFormField(
            controller: controller.phoneNumber,
            validator: (value) => MyValidator.validatePhoneNumber(value),
            expands: false,
            decoration: const InputDecoration(
              labelText: "Phone Number",
              labelStyle: TextStyle(color: MyColors.grey),
              prefixIcon: Icon(Iconsax.call),
            ),
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+$')),
              // Allow only numeric input
            ],
          ),
          const SizedBox(height: MySizes.spaceBtwInputItems),

          ///Password
          Obx(
            () => TextFormField(
              controller: controller.password,
              validator: (value) => MyValidator.validatePassword(value),
              expands: false,
              obscureText: controller.hidePassword.value,
              decoration: InputDecoration(
                labelText: "Password",
                labelStyle: TextStyle(color: MyColors.grey),
                prefixIcon: Icon(Iconsax.lock),
                suffixIcon: IconButton(
                    onPressed: () => controller.hidePassword.value =
                        !controller.hidePassword.value,
                    icon: Icon(controller.hidePassword.value ? Iconsax.eye_slash : Iconsax.eye)),
              ),
            ),
          ),
          const SizedBox(height: MySizes.spaceBtwInputItems),
          Obx(
                () => TextFormField(
              controller: controller.confirmPassword,
              validator: (value) => MyValidator.validateConfirmPassword(
                  controller.password.text, value),
              expands: false,
              obscureText: controller.hideConfirmPassword.value,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                labelStyle: TextStyle(color: MyColors.grey),
                prefixIcon: Icon(Iconsax.lock),
                suffixIcon: IconButton(
                  onPressed: () =>
                  controller.hideConfirmPassword.value =
                  !controller.hideConfirmPassword.value,
                  icon: Icon(controller.hideConfirmPassword.value
                      ? Iconsax.eye_slash
                      : Iconsax.eye),
                ),
              ),
            ),
          ),
          const SizedBox(height: MySizes.spaceBtwInputItems),

          /// Check Box and Privacy Policy and Terms of Use
          const SignUpCheckBox(),

          const SizedBox(
            height: MySizes.spaceBtwItems,
          ),

          /// Sign Up Button
          SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () { if (controller.signupFormKey.currentState?.validate() ?? false){
                  controller.signup();}},
                child: const Text("Create Account"),
              ))
        ]));
  }
}
