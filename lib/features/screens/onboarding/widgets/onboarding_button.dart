
import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utitility.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/controllers/onboarding/onboarding_controller.dart';



class OnBoardingCircularButton extends StatelessWidget {
  const OnBoardingCircularButton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = MyHelperFunctions.isDarkMode(context);
    return Positioned(
      right: MySizes.defaultspace,
      bottom: MyDeviceUtils.getBottomNavigationBarHeight(),
      child: ElevatedButton(
        onPressed: () => OnBoardingController.instance.nextPage(),
        style: ElevatedButton.styleFrom(shape: const CircleBorder(), backgroundColor: dark ? MyColors.primaryColor : Colors.black),
        child: const Icon(Iconsax.arrow_right_3),
      ),
    );
  }
}