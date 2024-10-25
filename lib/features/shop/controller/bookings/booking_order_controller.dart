import 'dart:async';
import 'dart:convert';
import 'dart:developer';
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
import '../../../../common/success_screen/sucess_screen.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../screens/personalization/controllers/address_controller.dart';
import '../../models/picked_date_and_time_model.dart';
import '../../screens/checkout/widgets/unique_key_generator.dart';
import '../product/checkout_controller.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class BookingOrderController extends GetxController {
  static BookingOrderController get instance => Get.find();

  // Observable list of bookings
  final RxList<BookingOrderModel> bookings = <BookingOrderModel>[].obs;

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

  /// Start the loader as soon as processOrder starts
  void processOrder(
      double totalAmount,
      List<DateTime> pickedDates,
      List<TimeOfDay?> pickedTimes,
      BuildContext context,
      ) async {
    final effectiveContext = context ?? Get.overlayContext;
    if (effectiveContext == null) {
      debugPrint("No context available to show loading dialog.");
      return;
    }

    try {
      MyFullScreenLoader.openLoadingDialog('Processing your order', MyImages.loaders, context: effectiveContext);

      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null || userId.isEmpty) {
        MyLoaders.errorSnackBar(
            title: 'User Error', message: 'User not authenticated');
        MyFullScreenLoader.stopLoading();
        return;
      }

      List<PickedDateTimeModel> pickedDateTimeModels = [];
      for (int i = 0; i < pickedDates.length; i++) {
        DateTime pickedDateTime = DateTime(
          pickedDates[i].year,
          pickedDates[i].month,
          pickedDates[i].day,
          pickedTimes[i]?.hour ?? 0,
          pickedTimes[i]?.minute ?? 0,
        );
        pickedDateTimeModels.add(PickedDateTimeModel(
            pickedDate: pickedDates[i], pickedTime: pickedDateTime));
      }

      final selectedPaymentMethod =
          checkoutController.selectedPaymentMethod.value;

      if (totalAmount == 0) {
        _saveBooking(totalAmount, pickedDateTimeModels,
            selectedPaymentMethod.name, context); // Pass context here
        return;
      }

      if (selectedPaymentMethod.name == 'PayPal') {
        _processPayPalPayment(
            totalAmount, pickedDateTimeModels, context); // Pass context
        return;
      }

      // Handle saved card payment method if it’s not PayPal
      final String? savedCustomerId = await _retrieveSavedCustomerId();
      final String? savedCardId = await _retrieveSavedCardId();

      if (savedCustomerId != null && savedCardId != null) {
        bool paymentSuccess =
            await chargeCustomer(savedCustomerId, savedCardId, totalAmount);
        if (paymentSuccess) {
          _saveBooking(totalAmount, pickedDateTimeModels,
              selectedPaymentMethod.name, context); // Pass context here
        } else {
          MyLoaders.errorSnackBar(
              title: 'Payment Failed',
              message: 'There was an error processing your payment.');
          MyFullScreenLoader.stopLoading();
        }
      } else {
        MyLoaders.errorSnackBar(
            title: 'Payment Error',
            message: 'No saved customer or card information found.');
        MyFullScreenLoader.stopLoading();
      }
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
      MyFullScreenLoader.stopLoading();
    }
  }

  void _saveBooking(
      double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels,
      String paymentMethod,
      BuildContext context) {
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

      bookingOrderRepository.saveBooking(booking);
      MyLoaders.successSnackBar(
          title: 'Booking Confirmed',
          message: 'Your booking has been successfully confirmed!');

      // Navigate to order confirmation using GoRouter
      context.push('/orderConfirmation');
    } finally {
      MyFullScreenLoader.stopLoading(); // Stop loader after saving the booking
    }
  }

  /// PayPal payment process for mobile and web
  void _processPayPalPayment(double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels, BuildContext context) {
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
                "details": {
                  "subtotal": totalAmount.toStringAsFixed(2),
                  "shipping": '0',
                  "shipping_discount": 0
                }
              },
              "description": "Booking for selected dates",
              "item_list": {
                "items": pickedDateTimeModels
                    .map((model) => {
                          "name":
                              "Booking on ${DateFormat('MM/dd/yyyy').format(model.pickedDate)}",
                          "quantity": 1,
                          "price": (totalAmount / pickedDateTimeModels.length)
                              .toStringAsFixed(2),
                          "currency": "USD"
                        })
                    .toList(),
              }
            }
          ],
          note: "Contact us for any questions on your order.",
          onSuccess: (Map params) async {
            _handlePayPalSuccess(
                totalAmount, pickedDateTimeModels, context); // Pass context
          },
          onError: (error) {
            _handlePayPalError(context); // Pass context to the method
          },
          onCancel: () {
            _handlePayPalCancel(context); // Pass context to the method
          },
        ),
      ));
    } else if (kIsWeb) {
      _processPayPalPaymentWeb(
          totalAmount, pickedDateTimeModels, context); // Pass context
    }
  }

  /// Removed capture order request from Flutter client
  void _processPayPalPaymentWeb(
      double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels,
      BuildContext context) async {
    final String createOrderEndpoint =
        "https://us-central1-edukid-60f55.cloudfunctions.net/api/create_order";

    try {
      final response = await http.post(
        Uri.parse(createOrderEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'amount': totalAmount}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final approvalLink = responseData['approvalLink'];
        final orderID = responseData['id'];

        if (approvalLink != null && orderID != null) {
          final html.WindowBase? popupWindow =
              html.window.open(approvalLink, '_blank');

          Timer.periodic(Duration(seconds: 1), (timer) async {
            if (popupWindow != null && popupWindow.closed!) {
              timer.cancel();
              await _checkOrderStatus(orderID, totalAmount,
                  pickedDateTimeModels, context); // Pass context here
            }
          });
        } else {
          MyLoaders.errorSnackBar(
              title: 'Error',
              message:
                  'Invalid PayPal response: missing approval link or order ID.');
          MyFullScreenLoader.stopLoading();
        }
      } else {
        MyLoaders.errorSnackBar(
            title: 'Error', message: 'Error creating PayPal order.');
        MyFullScreenLoader.stopLoading();
      }
    } catch (e) {
      MyLoaders.errorSnackBar(
          title: 'Error',
          message: 'An error occurred while processing your payment.');
      MyFullScreenLoader.stopLoading();
    }
  }

  Future<void> _checkOrderStatus(
      String orderID,
      double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels,
      BuildContext context) async {
    final String statusEndpoint =
        "https://us-central1-edukid-60f55.cloudfunctions.net/api/order_status/$orderID";

    try {
      final response = await http.get(Uri.parse(statusEndpoint));

      if (response.statusCode == 200) {
        final statusData = jsonDecode(response.body);

        if (statusData['success'] == true &&
            statusData['status'] == 'APPROVED') {
          // Payment was successful, save the booking
          _saveBooking(totalAmount, pickedDateTimeModels, "PayPal", context);
          MyLoaders.successSnackBar(
              title: 'Payment Success',
              message: 'Your payment was successful!');
        } else {
          MyLoaders.errorSnackBar(
              title: 'Payment Failed', message: 'Payment was not successful.');
        }
      } else {
        MyLoaders.errorSnackBar(
            title: 'Error', message: 'Error checking payment status.');
      }
    } catch (e) {
      MyLoaders.errorSnackBar(
          title: 'Error',
          message: 'An error occurred while checking payment status.');
    } finally {
      MyFullScreenLoader.stopLoading();
    }
  }

  Future<String?> _retrieveSavedCustomerId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentInfo')
          .doc('customerDetails')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.get('customerId');
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<String?> _retrieveSavedCardId() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentInfo')
          .doc('customerDetails')
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        return docSnapshot.get('cardId');
      } else {
        return null;
      }
    } else {
      return null;
    }
  }

  Future<bool> chargeCustomer(
      String customerId, String cardId, double totalAmount) async {
    await Future.delayed(Duration(seconds: 2));
    return true;
  }

  void _handlePayPalSuccess(double totalAmount,
      List<PickedDateTimeModel> pickedDateTimeModels, BuildContext context) {
    _saveBooking(totalAmount, pickedDateTimeModels, "PayPal",
        context); // Pass context for navigation
    Navigator.pop(context);
  }

  void _handlePayPalError(BuildContext context) {
    MyLoaders.errorSnackBar(
      title: 'Payment Failed',
      message: 'There was an error processing your PayPal payment.',
    );
    MyFullScreenLoader.stopLoading();
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Close the loading dialog
    }
  }

  void _handlePayPalCancel(BuildContext context) {
    Get.snackbar(
      "Payment Cancelled",
      "You cancelled the PayPal payment.",
      snackPosition: SnackPosition.BOTTOM,
    );
    MyFullScreenLoader.stopLoading();
    if (Navigator.of(context, rootNavigator: true).canPop()) {
      Navigator.of(context, rootNavigator: true)
          .pop(); // Close the loading dialog
    }
  }
}
