
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/screens/bookings/widget/all_user_bookings_list.dart';
import 'package:webedukid/features/shop/screens/bookings/widget/booking_tabs.dart';

import '../../../../utils/constants/enums.dart';
import '../../../../utils/constants/sizes.dart';

import '../../../bookings/widgets/bookings_list.dart';
import '../../../screens/homescreen/widgets/promo_slider.dart';
import '../../controller/bookings/booking_order_controller.dart';
import '../../models/booking_orders_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedIndex = 0;
  final BookingOrderController _bookingOrderController =
      BookingOrderController.instance;

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(MySizes.defaultspace), // Add padding here
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
                // Center MyTabBookingBar
                Align(
                  alignment: Alignment.center,
                  child: MyTabBookingBar(
                    tabs: [
                      TabData(label: 'Processing', icon: Icons.access_alarm),
                      TabData(label: 'Scheduled', icon: Icons.schedule),
                      TabData(label: 'Ongoing', icon: Icons.timer),
                      TabData(label: 'Completed', icon: Icons.check),
                      TabData(label: 'Rescheduled', icon: Icons.refresh),
                      TabData(label: 'Cancelled', icon: Icons.cancel),
                    ],
                    onTabSelected: _onTabSelected,
                    selectedIndex: _selectedIndex,
                  ),
                ),
                // Align "View All Bookings" button to the right
                Positioned(
                  right: 0,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to view all bookings
                      Get.to(() => AllBookingsScreen());
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(Colors.blue),
                    ),
                    child: Text(
                      'View All Bookings',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<BookingOrderModel>>(
                future: _bookingOrderController.fetchUserBookings(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final List<BookingOrderModel>? bookings = snapshot.data;
                    if (bookings != null && bookings.isNotEmpty) {
                      // Filter bookings based on selected tab
                      List<BookingOrderModel> filteredBookings;
                      switch (_selectedIndex) {
                        case 0:
                          filteredBookings = bookings
                              .where((booking) =>
                          booking.status == OrderStatus.processing)
                              .toList();
                          break;
                        case 1:
                          filteredBookings = bookings
                              .where((booking) =>
                          booking.status == OrderStatus.scheduled)
                              .toList();
                          break;
                        case 2:
                          filteredBookings = bookings
                              .where((booking) =>
                          booking.status == OrderStatus.ongoing)
                              .toList();
                          break;
                        case 3:
                          filteredBookings = bookings
                              .where((booking) =>
                          booking.status == OrderStatus.completed)
                              .toList();
                          break;
                        case 4:
                          filteredBookings = bookings
                              .where((booking) =>
                          booking.status == OrderStatus.rescheduled)
                              .toList();
                          break;
                        case 5:
                          filteredBookings = bookings
                              .where((booking) =>
                          booking.status == OrderStatus.cancelled)
                              .toList();
                          break;
                        default:
                          filteredBookings = [];
                          break;
                      }

                      return Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 600), // Set the maximum width
                          child: MyBookingsList(bookings: filteredBookings),
                        ),
                      );
                    } else {
                      return Center(child: Text('No bookings found.'));
                    }
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
