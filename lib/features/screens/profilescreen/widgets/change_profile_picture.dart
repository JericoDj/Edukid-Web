import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:image_picker/image_picker.dart'; // For picking images
import 'dart:io';
import 'dart:typed_data';

import '../../../personalization/controllers/user_controller.dart'; // Web file handling

class ChangeProfilePictureDialog extends StatelessWidget {
  const ChangeProfilePictureDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<UserController>(); // Get the UserController

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 400),
        // Set a maximum width for the dialog
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Choose a new profile picture.',
                style: Theme.of(context).textTheme.labelMedium,
              ),
              const SizedBox(height: 16.0),
              // Profile Image Preview
              Obx(() {
                final profilePicture = controller.user.value.profilePicture;
                return CircleAvatar(
                  radius: 50,
                  backgroundImage: profilePicture.isNotEmpty
                      ? NetworkImage(profilePicture)
                      : const AssetImage('assets/images/default_avatar.png')
                  as ImageProvider,
                );
              }),
              const SizedBox(height: 16.0),

              const SizedBox(height: 16.0),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await controller.uploadUserProfilePicture(context); // Upload the selected image
                  },
                  child: const Text('Choose a Profile Picture'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
