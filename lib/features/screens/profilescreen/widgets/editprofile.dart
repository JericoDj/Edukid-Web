import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/profile_menu.dart';

import '../../../../common/widgets/appbar.dart';
import '../../../../common/widgets/images/my_circular_image.dart';
import '../../../../common/widgets/shimmer/shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import 'change_birthday.dart';
import 'change_gender.dart';
import 'change_name.dart';
import 'change_phonenumber.dart'; // Import the ChangeName dialog


class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    // Function to get the latest full name from UserController
    String getLatestFullName() {
      return "${controller.user.value.firstName} ${controller.user.value.lastName}";
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0), // Rounded edges for the container
          child: Container(
            color: MyColors.white,
            child: SingleChildScrollView(
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
                            print("Network Image: $networkImage");
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
                            child: const Text('Change Profile Picture'),
                          ),
                        ],
                      ),
                    ),

                    // Name Field with Popup Dialog
                    Obx(() => MyProfileMenu(
                      title: 'Name',
                      value: getLatestFullName(),
                      onPressed: () async {
                        var result = await Get.dialog(
                          const ChangeNameDialog(), // Use a dialog to open ChangeName screen
                        );
                        if (result != null) {
                          // Handle result if needed
                        }
                      },
                    )),

                    // Phone Number Field with Popup Dialog
                    Obx(() => MyProfileMenu(
                      title: 'Phone Number',
                      value: controller.user.value.phoneNumber,
                      onPressed: () async {
                        var result = await Get.dialog(
                          const ChangePhoneNumberDialog(), // Use a dialog to open ChangePhoneNumber screen
                        );
                        if (result != null) {
                          // Handle result if needed
                        }
                      },
                    )),

                    // Gender Field with Popup Dialog
                    Obx(() => MyProfileMenu(
                      title: 'Gender',
                      value: controller.user.value.gender,
                      onPressed: () async {
                        var result = await Get.dialog(
                          const ChangeGenderDialog(), // Use a dialog to open ChangeGender screen
                        );
                        if (result != null) {
                          // Handle result if needed
                        }
                      },
                    )),

                    // Birthday Field with Popup Dialog
                    Obx(() => MyProfileMenu(
                      title: 'Birthday',
                      value: controller.user.value.birthday,
                      onPressed: () async {
                        var result = await Get.dialog(
                          const ChangeBirthdayDialog(), // Use a dialog to open ChangeBirthday screen
                        );
                        if (result != null) {
                          // Handle result if needed
                        }
                      },
                    )),

                    MyProfileMenu(
                      title: 'Username',
                      value: controller.user.value.username,
                      icon: Iconsax.copy,
                      onPressed: () {},
                    ),
                    SizedBox(height: MySizes.spaceBtwItems),
                    const Divider(),
                    SizedBox(height: MySizes.spaceBtwItems),
                    MyProfileMenu(
                      title: 'UserID',
                      value: controller.user.value.id,
                      icon: Iconsax.copy,
                      onPressed: () {},
                    ),
                    MyProfileMenu(
                      title: 'Email',
                      value: controller.user.value.email,
                      icon: Iconsax.copy,
                      onPressed: () {},
                    ),
                    const Divider(),
                    SizedBox(height: MySizes.spaceBtwItems),
                    Center(
                      child: TextButton(
                        onPressed: () => controller.deleteAccountWarningPopup(),
                        child: const Text(
                          'Close Account',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
