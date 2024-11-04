import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/enums.dart';
import '../../controller/bookings/booking_order_controller.dart';
import '../../models/booking_orders_model.dart';

class CalendarController extends GetxController {
  // Initialize calendarBookings as an empty observable list
  RxList<BookingOrderModel> calendarBookings = <BookingOrderModel>[].obs;

  // Observable for the focused date
  final Rx<DateTime> focusedDate = DateTime.now().obs;

  // Observable for the selected date
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  Future<void> fetchCalendarBookings() async {
    try {
      final fetchedBookings = await BookingOrderController.instance.fetchUserBookings();
      if (fetchedBookings != null) {
        calendarBookings.assignAll(fetchedBookings);
      } else {
        _showErrorSnackbar('No bookings found.');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to fetch bookings for calendar: $e');
    }
  }

  // Private method to safely show snackbar with proper context
  void _showErrorSnackbar(String message) {
    // Ensure there's a valid context and no other snackbar is currently open
    if (Get.context != null && !Get.isSnackbarOpen) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } else {
      // Fallback log for debugging if the snackbar couldn't be shown
      print('Snackbar not shown due to missing context or an open snackbar.');
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
}
