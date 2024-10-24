import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories.authentication/user_repository.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../personalization/controllers/user_controller.dart';

class UpdatePhoneNumberController extends GetxController {
  static UpdatePhoneNumberController get instance => Get.find();

  final phoneNumber = TextEditingController();
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> updatePhoneNumberFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    phoneNumber.text = userController.user.value.phoneNumber;
    super.onInit();
  }

  Future<void> updatePhoneNumber() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Updating your phone number...', MyImages.loaders);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      if (!updatePhoneNumberFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      Map<String, dynamic> data = {'PhoneNumber': phoneNumber.text.trim()};
      await userRepository.updateSingleField(data);

      userController.user.update((user) {
        user?.phoneNumber = phoneNumber.text.trim();
      });

      Get.back();
      MyLoaders.successSnackBar(
        title: 'Success',
        message: 'Your phone number has been updated.',
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
