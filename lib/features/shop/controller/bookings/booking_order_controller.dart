import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;
import 'package:intl/intl.dart';

import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../common/data/repositories.authentication/bookings/booking_order_repository.dart';
import '../../models/booking_orders_model.dart';
import '../payment_charging_controller.dart';
import '../product/order_controller.dart';
import '../../../../utils/constants/enums.dart';
import '../../../screens/personalization/controllers/address_controller.dart';
import '../../models/picked_date_and_time_model.dart';
import '../../screens/checkout/widgets/unique_key_generator.dart';
import '../product/checkout_controller.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class BookingOrderController extends GetxController {
  static BookingOrderController get instance => Get.find();

  final RxList<BookingOrderModel> bookings = <BookingOrderModel>[].obs;
  final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final bookingCheckoutController = OrderController.instance;
  final bookingOrderRepository = Get.put(BookingOrderRepository());

  Future<List<BookingOrderModel>> fetchUserBookings() async {
    try {
      return await bookingOrderRepository.fetchUserBookings();
    } catch (e) {
      print('Error fetching user bookings: $e');
      return [];
    }
  }

  Future<List<BookingOrderModel>> fetchAllBookings() async {
    try {
      return await bookingOrderRepository.fetchAllBookings();
    } catch (e) {
      print('Error fetching all bookings: $e');
      return [];
    }
  }

  Future<void> processOrder(
      double totalAmount,
      List<DateTime> pickedDates,
      List<TimeOfDay?> pickedTimes,
      BuildContext context,
      ) async {
    final effectiveContext = context ?? Get.overlayContext;
    if (effectiveContext == null) return;

    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) {
        print('User Error: User not authenticated');
        return;
      }

      List<PickedDateTimeModel> pickedDateTimeModels = pickedDates.asMap().entries.map((entry) {
        int i = entry.key;
        DateTime pickedDateTime = DateTime(
          entry.value.year,
          entry.value.month,
          entry.value.day,
          pickedTimes[i]?.hour ?? 0,
          pickedTimes[i]?.minute ?? 0,
        );
        return PickedDateTimeModel(pickedDate: entry.value, pickedTime: pickedDateTime);
      }).toList();

      final selectedPaymentMethod = checkoutController.selectedPaymentMethod.value;

      if (totalAmount == 0) {
        saveBooking(totalAmount, pickedDateTimeModels, selectedPaymentMethod.name, context);
        return;
      }

      if (selectedPaymentMethod.name == 'PayPal') {
        processPayPalPayment(totalAmount, pickedDateTimeModels, context);
        return;
      }

      final savedCustomerId = await retrieveSavedCustomerId();
      final savedCardId = await retrieveSavedCardId();

      if (savedCustomerId != null && savedCardId != null) {
        bool paymentSuccess = await chargeCustomer(savedCustomerId, savedCardId, totalAmount);
        if (paymentSuccess) {
          saveBooking(totalAmount, pickedDateTimeModels, selectedPaymentMethod.name, context);
        } else {
          print('Payment Failed: Payment error occurred.');
        }
      } else {
        print('Payment Error: No saved payment info found.');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void saveBooking(
      double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels,
      String paymentMethod,
      BuildContext context,
      ) {
    try {
      final booking = BookingOrderModel(
        id: UniqueKeyGenerator.generateUniqueKey(),
        userId: AuthenticationRepository.instance.authUser!.uid,
        status: OrderStatus.processing,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        paymentMethod: paymentMethod,
        address: addressController.selectedAddress.value,
        deliveryDate: DateTime.now(),
        booking: [],
        pickedDateTime: pickedDateTimeModels,
      );

      bookingOrderRepository.saveBooking(booking, context);

      // Navigate to home
      context.push('/home');
    } catch (e) {
      print('Save Error: Error saving booking: $e');
    }
  }

  void processPayPalPayment(
      double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels,
      BuildContext context,
      ) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => PaypalCheckoutView(
          sandboxMode: true,
          clientId: "Your PayPal Client ID",
          secretKey: "Your PayPal Secret Key",
          transactions: [
            {
              "amount": {
                "total": totalAmount.toStringAsFixed(2),
                "currency": "USD",
                "details": {"subtotal": totalAmount.toStringAsFixed(2), "shipping": '0'}
              },
              "description": "Booking for selected dates",
              "item_list": {
                "items": pickedDateTimeModels
                    .map((model) => {
                  "name": "Booking on ${DateFormat('MM/dd/yyyy').format(model.pickedDate)}",
                  "quantity": 1,
                  "price": (totalAmount / pickedDateTimeModels.length).toStringAsFixed(2),
                  "currency": "USD"
                })
                    .toList(),
              }
            }
          ],
          onSuccess: (Map params) => handlePayPalSuccess(totalAmount, pickedDateTimeModels, context),
          onError: (error) => handlePayPalError(context),
          onCancel: () => handlePayPalCancel(context),
        ),
      ));
    } else if (kIsWeb) {
      processPayPalPaymentWeb(totalAmount, pickedDateTimeModels, context);
    }
  }

  void processPayPalPaymentWeb(
      double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels,
      BuildContext context,
      ) async {
    final createOrderEndpoint = "https://us-central1-edukid-60f55.cloudfunctions.net/api/create_order";

    try {
      final response = await http.post(Uri.parse(createOrderEndpoint),
          headers: {'Content-Type': 'application/json'}, body: jsonEncode({'amount': totalAmount}));

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final approvalLink = responseData['approvalLink'];
        final orderID = responseData['id'];

        if (approvalLink != null && orderID != null) {
          final popupWindow = html.window.open(approvalLink, '_blank');

          Timer.periodic(Duration(seconds: 1), (timer) async {
            if (popupWindow != null && popupWindow.closed!) {
              timer.cancel();
              await checkOrderStatus(orderID, totalAmount, pickedDateTimeModels, context);
            }
          });
        } else {
          print('Error: Invalid PayPal response.');
        }
      } else {
        print('Error: Error creating PayPal order.');
      }
    } catch (e) {
      print('Error: An error occurred.');
    }
  }

  Future<void> checkOrderStatus(
      String orderID,
      double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels,
      BuildContext context,
      ) async {
    final statusEndpoint = "https://us-central1-edukid-60f55.cloudfunctions.net/api/order_status/$orderID";

    try {
      final response = await http.get(Uri.parse(statusEndpoint));

      if (response.statusCode == 200) {
        final statusData = jsonDecode(response.body);

        if (statusData['success'] == true && statusData['status'] == 'APPROVED') {
          saveBooking(totalAmount, pickedDateTimeModels, "PayPal", context);
          print('Payment Success: Your payment was successful!');
        } else {
          print('Payment Failed: Payment was not successful.');
        }
      } else {
        print('Error: Error checking payment status.');
      }
    } catch (e) {
      print('Error: An error occurred while checking payment status.');
    }
  }

  Future<String?> retrieveSavedCustomerId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentInfo')
          .doc('customerDetails')
          .get();

      return docSnapshot.exists ? docSnapshot.get('customerId') : null;
    }
    return null;
  }

  Future<String?> retrieveSavedCardId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentInfo')
          .doc('customerDetails')
          .get();

      return docSnapshot.exists ? docSnapshot.get('cardId') : null;
    }
    return null;
  }

  Future<bool> chargeCustomer(String customerId, String cardId, double totalAmount) async {
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  void handlePayPalSuccess(double totalAmount, List<PickedDateTimeModel> pickedDateTimeModels, BuildContext context) {
    saveBooking(totalAmount, pickedDateTimeModels, "PayPal", context);
    Navigator.pop(context);
  }

  void handlePayPalError(BuildContext context) {
    print('Payment Failed: There was an error with PayPal.');
    if (Navigator.of(context, rootNavigator: true).canPop()) Navigator.of(context, rootNavigator: true).pop();
  }

  void handlePayPalCancel(BuildContext context) {
    print("Payment Cancelled: You cancelled the PayPal payment.");
    if (Navigator.of(context, rootNavigator: true).canPop()) Navigator.of(context, rootNavigator: true).pop();
  }
}
