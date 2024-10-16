import 'package:flutter/material.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/pricing_calculator.dart';
import '../../../controller/product/cart_controller.dart';

class MyBillingAmountSection extends StatelessWidget {
  final double subTotal;
  final double discount; // Accept discount value

  const MyBillingAmountSection({super.key, required this.subTotal, required this.discount});

  @override
  Widget build(BuildContext context) {
    final totalDiscount = subTotal * (discount / 100);
    final discountedSubTotal = subTotal - totalDiscount;

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
            Text('-\$$totalDiscount', style: Theme.of(context).textTheme.bodyMedium), // Show discount amount
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
