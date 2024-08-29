import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
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
      final userOrders = await orderRepository.fetchUserOrders();
      print('Length of userOrders: ${userOrders.length}');
      return userOrders;
    } catch (e, stackTrace) {
      print('Error fetching user orders: $e');
      print('Stack Trace: $stackTrace');
      MyLoaders.warningSnackBar(title: 'Oh Snap!', message: e.toString());
      return [];
    }
  }

  /// Processes the order using the saved customer ID with Square payment integration
  void processOrder(double totalAmount) async {
    try {
      // Start Loader
      MyFullScreenLoader.openLoadingDialog('Processing your order', MyImages.loaders);

      // Get user authentication ID
      final userId = AuthenticationRepository.instance.authUser?.uid;
      if (userId == null || userId.isEmpty) {
        print("User ID is null or empty");
        return;
      }

      // Retrieve the saved customer ID and card ID from storage or backend
      final String? savedCustomerId = await _retrieveSavedCustomerId();
      final String? savedCardId = await _retrieveSavedCardId();  // Retrieve saved card ID

      // Debugging print statements
      if (savedCustomerId != null) {
        print("Saved customer ID found: $savedCustomerId");
      } else {
        print("No saved customer ID found.");
      }

      if (savedCardId != null) {
        print("Saved card ID found: $savedCardId");
      } else {
        print("No saved card ID found.");
      }

      // Print the total amount
      print("Total amount to be charged: $totalAmount");

      if (savedCustomerId != null && savedCardId != null) {
        // Process the payment using the saved customer ID and card ID
        bool paymentSuccess = await _chargeCustomer(savedCustomerId, savedCardId, totalAmount);

        if (paymentSuccess) {
          // Payment was successful, proceed to save the order and clear cart
          _saveOrderAndClearCart(userId, totalAmount);
        } else {
          MyLoaders.errorSnackBar(
            title: 'Payment Failed',
            message: 'There was an error processing your payment.',
          );
        }
      } else {
        // Handle the case where no saved customer ID or card ID is available
        MyLoaders.errorSnackBar(
          title: 'Payment Error',
          message: 'No saved customer or card information found.',
        );
      }
    } catch (e) {
      MyLoaders.errorSnackBar(
        title: 'Oh Snap',
        message: e.toString(),
      );
      print("Exception during order processing: $e");
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
      deliveryDate: DateTime.now(),
      items: cartController.cartItems.toList(),
    );

    await orderRepository.saveOrder(order);
    cartController.clearCart();

    Get.offAll(() => SuccessScreen(
      image: MyImages.accountGIF,
      title: 'Payment Success!',
      subtitle: 'Your item will be shipped soon!',
      onPressed: () => Get.offAll(() => const NavigationBarMenu()),
    ));
  }

  /// Charges the customer using the Square payment API
  Future<bool> _chargeCustomer(String customerId, String cardId, double amount) async {
    try {
      final Uuid uuid = Uuid();  // Instantiate the UUID generator

      // Print statements for debugging
      print("Charging customer with ID: $customerId using card ID: $cardId for amount: $amount");

      final response = await http.post(
        Uri.parse('http://localhost:3000/charge-customer'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'customerId': customerId,
          'cardId': cardId, // Use cardId for specifying which card to charge
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
}
