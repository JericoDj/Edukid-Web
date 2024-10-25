import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories.authentication/user_repository.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
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
  Future<void> updateGender() async {
    // Start the loading dialog
    MyFullScreenLoader.openLoadingDialog('Updating your gender...', MyImages.loaders);

    try {
      // Check if the device is connected to the internet
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        MyLoaders.errorSnackBar(
          title: 'No Internet',
          message: 'Please check your network connection and try again.',
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

      // Close the loader and show success notification
      MyFullScreenLoader.stopLoading();
      MyLoaders.successSnackBar(
        title: 'Success',
        message: 'Your gender has been updated.',
      );

    } catch (e) {
      // In case of an error, stop the loader and show error notification
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update gender. Please try again later.',
      );
    } finally {
      // Close any open dialogs if necessary
      if (Get.isDialogOpen == true) {
        Get.back();
      }
    }
  }
}
