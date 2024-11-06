import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/change_profile_picture.dart';
import 'package:webedukid/features/screens/profilescreen/widgets/profile_menu.dart';

import '../../../../common/widgets/images/my_circular_image.dart';
import '../../../../common/widgets/shimmer/shimmer.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../personalization/controllers/user_controller.dart';
import 'change_birthday.dart';
import 'change_gender.dart';
import 'change_name.dart';
import 'change_phonenumber.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  void _showTopSnackBar(BuildContext context, String message) {
    OverlayEntry overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        top: 50.0,
        left: 0,
        right: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: MyColors.darkGrey,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black45,
                  offset: Offset(0, 4),
                  blurRadius: 8.0,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 2), () {
      overlayEntry.remove();
    });
  }

  void _copyToClipboard(BuildContext context, String value) {
    Clipboard.setData(ClipboardData(text: value));
    _showTopSnackBar(context, 'Copied to clipboard!');
  }

  @override
  Widget build(BuildContext context) {
    final controller = UserController.instance;

    String getLatestFullName() {
      return "${controller.user.value.firstName} ${controller.user.value.lastName}";
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30.0),
          child: Container(
            color: MyColors.white,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30, 10, 30, 20),
                child: Column(
                  children: [
                    Obx(() {
                      final networkImage = controller.user.value.profilePicture;
                      final image = networkImage.isNotEmpty ? networkImage : MyImages.accountGIF;

                      return Column(
                        children: [
                          controller.imageUploading.value
                              ? const MyShimmerEffect(
                            width: 100,
                            height: 100,
                            radius: 100,
                          )
                              : MyCircularImage(
                            image: image,
                            isNetworkImage: networkImage.isNotEmpty,
                            width: 100,
                            height: 100,
                          ),
                          TextButton(
                            onPressed: () async {
                              var picture = await showDialog(
                                context: context,
                                builder: (context) => const ChangeProfilePictureDialog(),
                              );
                              if (picture != null) {
                                await controller.uploadUserProfilePicture(context);
                              }
                            },
                            child: const Text(
                              'Change Profile Picture',
                              style: TextStyle(color: MyColors.primaryColor),
                            ),
                          ),
                        ],
                      );
                    }),

                    // Name Field with Popup Dialog
                    Obx(() => MyProfileMenu(
                      title: 'Name',
                      value: getLatestFullName(),
                      onPressed: () async {
                        var result = await showDialog(
                          context: context,
                          builder: (context) => const ChangeNameDialog(),
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
                        var result = await showDialog(
                          context: context,
                          builder: (context) => const ChangePhoneNumberDialog(),
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
                        var result = await showDialog(
                          context: context,
                          builder: (context) => const ChangeGenderDialog(),
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
                        var result = await showDialog(
                          context: context,
                          builder: (context) => const ChangeBirthdayDialog(),
                        );
                        if (result != null) {
                          // Handle result if needed
                        }
                      },
                    )),

                    // Username Field with Copy Functionality
                    MyProfileMenu(
                      title: 'Username',
                      value: controller.user.value.username,
                      icon: Iconsax.copy,
                      onPressed: () {
                        _copyToClipboard(context, controller.user.value.username);
                      },
                    ),

                    SizedBox(height: MySizes.spaceBtwItems),
                    const Divider(),
                    SizedBox(height: MySizes.spaceBtwItems),

                    // UserID Field with Copy Functionality
                    MyProfileMenu(
                      title: 'UserID',
                      value: controller.user.value.id,
                      icon: Iconsax.copy,
                      onPressed: () {
                        _copyToClipboard(context, controller.user.value.id);
                      },
                    ),

                    // Email Field with Copy Functionality
                    MyProfileMenu(
                      title: 'Email',
                      value: controller.user.value.email,
                      icon: Iconsax.copy,
                      onPressed: () {
                        _copyToClipboard(context, controller.user.value.email);
                      },
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
