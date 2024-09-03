import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/screens/bookings/widget/all_user_bookings_list.dart';
import 'package:webedukid/features/shop/screens/bookings/widget/booking_tabs.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'package:webedukid/utils/constants/sizes.dart';

import '../../../../utils/constants/enums.dart';
import '../../../bookings/widgets/bookings_list.dart';
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
        padding: const EdgeInsets.all(MySizes.defaultspace),
        child: Column(
          children: [
            const SizedBox(height: 10),
            Stack(
              children: [
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
                Positioned(
                  right: 0,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to view all bookings
                      Get.to(() => AllBookingsScreen());
                    },
                    style: ButtonStyle(
                      foregroundColor:
                      MaterialStateProperty.all(MyColors.primaryColor),
                    ),
                    child: Text(
                      'View All Bookings',
                      style: TextStyle(color: MyColors.primaryColor),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: BookingsListScreen(
                status: _getOrderStatusForSelectedIndex(_selectedIndex), title: '',
              ),
            ),
          ],
        ),
      ),
    );
  }

  OrderStatus _getOrderStatusForSelectedIndex(int index) {
    switch (index) {
      case 0:
        return OrderStatus.processing;
      case 1:
        return OrderStatus.scheduled;
      case 2:
        return OrderStatus.ongoing;
      case 3:
        return OrderStatus.completed;
      case 4:
        return OrderStatus.rescheduled;
      case 5:
        return OrderStatus.cancelled;
      default:
        return OrderStatus.processing;
    }
  }
}

class BookingsListScreen extends StatelessWidget {
  final OrderStatus status;

  const BookingsListScreen({Key? key, required this.status, required String title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final BookingOrderController _bookingOrderController =
        BookingOrderController.instance;

    return FutureBuilder<List<BookingOrderModel>>(
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
                .where((booking) => booking.status == status)
                .toList();

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 600),
                child: MyBookingsList(bookings: filteredBookings),
              ),
            );
          } else {
            return Center(child: Text('No bookings found.'));
          }
        }
      },
    );
  }
}
