import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../common/data/repositories.authentication/user_repository.dart';
import '../../../common/widgets/loaders/loaders.dart';
import '../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/network manager/network_manager.dart';
import '../../../utils/popups/full_screen_loader.dart';
import '../../authentication/login/login.dart';
import '../../models/user_model.dart';
import '../../screens/signup/widgets/re_authenticate_user_login_form.dart';

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  Rx<UserModel> user = UserModel.empty().obs;
  final hidePassword = false.obs;
  final imageUploading = false.obs;
  final verifyEmail = TextEditingController();
  final verifyPassword = TextEditingController();
  final userRepository = Get.put(UserRepository());
  GlobalKey<FormState> reAuthFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();
    fetchUserRecord();
  }

  Future<void> fetchUserRecord() async {
    try {
      profileLoading.value = true;
      final fetchedUser = await userRepository.fetchUserDetails();
      user(fetchedUser);
    } catch (e) {
      user(UserModel.empty());
    } finally {
      profileLoading.value = false;
    }
  }

  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      await fetchUserRecord();

      if (user.value.id.isEmpty) {
        if (userCredentials != null) {
          final nameParts = UserModel.nameParts(userCredentials.user!.displayName ?? '');
          final username = UserModel.generateUsername(userCredentials.user!.displayName ?? '');

          final newUser = UserModel(
            id: userCredentials.user!.uid,
            firstName: nameParts[0],
            lastName: nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '',
            username: username,
            email: userCredentials.user!.email ?? '',
            phoneNumber: userCredentials.user!.phoneNumber ?? '',
            profilePicture: userCredentials.user!.photoURL ?? '',
            gender: '', // Optional field, can be set later
            birthday: '', // Optional field, can be set later
          );

          await userRepository.saveUserRecord(newUser);
        }
      }
    } catch (e) {
      MyLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(MySizes.md),
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account permanently? This action is not reversible and all of your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async => deleteUserAccount(),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: MySizes.lg),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Navigator.of(Get.overlayContext!).pop(),
      ),
    );
  }

  void deleteUserAccount() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Processing', MyImages.loaders);
      final auth = AuthenticationRepository.instance;
      final provider = auth.authUser!.providerData.map((e) => e.providerId).first;

      if (provider == 'google.com') {
        await auth.signInWithGoogle();
        await auth.deleteAccount();
        MyFullScreenLoader.stopLoading();
        Get.offAll(() => const LoginScreen());
      } else if (provider == 'password') {
        MyFullScreenLoader.stopLoading();
        Get.to(() => const ReAuthLoginForm());
      }
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Processing', MyImages.loaders);
      final isConnected = await NetworkManager.instance.isConnected();

      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance
          .ReAuthenticateWithEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );

      await AuthenticationRepository.instance.deleteAccount();

      MyFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
    }
  }

  Future<void> uploadUserProfilePicture() async {
    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxHeight: 512,
        maxWidth: 512,
      );

      if (image != null) {
        imageUploading.value = true;

        // Get the old profile picture URL
        final oldProfilePictureUrl = user.value.profilePicture;

        // Call the private method to delete old profile picture from Firebase Storage
        await _deleteOldProfilePicture(oldProfilePictureUrl);

        // Upload the new profile picture
        final imageUrl = await userRepository.uploadImage(
          'Users/Images/Profile/',
          image,
        );

        // Update the document with the new profile picture URL
        final json = {'ProfilePicture': imageUrl};
        await userRepository.updateSingleField(json);

        user.value.profilePicture = imageUrl;
        MyLoaders.successSnackBar(
          title: 'Congratulations',
          message: 'Your Profile Image has been updated!',
        );
      }
    } catch (e) {
      MyLoaders.errorSnackBar(
          title: 'Oh Snap', message: 'Something went wrong $e');
    } finally {
      imageUploading.value = false;
    }
  }

  Future<void> _deleteOldProfilePicture(String oldProfilePictureUrl) async {
    if (oldProfilePictureUrl.isNotEmpty && oldProfilePictureUrl != MyImages.accountGIF) {
      try {
        final fileNameWithQuery = oldProfilePictureUrl.split('/').last;

        // Remove query parameters to get the actual filename
        final fileName = Uri.parse(fileNameWithQuery).pathSegments.last;

        // Remove leading 'Users/Images/Profile/' from the filename if present
        final cleanFileName = fileName.replaceFirst('Users/Images/Profile/', '');

        // Reference to the old profile picture in Firebase Storage
        final storageReference = FirebaseStorage.instance.ref('Users/Images/Profile/$cleanFileName');

        // Delete the old profile picture from Firebase Storage
        await storageReference.delete();
      } catch (e) {
        print('Error deleting old profile picture from Firebase Storage: $e');
      }
    }
  }

  Future<void> updateGender(String gender) async {
    try {
      MyFullScreenLoader.openLoadingDialog('Updating Gender...', MyImages.loaders);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      final json = {'Gender': gender};
      await userRepository.updateSingleField(json);

      // Update the userController's reactive user model
      user.update((user) {
        user?.gender = gender;
      });

      MyFullScreenLoader.stopLoading();
      MyLoaders.successSnackBar(
        title: 'Gender Updated',
        message: 'Your gender has been updated successfully.',
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: e.toString(),
      );
    }
  }

  Future<void> updateBirthday(String birthday) async {
    try {
      MyFullScreenLoader.openLoadingDialog('Updating Birthday...', MyImages.loaders);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      final json = {'Birthday': birthday};
      await userRepository.updateSingleField(json);

      // Update the userController's reactive user model
      user.update((user) {
        user?.birthday = birthday;
      });

      MyFullScreenLoader.stopLoading();
      MyLoaders.successSnackBar(
        title: 'Birthday Updated',
        message: 'Your birthday has been updated successfully.',
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Oh Snap!',
        message: e.toString(),
      );
    }
  }
}
