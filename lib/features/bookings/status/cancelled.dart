import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:webedukid/features/shop/controller/bookings/booking_order_controller.dart';
import 'package:webedukid/features/shop/models/booking_orders_model.dart';
import 'package:webedukid/utils/constants/colors.dart';

import '../../../../utils/constants/enums.dart';

class CancelledBookingsScreen extends StatelessWidget {
  const CancelledBookingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingOrderController _bookingOrderController =
        BookingOrderController.instance;

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Cancelled Bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: MyColors.primaryColor,
            ),
          ),
          SizedBox(height: 10),
          FutureBuilder<List<BookingOrderModel>>(
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

                  return ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: 600, maxHeight: 400),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filteredBookings.length,
                      itemBuilder: (context, index) {
                        final booking = filteredBookings[index];
                        return GestureDetector(
                          onTap: () {
                            print("Booking #${booking.id} tapped");
                            showBookingDetailsDialog(context, booking);
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
                                      Icon(Icons.cancel, color: MyColors.primaryColor),
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
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Booking Date: ${booking.orderDate}',
                                    style: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 14,
                                    ),
                                  ),
                                  SizedBox(height: 8),

                                  if (booking.pickedDateTime.isNotEmpty) ...[
                                    Text(
                                      'Picked Dates and Times:',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: MyColors.primaryColor,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 4),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: booking.pickedDateTime.map((picked) {
                                        final date = DateFormat.yMMMMd().format(picked.pickedDate);
                                        final time = DateFormat.jm().format(picked.pickedTime);

                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 4.0),
                                          child: Row(
                                            children: [
                                              Icon(Icons.access_time, color: MyColors.primaryColor),
                                              SizedBox(width: 8),
                                              Text(
                                                '$date at $time',
                                                style: TextStyle(
                                                  color: Colors.black87,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ] else ...[
                                    Text(
                                      'Picked Date: N/A',
                                      style: TextStyle(
                                        color: Colors.black87,
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                  ],

                                  Row(
                                    children: [
                                      Icon(Icons.location_on, color: MyColors.primaryColor),
                                      SizedBox(width: 8),
                                      Text(
                                        'Status: ${getStatusString(booking.status)}',
                                        style: TextStyle(
                                          color: MyColors.primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: Text('No bookings found.'));
                }
              }
            },
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  void showBookingDetailsDialog(BuildContext context, BookingOrderModel booking) {
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
                _buildDetailRow('Status:', getStatusString(booking.status)),
                _buildDetailRow('Order Date:', booking.formattedOrderDate),
                if (booking.deliveryDate != null)
                  _buildDetailRow('Delivery Date:', booking.formattedDeliveryDate),
                _buildDetailRow('Payment Method:', booking.paymentMethod),
                _buildDetailRow('Total Amount:', '\$${booking.totalAmount.toStringAsFixed(2)}'),
                if (booking.address != null)
                  _buildDetailRow('Address:', booking.address!.toString()),
                if (booking.pickedDateTime.isNotEmpty)
                  ...booking.pickedDateTime.map((picked) {
                    final date = DateFormat.yMMMMd().format(picked.pickedDate);
                    final time = DateFormat.jm().format(picked.pickedTime);
                    return _buildDetailRow('Picked Date & Time:', '$date at $time');
                  }).toList(),
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

// Helper function to convert OrderStatus to a user-friendly string
String getStatusString(OrderStatus status) {
  switch (status) {
    case OrderStatus.processing:
      return 'Processing';
    case OrderStatus.scheduled:
      return 'Scheduled';
    case OrderStatus.ongoing:
      return 'Ongoing';
    case OrderStatus.completed:
      return 'Completed';
    case OrderStatus.rescheduled:
      return 'Rescheduled';
    case OrderStatus.cancelled:
      return 'Cancelled';
    default:
      return 'Unknown Status';
  }
}
