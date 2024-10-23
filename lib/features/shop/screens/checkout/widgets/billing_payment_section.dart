import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../common/widgets/customShapes/containers/rounded_container.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../../controller/product/checkout_controller.dart';
import '../../../models/payment_method_model.dart';

class MyBillingPaymentSection extends StatelessWidget {
  const MyBillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CheckoutController>();
    final dark = MyHelperFunctions.isDarkMode(context);

    // Fetch and display the saved payment method from Firebase
    _retrieveSavedPaymentMethod(controller);

    return Column(
      children: [
        MySectionHeading(
          title: 'Payment Method',
          buttonTitle: '', // Removed the buttonTitle from here
          onPressed: null,  // Disabled this, we'll handle the button in the TextButton below
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Payment Method',
              style: Theme.of(context).textTheme.labelMedium,
            ),
            TextButton(
              onPressed: () => controller.selectPaymentMethod(context),
              child: Text(
                'Change',
                style: TextStyle(
                  color: MyColors.primaryColor, // Change button color
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: MySizes.spaceBtwItems / 2),
        Obx(
              () => Row(
            children: [
              MyRoundedContainer(
                width: 60,
                height: 35,
                backgroundColor: dark ? MyColors.light : MyColors.white,
                padding: EdgeInsets.all(MySizes.sm),
                child: Image(
                  image: AssetImage(controller.selectedPaymentMethod.value.image),
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(width: MySizes.spaceBtwItems / 2),
              Text(
                controller.selectedPaymentMethod.value.name,
                style: Theme.of(context).textTheme.bodyLarge,
              )
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _retrieveSavedPaymentMethod(CheckoutController controller) async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Fetch the stored nonce
      DocumentSnapshot docSnapshot = await userDoc.collection('paymentInfo').doc('cardNonce').get();

      if (docSnapshot.exists) {
        // Update the controller with the retrieved payment method
        controller.selectedPaymentMethod.value = PaymentMethodModel(
          name: 'Saved Card',
          image: MyImages.masterCard,
          nonce: docSnapshot['nonce'], // Use the nonce retrieved
        );
        print("Saved payment method loaded from Firebase.");
      }
    }
  }
}
