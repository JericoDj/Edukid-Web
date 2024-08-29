import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/products/cart_menu_icons.dart';
import '../../../../common/widgets/shimmer/shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/text_strings.dart';
import '../../../personalization/controllers/user_controller.dart';

class MyHomeAppBar extends StatelessWidget {
  const MyHomeAppBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the controller is properly initialized
    final controller = Get.put(UserController(), permanent: true);

    return MyAppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            MyTexts.homeAppBarTitle,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(color: MyColors.white),
          ),
          Obx(() {
            if (controller.profileLoading.value) {
              // Debugging: print statement to check loading state
              print("Loading user profile...");
              return const MyShimmerEffect(width: 80, height: 15, radius: 8.0);
            } else if (controller.user.value.fullName != null) {
              // Debugging: print statement to check user data
              print("User loaded: ${controller.user.value.fullName}");
              return Text(
                controller.user.value.fullName ?? '',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: MyColors.white),
              );
            } else {
              // Handle null or empty user name
              print("User name is null or empty");
              return const Text(
                "Guest",
                style: TextStyle(color: MyColors.white),
              );
            }
          }),
        ],
      ),

    );
  }
}
