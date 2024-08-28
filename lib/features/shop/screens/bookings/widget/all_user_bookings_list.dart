import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../controller/bookings/booking_order_controller.dart';
import '../../../models/booking_orders_model.dart';
// Import MyColors.primaryColor

class AllBookingsScreen extends StatelessWidget {
  final BookingOrderController _bookingOrderController = Get.find<BookingOrderController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor, // Set app bar color here
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white), // Make the back button white
          onPressed: () => Get.back(), // Navigate back when pressed
        ),
        title: Text(
          'All Bookings',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Make the title text white
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add default padding
        child: Container(
          color: Colors.grey[200],
          child: FutureBuilder<List<BookingOrderModel>>(
            future: _bookingOrderController.fetchUserBookings(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // While data is loading
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // If any error occurs
                return Center(child: Text('Error: ${snapshot.error}'));
              } else {
                // If data is successfully fetched
                final List<BookingOrderModel>? bookings = snapshot.data;
                if (bookings != null && bookings.isNotEmpty) {
                  // If there are bookings
                  return ListView.builder(
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      return Card(
                        elevation: 3,
                        margin: EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          title: Text('Booking ID: ${bookings[index].id}'),
                          subtitle: Text('Status: ${bookings[index].status}'),
                        ),
                      );
                    },
                  );
                } else {
                  // If no bookings found
                  return Center(child: Text('No bookings found.'));
                }
              }
            },
          ),
        ),
      ),
    );
  }
}
