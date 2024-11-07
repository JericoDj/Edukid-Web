import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utils/constants/enums.dart';
import '../../controller/bookings/booking_order_controller.dart';
import '../../models/booking_orders_model.dart';

class CalendarController extends GetxController {
  // Observable list to hold booking data for the calendar
  RxList<BookingOrderModel> calendarBookings = <BookingOrderModel>[].obs;

  // Observable for currently focused date in the calendar
  final Rx<DateTime> focusedDate = DateTime.now().obs;

  // Observable for currently selected date in the calendar
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  /// Fetch bookings for the calendar and populate `calendarBookings`
  Future<void> fetchCalendarBookings() async {
    try {
      final fetchedBookings = await BookingOrderController.instance.fetchUserBookings();
      if (fetchedBookings != null && fetchedBookings.isNotEmpty) {
        calendarBookings.assignAll(fetchedBookings);
      } else {
        _showErrorSnackbar('No bookings found.');
      }
    } catch (e) {
      _showErrorSnackbar('Failed to fetch bookings for calendar: $e');
    }
  }

  /// Display an error message as a snackbar
  void _showErrorSnackbar(String message) {
    if (Get.context != null && !Get.isSnackbarOpen) {
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        Get.snackbar(
          'Error',
          message,
          snackPosition: SnackPosition.BOTTOM,
        );
      });
    } else {
      print('Snackbar not shown due to missing context or an open snackbar.');
    }
  }

  /// Get color for a specific day on the calendar based on booking status
  Color getDayColor(DateTime date) {
    final List<BookingOrderModel> bookingsForDate = calendarBookings
        .where((booking) => booking.pickedDateTime
        .any((picked) => _normalizeDate(picked.pickedDate) == date))
        .toList();

    if (bookingsForDate.isEmpty) {
      return Colors.white; // Default color for dates without bookings
    }

    // Determine color based on the highest-priority booking status for that date
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

  /// Normalize the date by removing the time component
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  /// Clear all booking data when the user logs out
  void clearBookings() {
    calendarBookings.clear();
    focusedDate.value = DateTime.now();
    selectedDate.value = DateTime.now();
  }
}
