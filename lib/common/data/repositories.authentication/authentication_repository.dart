import 'dart:io' if (dart.library.html) 'dart:html';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:go_router/go_router.dart';
import 'package:webedukid/common/data/repositories.authentication/user_repository.dart';

import '../../../drawer_controller.dart';
import '../../../features/authentication/login/login.dart';
import '../../../features/personalization/controllers/user_controller.dart';
import '../../../features/screens/homescreen/HomeScreen.dart';
import '../../../features/screens/navigation_controller.dart';
import '../../../features/screens/onboarding/onboarding.dart';
import '../../../features/screens/signup/widgets/verifyemailscreen.dart';
import '../../../myapp.dart';
import '../../../navigation_Bar.dart';
import '../../../try.dart';
import '../../../utils/constants/image_strings.dart';
import '../../../utils/exception/my_firebase_auth_exception.dart';
import '../../../utils/exception/my_firebase_exception.dart';
import '../../../utils/exception/my_format_exception.dart';
import '../../../utils/exception/my_platform_exception.dart';
import '../../../utils/local_storage/storage_utility.dart';
import '../../../utils/popups/full_screen_loader.dart';
import 'auth_controller.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final AuthController _authController = Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get authenticated user
  User? get authUser => _auth.currentUser;

  // Placeholder constant
  static const String noUser = 'NoUser';

  get userController => null;

  // Redirect based on authentication status and email verification
  Future<void> screenRedirect(BuildContext context) async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        await MyStorageUtility.init(user.uid);
        context.go('/home');
      } else {
        final userEmail = user.email ?? noUser;
        context.go('/verifyEmail', extra: {'email': userEmail});
      }
    } else {
      final isFirstTime = deviceStorage.read('IsFirstTime') ?? true;
      deviceStorage.write('IsFirstTime', isFirstTime);
      context.go(isFirstTime ? '/onBoarding' : '/login');
    }
  }

  // Email and password login
  Future<UserCredential> loginWithEmailAndPassword(String email,
      String password) async {
    try {
      return await _auth.signInWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Email and password registration
  Future<UserCredential> registerWithEmailAndPassword(String email,
      String password) async {
    try {
      return await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Check if email is already registered
  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      final querySnapshot = await _firestore.collection('Users').get();
      return querySnapshot.docs.any((document) => document['Email'] == email);
    } catch (e) {
      print('Error checking Firestore: $e');
      return false;
    }
  }

  // Re-authenticate user with email and password
  Future<void> reAuthenticateWithEmailAndPassword(String email,
      String password) async {
    try {
      final credential = EmailAuthProvider.credential(
          email: email, password: password);
      await _auth.currentUser?.reauthenticateWithCredential(credential);
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Logout and navigate to login page
  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Firebase sign out

      // Clear user data in UserController or any relevant session data here
      Get.find<UserController>().clearUser();

      // Close the drawer, then navigate to the home screen
      Navigator.of(context).pop(); // Closes the drawer
      context.go('/home'); // Resets the navigation stack to login screen
    } catch (e) {
      if (Get.overlayContext != null) {
        Get.snackbar("Error", "Logout failed. Try again.", snackPosition: SnackPosition.BOTTOM);
      }
    }
  }


  // Delete user account
  Future<void> deleteAccount(BuildContext context) async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
      context.go('/login');
    } on FirebaseAuthException catch (e) {
      throw MyFirebaseAuthException(e.code).message;
    } on FirebaseException catch (e) {
      throw MyFirebaseException(e.code).message;
    } on FormatException catch (_) {
      throw const MyFormatException();
    } on PlatformException catch (e) {
      throw MyPlatformException(e.code).message;
    } catch (e) {
      throw 'Something went wrong. Please try again';
    }
  }

  // Google sign-in
  Future<UserCredential> signInWithGoogle(BuildContext context) async {
    try {
      if (kIsWeb) {
        final googleProvider = GoogleAuthProvider();
        return await _auth.signInWithPopup(googleProvider);
      } else {
        final googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) throw Exception('Google sign-in aborted');

        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        return await _auth.signInWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      throw e.message ?? 'An error occurred during Google Sign-In';
    } catch (e) {
      print("General Exception: $e");
      throw 'An unexpected error occurred during Google Sign-In: $e';
    }
  }

  // Check authentication status and navigate to restricted content if authorized
  Widget handleRestrictedContent(BuildContext context, Widget Function() content) {
    if (_auth.currentUser != null) {
      return content();
    } else {
      Future.delayed(Duration.zero, () => context.go('/login'));
      return const SizedBox.shrink();
    }
  }
}
