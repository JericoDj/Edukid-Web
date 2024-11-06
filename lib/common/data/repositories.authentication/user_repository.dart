import 'dart:io';
import 'package:cross_file/cross_file.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../features/models/user_model.dart';
import '../../../utils/exception/my_firebase_exception.dart';
import '../../../utils/exception/my_format_exception.dart';
import '../../../utils/exception/my_platform_exception.dart';
import 'authentication_repository.dart';

class UserRepository extends GetxController {
  static UserRepository get instance => Get.find();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Save user data to Firestore.
  Future<void> saveUserRecord(UserModel user) async {
    try {
      await _db.collection("Users").doc(user.id).set(user.toJson());
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

  /// Check if the user document exists in Firestore.
  Future<bool> userDocumentExists(String userId) async {
    try {
      final doc = await _db.collection("Users").doc(userId).get();
      return doc.exists;
    } catch (e) {
      print('Error checking user document existence: $e');
      return false;
    }
  }

  /// Create a new user document in Firestore with the provided details.
  Future<void> createUserDocument({
    required String id,
    required String email,
    String? displayName,
    String? photoURL,
  }) async {
    try {
      await _db.collection("Users").doc(id).set({
        'Email': email,
        'DisplayName': displayName ?? '',
        'PhotoURL': photoURL ?? '',
        'CreatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error creating user document: $e');
    }
  }

  /// Fetch user details by ID.
  Future<UserModel> fetchUserDetailsById(String userId) async {
    try {
      final doc = await _db.collection('Users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromSnapshot(doc); // Ensure UserModel has a fromSnapshot method
      } else {
        throw Exception("User not found");
      }
    } catch (e) {
      throw Exception("Error fetching user details: $e");
    }
  }

  /// Fetch user details based on the currently authenticated user.
  Future<UserModel> fetchUserDetails() async {
    try {
      final documentSnapshot = await _db
          .collection("Users")
          .doc(AuthenticationRepository.instance.authUser?.uid)
          .get();
      if (documentSnapshot.exists) {
        return UserModel.fromSnapshot(documentSnapshot);
      } else {
        return UserModel.empty();
      }
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

  /// Fetch user credentials by email.
  Future<UserCredential?> fetchUserCredentialsByEmail(String email) async {
    try {
      final querySnapshot = await _db
          .collection("Users")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final user = querySnapshot.docs.first;
        final emailCredential = EmailAuthProvider.credential(
          email: user['email'],
          password: user['password'],
        );

        return await FirebaseAuth.instance.signInWithCredential(emailCredential);
      } else {
        return null;
      }
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

  /// Check if an email exists in Firestore.
  Future<String?> getEmailFromFirestore(String email) async {
    try {
      final querySnapshot = await _db
          .collection("Users")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return email;
      } else {
        return null;
      }
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

  /// Fetch user details by email.
  Future<UserModel?> fetchUserDetailsByEmail(String email) async {
    try {
      final querySnapshot = await _db
          .collection("Users")
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first;
        return UserModel.fromSnapshot(userDoc);
      } else {
        return null;
      }
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

  /// Update user data in Firestore.
  Future<void> updateUserDetails(UserModel updatedUser) async {
    try {
      await _db.collection("Users").doc(updatedUser.id).update(updatedUser.toJson());
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

  /// Update a single field in Firestore for the authenticated user, creating the document if it doesn't exist.
  Future<void> updateSingleField(Map<String, dynamic> json) async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) {
        throw Exception("No authenticated user found.");
      }

      final userDocRef = _db.collection("Users").doc(userId);
      final userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        // Update existing document if it exists
        await userDocRef.update(json);
      } else {
        // Create a new document if it doesn't exist
        await userDocRef.set(json);
      }
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


  /// Remove user data from Firestore.
  Future<void> removeUserRecord(String userId) async {
    try {
      await _db.collection("Users").doc(userId).delete();
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

  /// Upload an image to Firebase Storage.
  Future<String> uploadImage(String path, XFile image) async {
    try {
      final ref = FirebaseStorage.instance.ref(path).child(image.name);
      await ref.putFile(File(image.path));
      final url = await ref.getDownloadURL();
      return url;
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
}
