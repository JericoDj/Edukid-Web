import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/screens/bookings/widget/all_user_bookings_list.dart';
import 'package:webedukid/features/shop/screens/bookings/widget/booking_tabs.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'package:webedukid/utils/constants/sizes.dart';

import '../../../../utils/constants/enums.dart';
import '../../../bookings/status/cancelled.dart';
import '../../../bookings/status/completed.dart';
import '../../../bookings/status/ongoing.dart';
import '../../../bookings/status/processing.dart';
import '../../../bookings/status/rescheduled.dart';
import '../../../bookings/status/scheduled.dart';
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
              child: _getScreenForSelectedIndex(_selectedIndex),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getScreenForSelectedIndex(int index) {
    switch (index) {
      case 0:
        return const ProcessingBookingsScreen();
      case 1:
        return const ScheduledBookingsScreen();
      case 2:
        return const OngoingBookingsScreen();
      case 3:
        return const CompletedBookingsScreen();
      case 4:
        return const RescheduledBookingsScreen();
      case 5:
        return const CancelledBookingsScreen();
      default:
        return const ProcessingBookingsScreen(); // Default to processing if index is out of range
    }
  }
}
