import 'package:flutter/material.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/pricing_calculator.dart';

class MyBookingBillingAmountSection extends StatelessWidget {
  final double subTotal;
  final double discount; // Accept the discount value

  const MyBookingBillingAmountSection({
    Key? key,
    required this.subTotal,
    required this.discount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final totalDiscount = subTotal * (discount / 100); // Calculate discount in dollars
    final discountedSubTotal = subTotal - totalDiscount; // Calculate subtotal after discount

    return Column(
      children: [
        /// SubTotal
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
            Text('\$$subTotal', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: MySizes.spaceBtwItems / 2),

        /// Discount
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Discount', style: Theme.of(context).textTheme.bodyMedium),
            Text('-\$$totalDiscount', style: Theme.of(context).textTheme.bodyMedium), // Display the discount
          ],
        ),
        const SizedBox(height: MySizes.spaceBtwItems / 2),

        /// Shipping Fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Shipping Fee', style: Theme.of(context).textTheme.bodyMedium),
            Text('\$${MyPricingCalculator.calculateShippingCost(discountedSubTotal, 'US')}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: MySizes.spaceBtwItems / 2),

        /// Tax Fee
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Tax Fee', style: Theme.of(context).textTheme.bodyMedium),
            Text('\$${MyPricingCalculator.calculateTax(discountedSubTotal, 'US')}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: MySizes.spaceBtwItems / 2),

        /// Order Total
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Order Total', style: Theme.of(context).textTheme.bodyMedium),
            Text('\$${MyPricingCalculator.calculateTotalPrice(discountedSubTotal, 'US')}', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: MySizes.spaceBtwItems / 2),
      ],
    );
  }
}
