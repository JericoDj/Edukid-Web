import 'package:get/get.dart';
import '../../../../utils/constants/enums.dart';
import '../../models/booking_orders_model.dart';
import '../../controller/bookings/booking_order_controller.dart';
import 'package:flutter/material.dart';

class CalendarController extends GetxController {
  static CalendarController get instance => Get.find();

  // Observable list of bookings for the calendar
  final RxList<BookingOrderModel> calendarBookings = <BookingOrderModel>[].obs;

  // Observable for the focused date
  final Rx<DateTime> focusedDate = DateTime.now().obs;

  // Observable for the selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs; // Add this line

  // Fetch bookings specifically for the calendar view
  Future<void> fetchCalendarBookings() async {
    try {
      final fetchedBookings = await BookingOrderController.instance.fetchUserBookings();
      calendarBookings.assignAll(fetchedBookings);
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch bookings for calendar: $e');
    }
  }

  // Determine the color for each date based on booking status
  Color getDayColor(DateTime date) {
    final List<BookingOrderModel> bookingsForDate = calendarBookings
        .where((booking) => booking.pickedDateTime
        .any((picked) => _normalizeDate(picked.pickedDate) == date))
        .toList();

    if (bookingsForDate.isEmpty) {
      return Colors.white; // Default color for dates without bookings
    }

    // Prioritize color based on the booking status
    BookingOrderModel booking = bookingsForDate.first;
    switch (booking.status) {
      case OrderStatus.processing:
        return Colors.orange;
      case OrderStatus.scheduled:
        return Colors.blue;
      case OrderStatus.ongoing:
        return Colors.green;
      case OrderStatus.completed:
        return Colors.purple;
      case OrderStatus.rescheduled:
        return Colors.yellow;
      case OrderStatus.cancelled:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // Helper method to normalize date (remove time part)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Get time slots for a particular date
  List<TimeOfDay> getTimeSlotsForDate(DateTime date) {
    // Logic to fetch and return the available time slots for the given date
    final bookingForDate = calendarBookings.firstWhereOrNull(
          (booking) => booking.pickedDateTime.any(
            (picked) => _normalizeDate(picked.pickedDate) == date,
      ),
    );

    if (bookingForDate == null) {
      return [];
    }

    return bookingForDate.pickedDateTime
        .where((picked) => _normalizeDate(picked.pickedDate) == date)
        .map((picked) => TimeOfDay.fromDateTime(picked.pickedTime))
        .toList();
  }
}
