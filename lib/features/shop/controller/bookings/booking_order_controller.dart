import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;

// Import the payment service

import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../common/data/repositories.authentication/bookings/booking_order_repository.dart';
import '../../models/booking_orders_model.dart';
import '../payment_charging_controller.dart';
import '../product/order_controller.dart';

import '../../../../common/success_screen/sucess_screen.dart';
import '../../../../common/widgets/loaders/loaders.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../screens/personalization/controllers/address_controller.dart';
import '../../models/picked_date_and_time_model.dart';
import '../../screens/checkout/widgets/unique_key_generator.dart';
import '../product/checkout_controller.dart';

class BookingOrderController extends GetxController {
  static BookingOrderController get instance => Get.find();

  late final List<DateTime> pickedDates;
  late final List<TimeOfDay?> pickedTimes;

  final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final bookingCheckoutController = OrderController.instance;
  final bookingOrderRepository = Get.put(BookingOrderRepository());

  Future<List<BookingOrderModel>> fetchUserBookings() async {
    try {
      final bookings = await bookingOrderRepository.fetchUserBookings();
      return bookings;
    } catch (e, stackTrace) {
      MyLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  Future<List<BookingOrderModel>> fetchAllBookings() async {
    try {
      final bookings = await bookingOrderRepository.fetchAllBookings();
      return bookings;
    } catch (e, stackTrace) {
      print('Error fetching all bookings: $e');
      print('Stack Trace: $stackTrace');
      return [];
    }
  }

  void processOrder(double totalAmount, List<DateTime> pickedDates, List<TimeOfDay?> pickedTimes) async {
    try {
      MyFullScreenLoader.openLoadingDialog('Processing your order', MyImages.loaders);
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null || userId.isEmpty) return;

      // Create a list to store pickedDateTimeModels
      List<PickedDateTimeModel> pickedDateTimeModels = [];

      // Iterate through the pickedDates and pickedTimes to create PickedDateTimeModels
      for (int i = 0; i < pickedDates.length; i++) {
        DateTime pickedDateTime = DateTime(
          pickedDates[i].year,
          pickedDates[i].month,
          pickedDates[i].day,
          pickedTimes[i]?.hour ?? 0,
          pickedTimes[i]?.minute ?? 0,
        );
        pickedDateTimeModels.add(PickedDateTimeModel(pickedDate: pickedDates[i], pickedTime: pickedDateTime));
      }

      // Retrieve the saved customer ID and card ID from storage or backend
      final String? savedCustomerId = await _retrieveSavedCustomerId();
      final String? savedCardId = await _retrieveSavedCardId();

      if (savedCustomerId != null && savedCardId != null) {
        print("Saved customer ID found: $savedCustomerId");
        print("Saved card ID found: $savedCardId");
        print("Total amount to be charged: $totalAmount");

        // Process the payment using the saved customer ID and card ID
        bool paymentSuccess = await chargeCustomer(savedCustomerId, savedCardId, totalAmount);

        // If payment is successful, proceed with booking
        final booking = BookingOrderModel(
          id: UniqueKeyGenerator.generateUniqueKey(),
          userId: userId,
          status: OrderStatus.processing,
          totalAmount: totalAmount,
          orderDate: DateTime.now(),
          paymentMethod: checkoutController.selectedPaymentMethod.value.name,
          address: addressController.selectedAddress.value,
          deliveryDate: DateTime.now(),
          booking: [],
          pickedDateTime: pickedDateTimeModels,
        );

        if (paymentSuccess) {
          bookingOrderRepository.saveBooking(booking);
        } else {
          MyLoaders.errorSnackBar(title: 'Payment Failed', message: 'There was an error processing your payment.');
        }
      } else {
        MyLoaders.errorSnackBar(title: 'Payment Error', message: 'No saved customer or card information found.');
      }
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
    } finally {
      MyFullScreenLoader.stopLoading();
    }
  }

  /// Retrieves the saved customer ID from Firestore
  Future<String?> _retrieveSavedCustomerId() async {
    // Ensure the user is authenticated
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Retrieve the customer ID from Firestore under `customerDetails` in `paymentInfo`
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentInfo')
          .doc('customerDetails')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.get('customerId'); // Fetch customerId from `customerDetails`
      } else {
        print("No saved customer ID found in Firestore.");
        return null;
      }
    } else {
      print("User not authenticated. Cannot retrieve customer ID.");
      return null;
    }
  }

  /// Retrieves the saved card ID from Firestore
  Future<String?> _retrieveSavedCardId() async {
    // Ensure the user is authenticated
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Retrieve the card ID from Firestore under `customerDetails` in `paymentInfo`
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentInfo')
          .doc('customerDetails')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.get('cardId'); // Fetch cardId from `customerDetails`
      } else {
        print("No saved card ID found in Firestore.");
        return null;
      }
    } else {
      print("User not authenticated. Cannot retrieve card ID.");
      return null;
    }
  }

// No need for duplicate _chargeCard method since it uses the same utility function
}
