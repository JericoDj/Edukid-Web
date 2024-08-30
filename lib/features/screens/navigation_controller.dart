import 'package:get/get.dart';

class NavigationController extends GetxController {
  var currentScreen = 'home'.obs; // Default to the home screen

  void navigateTo(String screenKey) {
    currentScreen.value = screenKey;
  }
}
