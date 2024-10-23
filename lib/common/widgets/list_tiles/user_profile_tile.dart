
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/personalization/controllers/user_controller.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/image_strings.dart';
import '../appbar/myAppBarController.dart';
import '../images/my_circular_image.dart';
import '../shimmer/shimmer.dart';


class MyUserProfileTile extends StatelessWidget {
  const MyUserProfileTile({
    super.key, required this.onPressed,
  });



  final VoidCallback onPressed;


  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;
    final previousScreenController = Get.find<PreviousScreenController>();
    // Function to get the latest full name from UserController
    String getLatestFullName() {
      // Use updatedName if available, otherwise fallback to the original name
      return previousScreenController.updatedName.isNotEmpty
          ? previousScreenController.updatedName.value
          : "${controller.user.value.firstName} ${controller.user.value.lastName}";
    }

    return ListTile(
      leading: Obx(
        () {
          final networkImage = controller.user.value.profilePicture;
          final image = networkImage.isNotEmpty ? networkImage : MyImages.accountGIF;

          return controller.imageUploading.value
          ? const MyShimmerEffect(width: 100, height: 100, radius: 100)

          : MyCircularImage(
              image: image,
              isNetworkImage: networkImage.isNotEmpty,
              width: 50,
              height: 50,
              padding: 0);
        },
      ),

      title: Obx(
          () => Text(getLatestFullName(),
            style: Theme.of(context)
                .textTheme
                .headlineSmall!
                .apply(color: MyColors.white)),
      ),
      subtitle: Obx(
        ()=> Text(controller.user.value.email,
            style: Theme.of(context)
                .textTheme
                .bodyMedium!
                .apply(color: MyColors.white)),
      ),
      trailing: IconButton(
          onPressed: onPressed,
          icon: const Icon(Iconsax.edit, color: MyColors.white)),
    );
  }
}
