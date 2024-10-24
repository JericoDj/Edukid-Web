import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:webedukid/utils/constants/colors.dart';

class BookingController extends GetxController {
  var focusedDate = DateTime.now().obs;
  var chosenDate = DateTime.now().obs;
  var refocusFlag = false.obs;
  var selectedTimeSlots = <DateTime, TimeOfDay>{}.obs;
  var dateSpecificTimeSlots = <DateTime, List<TimeOfDay>>{}.obs;
  var pricePerSession = 1.0.obs;
  var bookedDates = <DateTime>[].obs;
  var loading = true.obs; // Add this to track loading state

  @override
  void onInit() {
    super.onInit();
    fetchUserBookedDates();
  }

  Future<void> fetchUserBookedDates() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        print('User not authenticated.');
        loading.value = false;
        return;
      }

      // Fetch all documents under the user's 'Bookings' subcollection
      final result = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Bookings')
          .get();

      print('Total documents found in Bookings for user $userId: ${result.docs.length}');

      // Extract dates from 'pickedDateTime'
      final dates = result.docs.expand((doc) {
        final data = doc.data();
        final pickedDateTimeList = data['pickedDateTime'];

        // Ensure it's a list and iterate over each item in the list
        if (pickedDateTimeList != null && pickedDateTimeList is List) {
          return pickedDateTimeList.map((item) {
            final pickedDate = item['pickedDate'];
            if (pickedDate != null && pickedDate is Timestamp) {
              final date = pickedDate.toDate();
              return DateTime(date.year, date.month, date.day);
            }
            return null;
          }).whereType<DateTime>();
        }
        return <DateTime>[];
      }).toList();

      bookedDates.assignAll(dates);

      // Print the fetched dates for verification
      print('Fetched bookings for user $userId: ${bookedDates.length} dates');
      for (var date in bookedDates) {
        print('Booked date: ${DateFormat.yMMMMd().format(date)}');
      }

    } catch (e) {
      print('Error fetching booked dates: $e');
    } finally {
      loading.value = false; // Set loading to false after data is fetched
    }
  }

  void updateChosenDate(DateTime date) {
    date = _normalizeDate(date);

    if (_isSameDate(chosenDate.value, date) &&
        selectedTimeSlots.containsKey(date)) {
      if (refocusFlag.value) {
        selectedTimeSlots.remove(date);
        dateSpecificTimeSlots.remove(date);

        focusedDate.value = DateTime.now();
        refocusFlag.value = false;
        chosenDate.value = DateTime(1900);
        focusedDate.refresh();
      } else {
        refocusFlag.value = true;
      }
    } else {
      chosenDate.value = date;
      refocusFlag.value = false;
      if (!selectedTimeSlots.containsKey(date)) {
        updateTimeSlots(date);
      }
      focusedDate.value = date;
    }

    focusedDate.refresh();
  }

  List<DateTime> getSelectedDates() {
    return selectedTimeSlots.keys.toList();
  }

  void updateTimeSlots(DateTime date) {
    dateSpecificTimeSlots[date] = [
      TimeOfDay(hour: 10, minute: 30),
      TimeOfDay(hour: 12, minute: 30),
      TimeOfDay(hour: 13, minute: 40),
      TimeOfDay(hour: 14, minute: 50),
      TimeOfDay(hour: 16, minute: 10),
      TimeOfDay(hour: 17, minute: 20),
      TimeOfDay(hour: 18, minute: 30),
    ];
  }

  List<TimeOfDay> getTimeSlotsForDate(DateTime date) {
    return dateSpecificTimeSlots[date] ?? [];
  }

  void selectTimeSlot(TimeOfDay timeSlot) {
    DateTime date = _normalizeDate(focusedDate.value);
    if (chosenDate.value == date) {
      selectedTimeSlots[date] = timeSlot;
      focusedDate.refresh();
    }
  }

  int getAvailableSlots(DateTime date, TimeOfDay timeSlot) {
    return 4;
  }

  double calculateTotalPrice() {
    return selectedTimeSlots.length * pricePerSession.value;
  }

  Color getDayColor(DateTime date) {
    final normalizedDate = _normalizeDate(date);
    if (isDateBooked(normalizedDate)) {
      return Colors.blue; // Color for booked dates
    }
    if (_isSameDate(normalizedDate, focusedDate.value)) {
      if (selectedTimeSlots.containsKey(normalizedDate)) {
        return MyColors.buttonPrimary;
      } else {
        return MyColors.buttonTertiary;
      }
    }
    if (selectedTimeSlots.containsKey(normalizedDate)) {
      return MyColors.buttonPrimary;
    }
    return Colors.white;
  }

  bool isDateBooked(DateTime date) {
    return bookedDates.contains(date);
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
