import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../common/data/repositories.authentication/user_repository.dart';
import '../../../../utils/network manager/network_manager.dart';
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

  Future<void> updatePhoneNumber(BuildContext context) async {
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

      if (!updatePhoneNumberFormKey.currentState!.validate()) {
        return;
      }

      Map<String, dynamic> data = {'PhoneNumber': phoneNumber.text.trim()};
      await userRepository.updateSingleField(data);

      // Update the userController's reactive user model
      userController.user.update((user) {
        user?.phoneNumber = phoneNumber.text.trim();
      });

      Navigator.of(context).pop(true); // Close the dialog with a success result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Your phone number has been updated.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }
}
