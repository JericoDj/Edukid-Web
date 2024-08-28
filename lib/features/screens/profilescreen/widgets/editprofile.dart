
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/profile_menu.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/appbar/myAppBarController.dart';
import '../../../../common/widgets/images/my_circular_image.dart';
import '../../../../common/widgets/shimmer/shimmer.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import 'change_name.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

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

    return Scaffold(
      appBar: MyAppBar(showBackArrow: true, title: Text('Profile')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(MySizes.defaultspace),
          child: Column(
            children: [
              /// Profile Picture
              SizedBox(
                width: double.infinity,
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty ? networkImage : MyImages.accountGIF;
                      print("Network Image: $networkImage"); // Print the URL or path
                      return controller.imageUploading.value
                          ? const MyShimmerEffect(width: 100, height: 100, radius: 100)
                          : MyCircularImage(
                        image: image,
                        isNetworkImage: networkImage.isNotEmpty,
                        width: 100,
                        height: 100,
                      );
                    }),
                    TextButton(
                        onPressed: () => controller.uploadUserProfilePicture(),
                        child: const Text('Change Profile Picture')),
                  ],
                ),
              ),

              // Use the function to get the latest full name dynamically
              Obx(() => MyProfileMenu(
                    title: 'Name',
                    value: getLatestFullName(),
                    onPressed: () async {
                      var result = await Get.to(() => const ChangeName());
                      if (result != null) {
                        previousScreenController.updateUIWithData(result);
                      }
                    },
                  )),

              MyProfileMenu(
                title: ' Username',
                value: controller.user.value.username,
                icon: Iconsax.copy,
                onPressed: () {},
              ),

              SizedBox(
                height: MySizes.spaceBtwItems,
              ),
              Divider(),
              SizedBox(
                height: MySizes.spaceBtwItems,
              ),

              MyProfileMenu(
                title: ' UserID',
                value: controller.user.value.id,
                icon: Iconsax.copy,
                onPressed: () {},
              ),
              MyProfileMenu(
                title: ' Email',
                value: controller.user.value.email,
                icon: Iconsax.copy,
                onPressed: () {},
              ),
              MyProfileMenu(
                title: ' Phone Number',
                value: controller.user.value.phoneNumber,
                onPressed: () {},
              ),
              MyProfileMenu(
                title: ' Gender',
                value: 'Male',
                onPressed: () {},
              ),
              MyProfileMenu(
                title: ' Birthday',
                value: 'May 28, 1997',
                onPressed: () {},
              ),

              Divider(),
              SizedBox(
                height: MySizes.spaceBtwItems,
              ),

              Center(
                child: TextButton(
                  onPressed: () => controller.deleteAccountWarningPopup(),
                  child: const Text(
                    'Close Account',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              )
            ],
          ), // Row
        ),
      ),
    );
  }
}
