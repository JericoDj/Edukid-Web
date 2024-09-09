import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../common/widgets/texts/section_heading.dart';
import '../../models/payment_method_model.dart';
import '../../../../utils/constants/image_strings.dart';
import '../../../../utils/constants/sizes.dart';
import '../../screens/checkout/widgets/payment_tile.dart';
import 'dart:html' as html; // Only for Flutter Web
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';

class   CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();
  final Rx<PaymentMethodModel> selectedPaymentMethod = PaymentMethodModel.empty().obs;

  @override
  void onInit() {
    selectedPaymentMethod.value = PaymentMethodModel(name: 'GCash', image: MyImages.gCash);
    super.onInit();
  }

  /// Select PayPal as the payment method without initiating the payment yet
  void selectPayPal() {
    selectedPaymentMethod.value = PaymentMethodModel(
      name: 'PayPal',
      image: MyImages.maya,
      nonce: null, // Since we are not processing the payment yet, set nonce to null
    );
    print("PayPal selected as payment method.");
  }


  /// Method to open the payment page in a new window (Web)
  void openPaymentPage() {
    const String paymentPageUrl = 'http://localhost:8000/payment_page.html'; // Your local server URL for testing
    html.window.open(paymentPageUrl, '_blank');

    // Listen for the message from the payment page
    html.window.onMessage.listen((event) async {
      try {
        var data = jsonDecode(event.data); // Decode JSON data received from payment page
        String nonce = data['nonce']; // Received nonce from the payment page
        Map<String, dynamic> billingAddress = data['billingAddress']; // Billing address from the payment page
        String email = data['email'];
        String firstName = data['firstName'];
        String lastName = data['lastName'];

        print('Nonce received: $nonce');

        if (nonce.isNotEmpty && email.isNotEmpty && firstName.isNotEmpty && lastName.isNotEmpty) {
          // Create customer and save the card on the server using the nonce
          Map<String, String?> result = await createCustomerAndSaveCard(nonce, email, firstName, lastName, billingAddress);

          if (result['customerId'] != null && result['cardId'] != null) {
            // Save the customer ID and card ID to Firebase
            await saveCustomerDetailsToFirebase(result['customerId']!, result['cardId']!);
            Get.snackbar('Success', 'Customer created and card saved successfully!', snackPosition: SnackPosition.BOTTOM);
          } else {
            Get.snackbar('Error open payment page', 'Failed to save customer details.', snackPosition: SnackPosition.BOTTOM);
          }
        } else {
          print('Incomplete data received from payment page.');
        }
      } catch (e) {
        print('Error processing payment page data: $e');
        Get.snackbar('Error', 'Invalid data received from payment page.', snackPosition: SnackPosition.BOTTOM);
      }
    });
  }

  /// Method to create a customer and save the card on the server
  Future<Map<String, String?>> createCustomerAndSaveCard(String nonce, String email, String firstName, String lastName, Map<String, dynamic> billingAddress) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/create-customer'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nonce': nonce,
          'email': email,
          'firstName': firstName,
          'lastName': lastName,
          'billingAddress': billingAddress
        }),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'customerId': responseData['customerId'],
          'cardId': responseData['cardId'],
        };
      } else {
        print('Error createcustomerandsavecard: Failed to create customer: ${response.body}');
        return {'customerId': null, 'cardId': null};
      }
    } catch (e) {
      print('Error createcustomerandsavecard creating customer on server: $e');
      return {'customerId': null, 'cardId': null};
    }
  }

  /// Method to save the customer ID and card ID to Firebase
  Future<void> saveCustomerDetailsToFirebase(String customerId, String cardId) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.collection('paymentInfo').doc('customerDetails').set({
        'customerId': customerId,
        'cardId': cardId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Customer and Card ID saved successfully in Firestore: $customerId, $cardId");
    } else {
      print("User not authenticated. Cannot save customer details.");
    }
  }

  /// Method to retrieve the saved customer ID and card ID from Firebase
  Future<Map<String, String?>> _retrieveCustomerDetailsFromFirebase() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('paymentInfo')
          .doc('customerDetails')
          .get();

      if (docSnapshot.exists) {
        return {
          'customerId': docSnapshot.get('customerId'),
          'cardId': docSnapshot.get('cardId')
        };
      } else {
        print("No saved customer details found in Firestore.");
        return {'customerId': null, 'cardId': null};
      }
    } else {
      print("User not authenticated. Cannot retrieve customer details.");
      return {'customerId': null, 'cardId': null};
    }
  }

  /// Method to select a payment method from the available options
  Future<PaymentMethodModel?> selectPaymentMethod(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(MySizes.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const MySectionHeading(title: 'Select Payment Method', showActionButton: false),
              const SizedBox(height: MySizes.spaceBtwSections),

              // Google Pay Tile
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'GooglePay', image: MyImages.googleLogo),
                onTap: () {
                  selectedPaymentMethod.value = PaymentMethodModel(name: 'GooglePay', image: MyImages.googleLogo);
                  Get.back(); // Return to the previous screen after selecting Google Pay
                },
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),

              // Apple Pay Tile
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'ApplePay', image: MyImages.applePay),
                onTap: () {
                  selectedPaymentMethod.value = PaymentMethodModel(name: 'ApplePay', image: MyImages.applePay);
                  Get.back(); // Return to the previous screen after selecting Apple Pay
                },
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),

              // Saved Card Tile
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'Saved Card', image: MyImages.masterCard),
                onTap: () async {
                  // Code for fetching saved card details from Firebase
                  Map<String, String?> savedDetails = await _retrieveCustomerDetailsFromFirebase();
                  if (savedDetails['customerId'] != null && savedDetails['cardId'] != null) {
                    selectedPaymentMethod.value = PaymentMethodModel(
                      name: 'Saved Card',
                      image: MyImages.masterCard,
                      nonce: savedDetails['customerId'],
                    );
                    Get.back(); // Return to the previous screen after selecting saved card
                  } else {
                    Get.snackbar('Error', 'No saved customer details found.', snackPosition: SnackPosition.BOTTOM);
                  }
                },
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),

              // Add Credit/Debit Card Tile (Web-based Payment)
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'Add Credit/Debit Card', image: MyImages.maya),
                onTap: () {
                  openPaymentPage(); // Open the payment page using the web SDK
                  Get.back(); // Return to the previous screen after selecting Credit/Debit Card
                },
              ),
              const SizedBox(height: MySizes.spaceBtwSections),

              // Add PayPal Payment Tile
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'PayPal', image: MyImages.maya), // PayPal Image
                onTap: () {
                  selectPayPal();  // Just mark PayPal as selected
                  Get.back();  // Return to the previous screen
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
