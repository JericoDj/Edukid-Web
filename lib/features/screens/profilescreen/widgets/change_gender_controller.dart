import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories.authentication/user_repository.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../personalization/controllers/user_controller.dart';

class UpdateGenderController extends GetxController {
  static UpdateGenderController get instance => Get.find();

  // Observable string to hold the gender selection
  RxString gender = ''.obs;

  // User controller instance
  final userController = UserController.instance;

  // User repository instance
  final UserRepository userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    // Initialize gender with the current user's gender or a default value
    gender.value = userController.user.value.gender ?? 'Male';
    super.onInit();
  }

  // Function to update the gender in Firestore and locally
  Future<void> updateGender(BuildContext context) async {
    try {
      // Check if the device is connected to the internet
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

      // Data to update in Firestore
      Map<String, dynamic> data = {'Gender': gender.value};

      // Update gender in the repository
      await userRepository.updateSingleField(data);

      // Update the gender in the user controller to reflect changes in the UI
      userController.user.update((user) {
        user?.gender = gender.value;
      });

      Navigator.of(context).pop(true); // Close the dialog with success result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your gender has been updated.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update gender. Please try again later.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
