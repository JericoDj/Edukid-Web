import 'dart:io'
    if (dart.library.html) 'dart:html'; // Conditional import for platform-specific code
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/basic.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:webedukid/common/data/repositories.authentication/user_repository.dart';

import '../../../features/authentication/login/login.dart';
import '../../../features/authentication/login/login.dart';
import '../../../features/screens/onboarding/onboarding.dart';
import '../../../features/screens/signup/widgets/verifyemailscreen.dart';
import '../../../navigation_Bar.dart';
import '../../../utils/exception/my_firebase_auth_exception.dart';
import '../../../utils/exception/my_firebase_exception.dart';
import '../../../utils/exception/my_format_exception.dart';
import '../../../utils/exception/my_platform_exception.dart';
import '../../../utils/local_storage/storage_utility.dart';

class AuthenticationRepository extends GetxController {
  static AuthenticationRepository get instance => Get.find();

  final deviceStorage = GetStorage();
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Authenticated User Data
  User? get authUser => _auth.currentUser;

  // Constant representing no user
  static const String noUser = 'NoUser';

  @override
  void onReady() {
    // This will only work on mobile; consider removing for web
    // FlutterNativeSplash.remove();
    screenRedirect();
  }

  void screenRedirect() async {
    final user = _auth.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        // Initialize User Specific Storage
        await MyStorageUtility.init(user.uid);
        Get.offAll(() => const NavigationBarMenu());
      } else {
        final userEmail = user.email ?? noUser; // Use noUser if email is null
        Get.offAll(() =>
            SizedBox(
              child: VerifyEmailScreen(
                email: userEmail,
              ),
            ));
      }
    } else {
      // Set user to noUser when it is null
      if (kDebugMode) {
        print('======== GET Storage Auth Repo =======');
        print(deviceStorage.read('IsFirstTime'));
      }

      // If IsFirstTime is not set or is set to true, navigate to OnBoardingScreen
      if (deviceStorage.read('IsFirstTime') != false) {
        deviceStorage.write('IsFirstTime', true); // Set IsFirstTime to true
        Get.offAll(const OnBoardingScreen());
      } else {
        Get.offAll(() => const LoginScreen());
      }
    }
  }

  /// Sign in (email authentication)
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

  /// Register (email authentication)
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

  /// Email verification (mail verification)
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

  Future<bool> isEmailAlreadyRegistered(String email) async {
    try {
      print('Checking Firestore for existing user with email: $email');

      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await _firestore.collection('Users').get();

      bool hasSameEmail =
      querySnapshot.docs.any((document) => document['Email'] == email);

      return hasSameEmail;
    } catch (e) {
      print('Error checking Firestore: $e');
      return false;
    }
  }

  /// ReAuthenticate user (reauthenticate)
  Future<void> ReAuthenticateWithEmailAndPassword(String email,
      String password) async {
    try {
      AuthCredential credential =
      EmailAuthProvider.credential(email: email, password: password);
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

  /// Forget password (email authentication)
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

  /// valid for any authentication (logout user)
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Get.offAll(() => const LoginScreen());
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

  /// Remove user auth and Firestore account (delete user)
  Future<void> deleteAccount() async {
    try {
      await UserRepository.instance.removeUserRecord(_auth.currentUser!.uid);
      await _auth.currentUser?.delete();
      Get.offAll(() => const LoginScreen());
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


  /// Google Sign-In (google authentication)
  Future<UserCredential> signInWithGoogle() async {
    try {
      print("Starting Google Sign-In process");
      if (kIsWeb) {
        // For web, use signInWithPopup or signInWithRedirect
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();

        final UserCredential userCredential =
        await _auth.signInWithPopup(googleProvider);

        print("Google Sign-In successful, user: ${userCredential.user?.email}");
        return userCredential;
      } else {
        // For mobile, continue with the existing code
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        if (googleUser == null) {
          throw Exception('Google sign-in aborted');
        }

        final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final UserCredential userCredential =
        await _auth.signInWithCredential(credential);
        print("Google Sign-In successful, user: ${userCredential.user?.email}");
        return userCredential;
      }
    } on FirebaseAuthException catch (e) {
      print("FirebaseAuthException: ${e.message}");
      throw e.message ?? 'An error occurred during Google Sign-In';
    } catch (e) {
      print("General Exception: $e");
      throw 'An unexpected error occurred during Google Sign-In: $e';
    }
  }

}


