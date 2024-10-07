import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:html' as html;

import 'package:uuid/uuid.dart';

import '../../../../common/data/repositories.authentication/product/order_repository.dart';
import '../../../../common/success_screen/sucess_screen.dart';
import '../../../../common/widgets/loaders/loaders.dart';
import '../../../../common/data/repositories.authentication/authentication_repository.dart';
import '../../../../navigation_Bar.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/popups/full_screen_loader.dart';
import '../../../screens/personalization/controllers/address_controller.dart';
import '../../models/order_model.dart';
import '../../screens/checkout/widgets/unique_key_generator.dart';
import 'cart_controller.dart';
import 'checkout_controller.dart';

class OrderController extends GetxController {
  static OrderController get instance => Get.find();

  final cartController = CartController.instance;
  final addressController = AddressController.instance;
  final checkoutController = CheckoutController.instance;
  final orderRepository = Get.put(OrderRepository());

  /// Fetches the list of orders for the current user
  Future<List<OrderModel>> fetchUserOrders() async {
    try {
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null) {
        throw Exception("User not authenticated.");
      }

      final orders = await FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: userId)
          .get();

      return orders.docs.map((doc) => OrderModel.fromSnapshot(doc)).toList();

    } catch (e) {
      MyLoaders.warningSnackBar(title: 'Error', message: e.toString());
      return [];
    }
  }

  /// Processes the order using PayPal or card payment
  void processOrder(double totalAmount) async {
    try {
      // Start Loader
      MyFullScreenLoader.openLoadingDialog('Processing your order', MyImages.loaders);

      // Get user authentication ID
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null || userId.isEmpty) {
        return;
      }

      final selectedPaymentMethod = checkoutController.selectedPaymentMethod.value;
      if (selectedPaymentMethod.name == 'PayPal') {
        _processPayPalPayment(totalAmount);
        return;
      }

      // Retrieve saved customer ID and card ID for card payment
      final String? savedCustomerId = await _retrieveSavedCustomerId();
      final String? savedCardId = await _retrieveSavedCardId();

      if (savedCustomerId != null && savedCardId != null) {
        // Process the payment using the saved customer ID and card ID
        bool paymentSuccess = await _chargeCustomer(savedCustomerId, savedCardId, totalAmount);

        if (paymentSuccess) {
          // Payment was successful, proceed to save the order and clear cart
          _saveOrderAndClearCart(userId, totalAmount);
        } else {
          MyLoaders.errorSnackBar(title: 'Payment Failed', message: 'There was an error processing your payment.');
        }
      } else {
        // Handle the case where no saved customer or card ID is available
        MyLoaders.errorSnackBar(title: 'Payment Error', message: 'No saved customer or card information found.');
      }
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Oh Snap', message: e.toString());
      print("Exception during order processing: $e");
    } finally {
      MyFullScreenLoader.stopLoading();
    }
  }

  /// PayPal payment process for mobile and web
  void _processPayPalPayment(double totalAmount) {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      Navigator.of(Get.context!).push(MaterialPageRoute(
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
              "description": "Order Total",
            }
          ],
          note: "Contact us for any questions on your order.",
          onSuccess: (Map params) async {
            _handlePayPalSuccess(totalAmount);
          },
          onError: (error) {
            _handlePayPalError();
          },
          onCancel: () {
            _handlePayPalCancel();
          },
        ),
      ));
    } else if (kIsWeb) {
      _processPayPalPaymentWeb(totalAmount);
    }
  }

  /// PayPal payment for web
  void _processPayPalPaymentWeb(double totalAmount) async {
    final String createOrderEndpoint = "https://us-central1-edukid-60f55.cloudfunctions.net/api/create_order";

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
          final html.WindowBase? popupWindow = html.window.open(approvalLink, '_blank');

          // Monitor the popup window and check order status when it closes
          Timer.periodic(Duration(seconds: 1), (timer) async {
            if (popupWindow != null && popupWindow.closed!) {
              timer.cancel();
              await _checkOrderStatus(orderID, totalAmount);  // Pass totalAmount
            }
          });
        } else {
          MyLoaders.errorSnackBar(title: 'Error', message: 'Invalid PayPal response: missing approval link or order ID.');
          MyFullScreenLoader.stopLoading();
        }
      } else {
        MyLoaders.errorSnackBar(title: 'Error', message: 'Error creating PayPal order.');
        MyFullScreenLoader.stopLoading();
      }
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Error', message: 'An error occurred while processing your payment.');
      MyFullScreenLoader.stopLoading();
    }
  }

  /// Check the status of PayPal order
  Future<void> _checkOrderStatus(String orderID, double totalAmount) async {
    final String statusEndpoint = "https://us-central1-edukid-60f55.cloudfunctions.net/api/order_status/$orderID";

    try {
      final response = await http.get(Uri.parse(statusEndpoint));

      if (response.statusCode == 200) {
        final statusData = jsonDecode(response.body);

        if (statusData['success'] == true && statusData['status'] == 'APPROVED') {
          // Payment was successful, save the order
          _saveOrderAndClearCart(AuthenticationRepository.instance.authUser!.uid, totalAmount);
          MyLoaders.successSnackBar(title: 'Payment Success', message: 'Your payment was successful!');
        } else {
          MyLoaders.errorSnackBar(title: 'Payment Failed', message: 'Payment was not successful.');
        }
      } else {
        MyLoaders.errorSnackBar(title: 'Error', message: 'Error checking payment status.');
      }
    } catch (e) {
      MyLoaders.errorSnackBar(title: 'Error', message: 'An error occurred while checking payment status.');
    } finally {
      MyFullScreenLoader.stopLoading();
    }
  }

  /// Retrieve saved customer ID from Firestore
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
        print("No saved customer ID found.");
        return null;
      }
    } else {
      print("User not authenticated.");
      return null;
    }
  }

  /// Retrieve saved card ID from Firestore
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
        print("No saved card ID found.");
        return null;
      }
    } else {
      print("User not authenticated.");
      return null;
    }
  }

  /// Charge the customer using saved details
  Future<bool> _chargeCustomer(String customerId, String cardId, double amount) async {
    try {
      final Uuid uuid = Uuid();

      final response = await http.post(
        Uri.parse('http://localhost:3000/charge-customer'),
        headers: <String, String>{'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(<String, dynamic>{
          'customerId': customerId,
          'cardId': cardId,
          'amount': (amount * 100).round(), // Convert to cents
        }),
      );

      if (response.statusCode == 200) {
        print('Payment successful: ${response.body}');
        return true;
      } else {
        print('Payment failed with status: ${response.statusCode}');
        print('Response body: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error charging customer: $e');
      return false;
    }
  }

  /// Saves the order in Firestore and clears the cart
  Future<void> _saveOrderAndClearCart(String userId, double totalAmount) async {
    final order = OrderModel(
      id: UniqueKeyGenerator.generateUniqueKey(),
      userId: userId,
      status: OrderStatus.processing,
      totalAmount: totalAmount,
      orderDate: DateTime.now(),
      paymentMethod: checkoutController.selectedPaymentMethod.value.name,
      address: addressController.selectedAddress.value,
      deliveryDate: DateTime.now(), // Adjust the delivery date as per requirement
      items: cartController.cartItems.toList(),
    );

    await orderRepository.saveOrder(order);
    cartController.clearCart();

    // Navigate to success screen
    Get.offAll(() => SuccessScreen(
      image: MyImages.accountGIF,
      title: 'Payment Success!',
      subtitle: 'Your item will be shipped soon!',
      onPressed: () => Get.offAll(() => NavigationBarMenu()),
    ));
  }

  /// Handle PayPal payment success
  void _handlePayPalSuccess(double totalAmount) async {
    _saveOrderAndClearCart(AuthenticationRepository.instance.authUser!.uid, totalAmount);
    Navigator.pop(Get.context!);
  }

  /// Handle PayPal payment error
  void _handlePayPalError() {
    MyLoaders.errorSnackBar(title: 'Payment Failed', message: 'There was an error processing your PayPal payment.');
    MyFullScreenLoader.stopLoading();
    Navigator.pop(Get.context!);
  }

  /// Handle PayPal payment cancellation
  void _handlePayPalCancel() {
    Get.snackbar("Payment Cancelled", "You cancelled the PayPal payment.", snackPosition: SnackPosition.BOTTOM);
    MyFullScreenLoader.stopLoading();
    Navigator.pop(Get.context!);
  }
}
