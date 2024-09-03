import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/controller/bookings/booking_order_controller.dart';
import 'package:webedukid/features/shop/models/booking_orders_model.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'package:webedukid/utils/constants/sizes.dart';

import '../../../../utils/constants/enums.dart';

class CancelledBookingsScreen extends StatelessWidget {
  const CancelledBookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingOrderController _bookingOrderController =
        BookingOrderController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cancelled Bookings'),
        backgroundColor: MyColors.primaryColor,
      ),
      body: FutureBuilder<List<BookingOrderModel>>(
        future: _bookingOrderController.fetchUserBookings(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final List<BookingOrderModel>? bookings = snapshot.data;
            if (bookings != null && bookings.isNotEmpty) {
              final filteredBookings = bookings
                  .where((booking) => booking.status == OrderStatus.cancelled)
                  .toList();

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return ListTile(
                        title: Text('Booking ${booking.id}'),
                        subtitle: Text('Status: ${booking.status}'),
                        trailing: Icon(Icons.arrow_forward_ios),
                        onTap: () {
                          // Handle booking item tap
                        },
                      );
                    },
                  ),
                ),
              );
            } else {
              return Center(child: Text('No bookings found.'));
            }
          }
        },
      ),
    );
  }
}
