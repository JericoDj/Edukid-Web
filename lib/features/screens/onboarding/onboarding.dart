
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:webedukid/features/screens/onboarding/widgets/onboarding_button.dart';
import 'package:webedukid/features/screens/onboarding/widgets/onboarding_page.dart';
import 'package:webedukid/features/screens/onboarding/widgets/onboarding_skip.dart';
import 'package:webedukid/features/screens/onboarding/widgets/onborading_navigation.dart';

import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/text_strings.dart';
import '../../authentication/controllers/onboarding/onboarding_controller.dart';


class OnBoardingScreen extends StatelessWidget {
  const OnBoardingScreen({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final controller = Get.put(OnBoardingController());

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller.pageController,
                onPageChanged: controller.updatePageIndicator,
                children: const [
                  OnBoardingPage(
                    image: MyImages.onBoardingImage1,
                    title: MyTexts.onBoardingTitle1,
                    subtitle: MyTexts.onBoardingSubTitle1,
                  ),
                  OnBoardingPage(
                    image: MyImages.onBoardingImage2,
                    title: MyTexts.onBoardingTitle2,
                    subtitle: MyTexts.onBoardingSubTitle2,
                  ),
                  OnBoardingPage(
                    image: MyImages.onBoardingImage3,
                    title: MyTexts.onBoardingTitle3,
                    subtitle: MyTexts.onBoardingSubTitle3,
                  ),
                ],
          ),

          /// Skip Button
          const OnBoardingSkip(),

          /// Dot navigation SmoothPageIndicator
          const OnBoardingNavigationBar(),


          /// Circular Button
          const OnBoardingCircularButton()
        ],

      ),
    );
  }
}



