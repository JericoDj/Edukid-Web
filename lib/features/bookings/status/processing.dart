import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/controller/bookings/booking_order_controller.dart';
import 'package:webedukid/features/shop/models/booking_orders_model.dart';
import 'package:webedukid/utils/constants/colors.dart';

import '../../../../utils/constants/enums.dart';

class ProcessingBookingsScreen extends StatelessWidget {
  const ProcessingBookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingOrderController _bookingOrderController =
        BookingOrderController.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('Processing Bookings'),
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
                  .where((booking) => booking.status == OrderStatus.processing)
                  .toList();

              return Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: 600),
                  child: ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (context, index) {
                      final booking = filteredBookings[index];
                      return GestureDetector(
                        onTap: () {
                          print("Booking #${booking.id} tapped");
                          _showBookingDetailsDialog(context, booking);
                        },
                        child: Card(
                          elevation: 4,
                          margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(Icons.calendar_today, color: MyColors.primaryColor),
                                    SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Booking ID: ${booking.id}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.arrow_forward_ios, color: MyColors.primaryColor),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Booking Date: ${booking.orderDate}',
                                  style: TextStyle(color: Colors.black54),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, color: MyColors.primaryColor),
                                    SizedBox(width: 8),
                                    Text(
                                      'Status: ${booking.status}',
                                      style: TextStyle(color: MyColors.primaryColor),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8),
                                Text(
                                  'Service: [ ]',
                                  style: TextStyle(color: Colors.black54),
                                ),
                              ],
                            ),
                          ),
                        ),
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

  void _showBookingDetailsDialog(BuildContext context, BookingOrderModel booking) {
    print("Showing details for Booking ID: ${booking.id}"); // Debugging
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Booking Details',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: MyColors.primaryColor,
                  ),
                ),
                SizedBox(height: 10),
                _buildDetailRow('Booking ID:', booking.id),
                _buildDetailRow('Status:', booking.status.toString()),
                _buildDetailRow('Order Date:', booking.formattedOrderDate),
                if (booking.deliveryDate != null)
                  _buildDetailRow('Delivery Date:', booking.formattedDeliveryDate),
                _buildDetailRow('Payment Method:', booking.paymentMethod),
                _buildDetailRow('Total Amount:', '\$${booking.totalAmount.toStringAsFixed(2)}'),
                if (booking.address != null)
                  _buildDetailRow('Address:', booking.address!.toString()),
                if (booking.pickedDateTime.isNotEmpty)
                  ...booking.pickedDateTime.map((picked) => _buildDetailRow('Picked Date & Time:', '${picked.pickedDate} at ${picked.pickedTime}')).toList(),
                SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: MyColors.primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text('Close'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[700]),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
