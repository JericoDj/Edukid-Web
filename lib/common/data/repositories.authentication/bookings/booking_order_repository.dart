import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../../../features/shop/models/booking_orders_model.dart';
import '../../../../navigation_Bar.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../success_screen/sucess_screen.dart';
import '../authentication_repository.dart';

class BookingOrderRepository extends GetxController {
  static BookingOrderRepository get instance => Get.find();

  final FirebaseFirestore _db = FirebaseFirestore.instance;




  /// Get all bookings related to the current user
  Future<List<BookingOrderModel>> fetchUserBookings() async {
    try {
      // Get the user ID safely using null-aware operators
      final userId = AuthenticationRepository.instance.authUser?.uid;

      // ;

      // Check if userId is not null before proceeding
      if (userId != null && userId.isNotEmpty) {
        final result = await _db.collection('Users').doc(userId).collection('Bookings').get();


        return result.docs
            .map((documentSnapshot) => BookingOrderModel.fromSnapshot(documentSnapshot))
            .toList();
      } else {
        throw Exception('Unable to find user information. Try again in a few minutes.');
      }
    } catch (e, stackTrace) {



      throw e; // Re-throw the exception to propagate it further if needed
    }
  }



  /// Store a new user booking
  Future<void> saveBooking(BookingOrderModel booking) async {
    try {
      // Get the user ID safely using null-aware operators
      final userId = AuthenticationRepository.instance.authUser?.uid;

      // Check if userId is not null before proceeding
      if (userId != null && userId.isNotEmpty) {
        await _db.collection('Users').doc(userId).collection('Bookings').add(booking.toJson());

        Get.offAll(() => SuccessScreen(
          image: MyImages.accountGIF,
          title: 'Booking Successful!',
          subtitle: 'Your booking has been confirmed!',
          onPressed: () => Get.offAll(() => const NavigationBarMenu()),
        ));
      } else {
        throw Exception('Unable to find user information. Try again in a few minutes.');
      }
    } catch (e) {
      throw Exception('Error saving Booking Information: $e');
    }
  }


  /// Fetch all bookings from the database
  Future<List<BookingOrderModel>> fetchAllBookings() async {
    try {
      final result = await _db.collectionGroup('Bookings').get();
      return result.docs.map((documentSnapshot) => BookingOrderModel.fromSnapshot(documentSnapshot)).toList();
    } catch (e, stackTrace) {
      throw e;
    }
  }
}