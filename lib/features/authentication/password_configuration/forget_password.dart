
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';

import '../../../utils/constants/sizes.dart';
import '../../../utils/constants/text_strings.dart';
import '../../../utils/validators/validation.dart';
import '../controllers/forgot_password/forgot_password_controller.dart';


class ForgetPasswordScreen extends StatelessWidget {
  const ForgetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ForgetPasswordController());
    return Scaffold(
        appBar: AppBar(),
        body:  Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Align(
            alignment: Alignment.topCenter,

            child: Container(
              width: 600,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [


                  /// Headings
                  Text(MyTexts.forgetPasswordTitle, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height:  MySizes.spaceBtwItems),
                  Text(MyTexts.forgetPasswordSubTitle, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height:  MySizes.spaceBtwItems * 2),

                  /// Text fields
                  Form(
                    key: controller.forgetPasswordFormKey,
                    child: TextFormField(
                      controller: controller.email,
                      validator: MyValidator.validateEmail,
                      decoration: const InputDecoration(labelText: MyTexts.email, prefixIcon: Icon(Iconsax.direct_right)),
                    ),
                  ),
                  const SizedBox(height:  MySizes.spaceBtwItems),

                  /// Submit Button
                  SizedBox(width: double.infinity,child: ElevatedButton(onPressed: () => controller.sendPasswordResetEmail(context), child: const Text("Submit"),))


                ],
              ),
            ),
          ),
        )
    );
  }
}
