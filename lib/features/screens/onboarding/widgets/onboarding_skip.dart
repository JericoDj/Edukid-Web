
import 'package:flutter/material.dart';

import '../../../../utils/constants/sizes.dart';
import '../../../../utils/device/device_utitility.dart';
import '../../../authentication/controllers/onboarding/onboarding_controller.dart';



class OnBoardingSkip extends StatelessWidget {
  const OnBoardingSkip({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(top: MyDeviceUtils.getAppBarheight(),
        right: MySizes.defaultspace,
        child:TextButton(onPressed: () => OnBoardingController.instance.skipPage(),
          child: const Text('Skip'),));
  }
}