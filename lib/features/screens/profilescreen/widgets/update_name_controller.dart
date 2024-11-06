import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories.authentication/user_repository.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../personalization/controllers/user_controller.dart';

class UpdateNameController extends GetxController {
  static UpdateNameController get instance => Get.find();

  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updateUserNameFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    initializeNames();
    super.onInit();
  }

  Future<void> initializeNames() async {
    firstName.text = userController.user.value.firstName;
    lastName.text = userController.user.value.lastName;
  }

  Future<void> updateUserName(BuildContext context) async { // Added BuildContext parameter
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No internet connection.'),
            backgroundColor: Colors.redAccent,
          ),
        );
        return;
      }

      if (!updateUserNameFormKey.currentState!.validate()) {
        return;
      }

      Map<String, dynamic> name = {
        'FirstName': firstName.text.trim(),
        'LastName': lastName.text.trim(),
      };
      await userRepository.updateSingleField(name);

      // Update the userController's reactive user model
      userController.user.update((user) {
        user?.firstName = firstName.text.trim();
        user?.lastName = lastName.text.trim();
      });

      Navigator.of(context).pop(); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar( // Show success snackbar
        SnackBar(
          content: Text('Your Name has been updated.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar( // Show error snackbar
        SnackBar(
          content: Text('Oh Snap! ${e.toString()}'),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  /// Additional methods for delete account warning, uploading profile image, etc.
  Future<void> uploadUserProfilePicture() async {
    // Your implementation for uploading profile image
  }
}
