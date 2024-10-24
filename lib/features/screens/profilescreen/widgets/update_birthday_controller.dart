import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories.authentication/user_repository.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../personalization/controllers/user_controller.dart';

class UpdateBirthdayController extends GetxController {
  static UpdateBirthdayController get instance => Get.find();

  // Change birthday to RxString for reactive updates
  final birthday = ''.obs;
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    birthday.value = userController.user.value.birthday ?? '';
    super.onInit();
  }

  Future<void> selectBirthday(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      birthday.value = pickedDate.toLocal().toString().split(' ')[0];
    }
  }

  Future<void> updateBirthday() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Updating your birthday...', MyImages.loaders);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      Map<String, dynamic> data = {'Birthday': birthday.value.trim()};
      await userRepository.updateSingleField(data);

      userController.user.update((user) {
        user?.birthday = birthday.value.trim();
      });

      Get.back();
      MyLoaders.successSnackBar(
        title: 'Success',
        message: 'Your birthday has been updated.',
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
