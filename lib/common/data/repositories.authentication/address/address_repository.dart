import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../features/models/address_model.dart';
import '../authentication_repository.dart';

class AddressRepository extends GetxController {
  static AddressRepository get instance => Get.find();
  final _db = FirebaseFirestore.instance;

  Future<List<AddressModel>> fetchUserAddresses() async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      if (userId.isEmpty) {
        throw 'Unable to find user information. Try again in few minutes.';
      }
      final result = await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .get();
      return result.docs
          .map((documentSnapshot) =>
          AddressModel.fromDocumentSnapshot(documentSnapshot))
          .toList();
    } catch (e) {
      throw 'Something went wrong while fetching Address Information. Try again later';
    }
  }

  /// Clear the "selected" field for all addresses
  Future<void> updateSelectedField(String addressId, bool selected) async {
    try {
      final userId = AuthenticationRepository.instance.authUser!.uid;
      await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .doc(addressId)
          .update({'Selected Address': selected});
    } catch (e) {
      throw 'Unable to update your address selection. Try again later';
    }
  }

  /// Store new user order
  Future<String> addAddress(AddressModel address) async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;

      // Ensure userId is not null before proceeding
      if (userId == null) {
        throw 'User ID is null. User might not be authenticated.';
      }

      // Add address to the Firestore collection
      final currentAddress = await _db
          .collection('Users')
          .doc(userId)
          .collection('Addresses')
          .add(address.toJson());

      return currentAddress.id;
    } catch (e) {
      // Log the error for debugging
      print('Error adding address: $e');
      throw 'Something went wrong while saving Address Information. Try again later';
    }
  }
}