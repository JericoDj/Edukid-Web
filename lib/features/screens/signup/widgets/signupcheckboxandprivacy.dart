
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/controllers/signup/signup_controller.dart';

class SignUpCheckBox extends StatelessWidget {
  const SignUpCheckBox({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);
    final controller = SignupController.instance;
    return Obx(
          () => Row(
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: controller.privacyPolicy.value,
              onChanged: (value) =>
              controller.privacyPolicy.value = !controller.privacyPolicy.value,
            ),
          ),
          const SizedBox(
            width: MySizes.spaceBtwInputItems,
          ),
          Text.rich(TextSpan(children: [
            TextSpan(
              text: 'I Agree to ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextSpan(
              text: "Privacy Policy",
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                color: dark ? MyColors.white : MyColors.primaryColor,
                decoration: TextDecoration.underline,
                decorationColor:
                dark ? MyColors.white : MyColors.primaryColor,
              ),
            ),
            TextSpan(
              text: ' and ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            TextSpan(
              text: "Terms of Use",
              style: Theme.of(context).textTheme.bodyMedium!.apply(
                color: dark ? MyColors.white : MyColors.primaryColor,
                decoration: TextDecoration.underline,
                decorationColor:
                dark ? MyColors.white : MyColors.primaryColor,
              ),
            ),
          ])),
        ],
      ),
    );
  }
}
