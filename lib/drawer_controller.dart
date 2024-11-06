import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'features/personalization/controllers/user_controller.dart';

class MyDrawerController extends GetxController {
  var isDrawerOpen = false.obs;
  final isEditProfileDrawerOpen = false.obs;
  User? currentUser;

  final UserController userController = Get.find<UserController>();

  @override
  void onInit() {
    super.onInit();
    // Set up a listener for Firebase authentication state
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is logged in
        currentUser = user;
        userController.fetchUserProfile(user.uid); // Fetch user profile
        print("User logged in: ${currentUser?.uid}");
      } else {
        // User is not logged in
        currentUser = null;
        print("No user logged in.");
      }
      update(); // Refresh GetX controllers
    });
  }

  void openDrawer() {
    isDrawerOpen.value = true;
    isEditProfileDrawerOpen.value = false;
    if (currentUser != null) {
      print('Drawer opened with user: ${currentUser!.uid}, email: ${currentUser!.email}');
    } else {
      print('Drawer opened with no logged-in user');
    }
  }

  void closeDrawer() {
    isDrawerOpen.value = false;
    isEditProfileDrawerOpen.value = false;
  }

  void toggleEditProfileDrawer() {
    isEditProfileDrawerOpen.value = !isEditProfileDrawerOpen.value;
  }
}
