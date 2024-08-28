import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';


import '../../../../features/shop/models/order_model.dart';
import '../authentication_repository.dart';

class OrderRepository extends GetxController {
  static OrderRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Get all orders related to the current user
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      // Get the user ID safely using null-aware operators
      final userId = AuthenticationRepository.instance.authUser?.uid;

      // Print the userId
      print(' ORDER REPOSITORY fetchUserOrders User ID: $userId');

      // Check if userId is not null before proceeding
      if (userId != null && userId.isNotEmpty) {
        final result = await _db.collection('Users').doc(userId).collection('Orders').get();

        // Print the result length
        print('ORDER REPOSITORY fetchUserOrders Result Length: ${result.docs.length}');

        // Print data for each document
        for (var doc in result.docs) {
          print('ORDER REPOSITORY Order Data: ${doc.data()}');
        }

        return result.docs
            .map((documentSnapshot) => OrderModel.fromSnapshot(documentSnapshot))
            .toList();
      } else {
        throw Exception('Unable to find user information. Try again in few minutes.');
      }
    } catch (e, stackTrace) {
      print('$e');

      print('ORDER REPOSITORY StackTrace: $stackTrace');
      throw e; // Re-throw the exception to propagate it further if needed
    }
  }

  /// Store a new user order
  Future<void> saveOrder(OrderModel order) async {
    try {
      // Get the user ID safely using null-aware operators
      final userId = AuthenticationRepository.instance.authUser?.uid;

      // Check if userId is not null before proceeding
      if (userId != null && userId.isNotEmpty) {
        await _db.collection('Users').doc(userId).collection('Orders').add(order.toJson());
      } else {
        throw Exception('Unable to find user information. Try again in few minutes.');
      }
    } catch (e) {
      throw Exception('Error saving Order Information: $e');
    }
  }
}
