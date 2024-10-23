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

  RxString gender = ''.obs;
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    gender.value = userController.user.value.gender ?? 'Male';
    super.onInit();
  }

  Future<void> updateGender() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Updating your gender...', MyImages.loaders);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      Map<String, dynamic> data = {'Gender': gender.value};
      await userRepository.updateSingleField(data);

      userController.user.update((user) {
        user?.gender = gender.value;
      });

      Get.back();
      MyLoaders.successSnackBar(
        title: 'Success',
        message: 'Your gender has been updated.',
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Error',
        message: e.toString(),
      );
    }
  }
}
