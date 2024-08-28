import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../../../features/shop/models/booking_orders_model.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class MyBookingsList extends StatelessWidget {
  final List<BookingOrderModel> bookings;

  const MyBookingsList({Key? key, required this.bookings}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dark = MyHelperFunctions.isDarkMode(context);

    if (bookings.isEmpty) {
      return Center(
        child: Text(
          'Whoops! No Bookings Yet!',
          style: TextStyle(color: dark ? MyColors.light : MyColors.dark),
        ),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      itemCount: bookings.length,
      separatorBuilder: (_, __) => SizedBox(height: MySizes.spaceBtwItems),
      itemBuilder: (_, index) => Container(
        decoration: BoxDecoration(
          color: dark ? MyColors.dark : MyColors.light,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: MyColors.primaryColor.withOpacity(0.3)),
        ),
        padding: EdgeInsets.all(MySizes.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Iconsax.calendar),
                SizedBox(width: MySizes.spaceBtwItems / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking ID: ${bookings[index].id}',
                        style: TextStyle(
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Booking Date: ${bookings[index].orderDate}'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: Icon(Iconsax.arrow_right_34, size: MySizes.iconSm),
                ),
              ],
            ),
            SizedBox(height: MySizes.spaceBtwItems),
            Row(
              children: [
                const Icon(Iconsax.tag),
                SizedBox(width: MySizes.spaceBtwItems / 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status: ${bookings[index].status}',
                        style: TextStyle(
                          color: MyColors.primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Service: ${bookings[index].booking}'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
