import 'dart:io'; // For mobile platforms (iOS/Android)
import 'dart:typed_data'; // Used to handle web-based image data
import 'dart:html' as html; // For web file picking in Flutter web
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
import 'package:flutter/foundation.dart'; // For platform detection (kIsWeb)

class UserController extends GetxController {
  static UserController get instance => Get.find();

  final profileLoading = false.obs;
  // Initialize user with an empty UserModel instead of allowing null values
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

  /// Fetch the user's record from the repository
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

  /// Set the user data after login
  void setUser(User? firebaseUser) {
    if (firebaseUser != null) {
      user.value = UserModel(
        id: firebaseUser.uid,
        firstName: '',
        lastName: '',
        username: firebaseUser.displayName ?? '',
        email: firebaseUser.email ?? '',
        phoneNumber: firebaseUser.phoneNumber ?? '',
        profilePicture: firebaseUser.photoURL ?? '',
        gender: '',
        birthday: '',
      );
    }
  }

  /// Clear user data on logout
  void clearUser() {
    user.value = UserModel.empty(); // Set to empty user instance to indicate no user is logged in
  }

  /// Save user record to the database
  Future<void> saveUserRecord(UserCredential? userCredentials) async {
    try {
      await fetchUserRecord();

      if (user.value.id.isEmpty && userCredentials != null) {
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
          gender: '',
          birthday: '',
        );

        await userRepository.saveUserRecord(newUser);
      }
    } catch (e) {
      MyLoaders.warningSnackBar(
        title: 'Data not saved',
        message: 'Something went wrong while saving your information. You can re-save your data in your Profile.',
      );
    }
  }

  /// Pick an image from the gallery and upload
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image != null) {
        await _uploadToFirebaseStorage(File(image.path));
      }
    } catch (e) {
      MyLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to pick image from gallery',
      );
    }
  }

  /// Pick an image from the camera and upload
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image != null) {
        await _uploadToFirebaseStorage(File(image.path));
      }
    } catch (e) {
      MyLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to pick image from camera',
      );
    }
  }

  /// Upload profile picture to Firebase Storage
  Future<void> uploadUserProfilePicture() async {
    try {
      MyFullScreenLoader.openLoadingDialog('We are updating your profile picture...', MyImages.loaders);
      imageUploading.value = true;

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        MyLoaders.errorSnackBar(
          title: 'No Internet Connection',
          message: 'Please check your network connection.',
        );
        return;
      }

      if (kIsWeb) {
        final html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
        uploadInput.accept = 'image/*'; // Accept only images
        uploadInput.click();

        uploadInput.onChange.listen((event) async {
          final html.File? file = uploadInput.files?.first;
          if (file != null) {
            final reader = html.FileReader();
            reader.readAsArrayBuffer(file);

            reader.onLoadEnd.listen((event) async {
              final Uint8List? imageData = reader.result as Uint8List?;
              if (imageData != null) {
                final imageUrl = await _uploadToFirebaseStorage(imageData, file.name);
                await _updateProfilePictureUrl(imageUrl);
              }
            });
          }
        });
      } else {
        final XFile? image = await ImagePicker().pickImage(
          source: ImageSource.gallery,
          imageQuality: 70,
          maxHeight: 512,
          maxWidth: 512,
        );

        if (image != null) {
          final imageUrl = await _uploadToFirebaseStorage(File(image.path));
          await _updateProfilePictureUrl(imageUrl);
        } else {
          MyFullScreenLoader.stopLoading();
          MyLoaders.warningSnackBar(
            title: 'Cancelled',
            message: 'Profile picture update cancelled.',
          );
        }
      }
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Error Uploading Image',
        message: 'Failed to upload profile picture. Error: $e',
      );
    } finally {
      imageUploading.value = false;
      user.refresh(); // Manually trigger UI refresh
    }
  }

  /// Helper method to upload to Firebase Storage
  Future<String> _uploadToFirebaseStorage(dynamic imageFile, [String? fileName]) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isEmpty) throw Exception("User ID is not available");

      final storagePath = 'Users/Images/Profile/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = FirebaseStorage.instance.ref(storagePath);

      if (kIsWeb && imageFile is Uint8List) {
        await ref.putData(imageFile);
      } else if (imageFile is File) {
        await ref.putFile(imageFile);
      }

      return await ref.getDownloadURL();
    } catch (e) {
      throw Exception('Error uploading to Firebase: $e');
    }
  }

  /// Update profile picture URL in Firestore
  Future<void> _updateProfilePictureUrl(String imageUrl) async {
    try {
      await userRepository.updateSingleField({'ProfilePicture': imageUrl});
      user.update((user) {
        user?.profilePicture = imageUrl;
      });
      MyFullScreenLoader.stopLoading();
      Get.back(); // Close the dialog
      MyLoaders.successSnackBar(
        title: 'Profile Picture Updated',
        message: 'Your profile picture has been successfully updated!',
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Error',
        message: 'Failed to update profile picture URL. Error: $e',
      );
    }
  }

  /// Show a dialog to confirm account deletion
  void deleteAccountWarningPopup() {
    Get.defaultDialog(
      contentPadding: const EdgeInsets.all(16),
      title: 'Delete Account',
      middleText: 'Are you sure you want to delete your account permanently? This action is not reversible, and all your data will be removed permanently.',
      confirm: ElevatedButton(
        onPressed: () async {
          await deleteUserAccount();
          Get.back(); // Close the dialog after confirmation
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          side: const BorderSide(color: Colors.red),
        ),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text('Delete'),
        ),
      ),
      cancel: OutlinedButton(
        child: const Text('Cancel'),
        onPressed: () => Get.back(),
      ),
    );
  }

  /// Delete the user account from Firebase
  Future<void> deleteUserAccount() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Deleting Account...', MyImages.loaders);

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception("No user found to delete.");
      }

      await user.delete();
      await userRepository.removeUserRecord(user.uid);

      MyFullScreenLoader.stopLoading();
      Get.offAll(() => const LoginScreen());

      MyLoaders.successSnackBar(
        title: 'Account Deleted',
        message: 'Your account has been successfully deleted.',
      );
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Account Deletion Failed',
        message: e.toString(),
      );
    }
  }

  /// Re-authenticate the user with email and password
  Future<void> reAuthenticateEmailAndPasswordUser() async {
    try {
      MyFullScreenLoader.openLoadingDialog('Re-authenticating...', MyImages.loaders);

      final isConnected = await NetworkManager.instance.isConnected();
      if (!isConnected) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      if (!reAuthFormKey.currentState!.validate()) {
        MyFullScreenLoader.stopLoading();
        return;
      }

      await AuthenticationRepository.instance.reAuthenticateWithEmailAndPassword(
        verifyEmail.text.trim(),
        verifyPassword.text.trim(),
      );

      MyFullScreenLoader.stopLoading();
    } catch (e) {
      MyFullScreenLoader.stopLoading();
      MyLoaders.errorSnackBar(
        title: 'Re-authentication Failed',
        message: e.toString(),
      );
    }
  }

  /// Update the user's gender
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

  /// Update the user's birthday
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
