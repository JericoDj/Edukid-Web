


import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/device/device_utitility.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../../authentication/controllers/onboarding/onboarding_controller.dart';

class OnBoardingNavigationBar extends StatelessWidget {
  const OnBoardingNavigationBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final controller = OnBoardingController.instance;
    final dark = MyHelperFunctions.isDarkMode(context);

    return Positioned(
      bottom: MyDeviceUtils.getBottomNavigationBarHeight() + 25,
      left: 16,
      child: SmoothPageIndicator(
        controller: controller.pageController,
        onDotClicked: controller.dotNavigationClick,
        count: 3,
        effect: ExpandingDotsEffect(
          activeDotColor: dark ?  MyColors.light: Colors.blue, // Change to your preferred color
          dotHeight: 6,
          dotColor: dark ? Colors.blue : Colors.black, // Set dot color to black
          radius: 8, // Adjust the radius for dot-expanding effect
        ),
      ),
    );
  }
}
