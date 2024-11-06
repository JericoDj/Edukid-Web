import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../common/data/repositories.authentication/user_repository.dart';
import '../../../../utils/network manager/network_manager.dart';
import '../../../personalization/controllers/user_controller.dart';

class UpdateBirthdayController extends GetxController {
  static UpdateBirthdayController get instance => Get.find();

  final birthday = ''.obs;
  final userController = UserController.instance;
  final userRepository = Get.put(UserRepository());

  @override
  void onInit() {
    // Initialize the birthday with the current user's birthday, formatted
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
      // Format the selected date as "MMMM d, yyyy" for user readability
      birthday.value = DateFormat('MMMM d, yyyy').format(pickedDate);
    }
  }

  Future<void> updateBirthday(BuildContext context) async {
    try {
      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        _showSnackBar(context, 'No internet connection.', Colors.redAccent);
        return;
      }

      Map<String, dynamic> data = {'Birthday': birthday.value.trim()};
      await userRepository.updateSingleField(data);

      // Update the user’s birthday in the controller for the UI to reflect the change
      userController.user.update((user) {
        user?.birthday = birthday.value.trim();
      });

      Navigator.of(context).pop(true); // Close the dialog with success result
      _showSnackBar(context, 'Your birthday has been updated.', Colors.green);
    } catch (e) {
      _showSnackBar(context, 'Error: ${e.toString()}', Colors.redAccent);
    }
  }

  // Utility method to show a SnackBar
  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
