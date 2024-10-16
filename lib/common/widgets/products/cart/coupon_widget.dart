import 'package:flutter/material.dart';
import 'package:webedukid/common/widgets/products/cart/validate_promo_code.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import '../../../../utils/helpers/helper_functions.dart';
import '../../customShapes/containers/rounded_container.dart';

class MyCouponCode extends StatefulWidget {
  final Function(double discount) onDiscountApplied; // Add a callback to pass discount

  const MyCouponCode({super.key, required this.onDiscountApplied});

  @override
  MyCouponCodeState createState() => MyCouponCodeState();
}

class MyCouponCodeState extends State<MyCouponCode> {
  final TextEditingController _promoCodeController = TextEditingController();
  String? _errorMessage;
  double? _discount;

  /// Function to apply promo code and handle the result
  Future<void> applyPromoCode() async {
    String promoCode = _promoCodeController.text.trim();

    if (promoCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a promo code';
        _discount = null; // Clear discount if any
      });
      return;
    }

    // Validate the promo code using the helper function from validate_promo_code.dart
    double? discount = await validatePromoCode(promoCode);

    if (discount != null) {
      setState(() {
        _discount = discount;
        _errorMessage = null; // Clear any error message
      });
      widget.onDiscountApplied(discount); // Pass discount to parent widget
      print('Promo code applied successfully. Discount: $discount%');
    } else {
      setState(() {
        _errorMessage = 'Invalid promo code';
        _discount = null; // Clear the discount if invalid
      });
      print('Invalid promo code');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyRoundedContainer(
          showBorder: true,
          backgroundColor: dark ? MyColors.dark : MyColors.white,
          padding: const EdgeInsets.only(
            top: MySizes.sm,
            bottom: MySizes.sm,
            right: MySizes.sm,
            left: MySizes.md,
          ),
          child: Row(
            children: [
              /// Promo code text field
              Flexible(
                child: TextFormField(
                  controller: _promoCodeController,
                  decoration: const InputDecoration(
                    hintText: 'Have a promo code? Enter here',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                  ),
                ),
              ),

              /// Apply button
              SizedBox(
                width: 100,
                child: ElevatedButton(
                  onPressed: applyPromoCode, // Call the function to apply promo code
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.withOpacity(0.2),
                    foregroundColor:
                    dark ? MyColors.white.withOpacity(0.5) : MyColors.dark.withOpacity(0.5),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ),

        /// Display discount if valid
        if (_discount != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              'Discount applied: $_discount%',
              style: const TextStyle(color: Colors.green),
            ),
          ),

        /// Display error message if any
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red),
            ),
          ),
      ],
    );
  }
}
