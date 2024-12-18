import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'package:webedukid/utils/constants/sizes.dart';

import '../../../../utils/constants/enums.dart';
import '../../../bookings/status/cancelled.dart';
import '../../../bookings/status/completed.dart';
import '../../../bookings/status/ongoing.dart';
import '../../../bookings/status/processing.dart';
import '../../../bookings/status/rescheduled.dart';
import '../../../bookings/status/scheduled.dart';
import '../../../screens/personalization/controllers/address_controller.dart';
import '../../controller/bookings/booking_order_controller.dart';
import '../../controller/product/cart_controller.dart';
import '../../controller/product/checkout_controller.dart';
import '../../controller/product/order_controller.dart';
import '../../controller/product/variation_controller.dart';
import '../../models/booking_orders_model.dart';
import 'calendar_controller.dart';
import 'widget/booking_tabs.dart';
import 'widget/all_user_bookings_list.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({Key? key}) : super(key: key);

  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _selectedIndex = 0;
  final CalendarController _calendarController = Get.put(CalendarController());

  @override
  void initState() {
    super.initState();
    // Lazy-load dependencies
    Get.lazyPut(() => CartController());
    Get.lazyPut(() => VariationController());
    Get.lazyPut(() => OrderController());
    Get.lazyPut(() => CheckoutController());
    Get.lazyPut(() => BookingOrderController());
    Get.lazyPut(() => AddressController());
  }

  void _onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _calendarController.fetchCalendarBookings(), // Load calendar data
        builder: (context, snapshot) {


            // Data loaded successfully, show the main content
            return _buildMainContent();
          }
        ,
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(MySizes.defaultspace),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Obx(() {
                  return _buildBookingCalendar();
                }),
                const SizedBox(width: 20),
                Container(
                  width: 500,
                  padding: const EdgeInsets.all(8.0),
                  child: _buildBookingDetails(),
                ),
              ],
            ),
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
                      Get.to(() => AllBookingsScreen());
                    },
                    style: ButtonStyle(
                      foregroundColor: MaterialStateProperty.all(MyColors.primaryColor),
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
            _getScreenForSelectedIndex(_selectedIndex),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingCalendar() {
    return Container(
      width: 350,
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(color: MyColors.primaryColor, width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: TableCalendar(
        focusedDay: _calendarController.focusedDate.value,
        firstDay: DateTime.utc(2023, 1, 1),
        lastDay: DateTime.utc(2025, 12, 31),
        calendarFormat: CalendarFormat.month,
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: MyColors.primaryColor,
            shape: BoxShape.circle,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          _calendarController.focusedDate.value = focusedDay;
          _calendarController.selectedDate.value = selectedDay;
        },
        selectedDayPredicate: (day) =>
            isSameDay(day, _calendarController.selectedDate.value),
        eventLoader: (date) {
          return _calendarController.calendarBookings
              .where((booking) => booking.pickedDateTime
              .any((picked) => picked.pickedDate == date))
              .toList();
        },
        calendarBuilders: CalendarBuilders(
          defaultBuilder: (context, date, focusedDay) {
            Color dayColor = _calendarController.getDayColor(_normalizeDate(date));
            return Container(
              decoration: BoxDecoration(
                color: dayColor,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(
                  color: dayColor == Colors.yellow || dayColor == Colors.white
                      ? Colors.black
                      : Colors.white,
                ),
              ),
            );
          },
          todayBuilder: (context, date, focusedDay) {
            return Container(
              decoration: BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                '${date.day}',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8.0),
      child: Obx(() {
        DateTime selectedDate = _calendarController.selectedDate.value;
        List<BookingOrderModel> bookingsForSelectedDate = _calendarController
            .calendarBookings
            .where((booking) => booking.pickedDateTime
            .any((picked) => isSameDay(picked.pickedDate, selectedDate)))
            .toList();

        if (bookingsForSelectedDate.isEmpty) {
          return Center(child: Text('No bookings for selected date.'));
        }

        return ListView.builder(
          shrinkWrap: true,
          itemCount: bookingsForSelectedDate.length,
          itemBuilder: (context, index) {
            final booking = bookingsForSelectedDate[index];

            return ListTile(
              title: Text('Booking ID: ${booking.id}'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${booking.status.toString().split('.').last}'),
                  if (booking.status == OrderStatus.processing) ...[
                    Text('Picked Date: ${DateFormat.yMMMMd().format(booking.pickedDateTime.first.pickedDate)}'),
                    Text('Picked Time: ${DateFormat.jm().format(booking.pickedDateTime.first.pickedTime)}'),
                  ],
                ],
              ),
              trailing: Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Handle booking item tap if needed
              },
            );
          },
        );
      }),
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
        return const ProcessingBookingsScreen();
    }
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
