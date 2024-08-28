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

class CheckoutController extends GetxController {
  static CheckoutController get instance => Get.find();
  final Rx<PaymentMethodModel> selectedPaymentMethod = PaymentMethodModel.empty().obs;

  @override
  void onInit() {
    selectedPaymentMethod.value = PaymentMethodModel(name: 'GCash', image: MyImages.gCash);
    super.onInit();
  }

  /// Method to open the payment page in a new window (Web)
  void openPaymentPage() {
    const String paymentPageUrl = 'http://localhost:8000/payment_page.html'; // Your local server URL for testing
    html.window.open(paymentPageUrl, '_blank');

    // Listen for the message from the payment page
    html.window.onMessage.listen((event) async {
      String nonce = event.data; // Received nonce from the payment page
      print('Nonce received: $nonce');

      if (nonce.isNotEmpty) {
        // Save the nonce to Firebase
        await saveNonceToFirebase(nonce);
      } else {
        print('No nonce received or nonce is empty.');
      }
    });
  }

  Future<void> saveNonceToFirebase(String nonce) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      await userDoc.collection('paymentInfo').doc('cardNonce').set({
        'nonce': nonce,
        'timestamp': FieldValue.serverTimestamp(),
      });

      print("Card nonce saved successfully in Firestore: $nonce");
    } else {
      print("User not authenticated. Cannot save card nonce.");
    }
  }

  /// Method to retrieve the saved card nonce from Firestore
  Future<String?> _retrieveSavedCardNonce() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference userDoc =
      FirebaseFirestore.instance.collection('users').doc(user.uid);

      DocumentSnapshot docSnapshot =
      await userDoc.collection('paymentInfo').doc('cardNonce').get();

      if (docSnapshot.exists) {
        String? nonce = docSnapshot.get('nonce');
        print("Retrieved nonce: $nonce");
        return nonce;
      } else {
        print("No saved nonce found.");
        return null;
      }
    } else {
      print("User not authenticated. Cannot retrieve card nonce.");
      return null;
    }
  }

  /// Method to handle the card entry completion event
  void _onCardEntryComplete() {
    print("Card entry completed successfully.");
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
                  Get.back();
                },
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),

              // Apple Pay Tile
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'ApplePay', image: MyImages.applePay),
                onTap: () {
                  selectedPaymentMethod.value = PaymentMethodModel(name: 'ApplePay', image: MyImages.applePay);
                  Get.back();
                },
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),

              // Saved Card Tile
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'Saved Card', image: MyImages.masterCard),
                onTap: () async {
                  String? savedCardNonce = await _retrieveSavedCardNonce();

                  if (savedCardNonce != null) {
                    print("Retrieved saved card nonce: $savedCardNonce");
                    selectedPaymentMethod.value = PaymentMethodModel(
                      name: 'Saved Card',
                      image: MyImages.masterCard,
                      nonce: savedCardNonce,
                    );
                    Get.back();
                  } else {
                    print("No saved card found.");
                    Get.snackbar('Error', 'No saved card found.', snackPosition: SnackPosition.BOTTOM);
                  }
                },
              ),
              const SizedBox(height: MySizes.spaceBtwItems / 2),

              // Add Credit/Debit Card Tile (Web-based Payment)
              MyPaymentTile(
                paymentMethod: PaymentMethodModel(name: 'Add Credit/Debit Card', image: MyImages.maya),
                onTap: () {
                  openPaymentPage(); // Open the payment page using the web SDK
                },
              ),
              const SizedBox(height: MySizes.spaceBtwSections),
            ],
          ),
        ),
      ),
    );
  }
}
