import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:webedukid/utils/constants/colors.dart';

class BookingController extends GetxController {
  var focusedDate = DateTime.now().obs;
  var chosenDate = DateTime.now().obs;
  var refocusFlag = false.obs;
  var selectedTimeSlots = <DateTime, TimeOfDay>{}.obs;
  var dateSpecificTimeSlots = <DateTime, List<TimeOfDay>>{}.obs;
  var pricePerSession = 1.0.obs;
  var bookedDates = <DateTime>[].obs;
  var loading = true.obs;

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

      final result = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .collection('Bookings')
          .get();

      final dates = result.docs.expand((doc) {
        final data = doc.data();
        final pickedDateTimeList = data['pickedDateTime'];

        if (pickedDateTimeList != null && pickedDateTimeList is List) {
          return pickedDateTimeList.map((item) {
            final pickedDate = item['pickedDate'];
            if (pickedDate != null && pickedDate is Timestamp) {
              final date = pickedDate.toDate();
              return normalizeDate(date);
            }
            return null;
          }).whereType<DateTime>();
        }
        return <DateTime>[];
      }).toList();

      bookedDates.assignAll(dates);
      print('Fetched bookings for user $userId: ${bookedDates.length} dates');
    } catch (e) {
      print('Error fetching booked dates: $e');
    } finally {
      loading.value = false;
    }
  }

  void updateChosenDate(DateTime date) {
    date = normalizeDate(date);

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
    DateTime date = normalizeDate(focusedDate.value);
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
    final normalizedDate = normalizeDate(date);
    if (isDateBooked(normalizedDate)) {
      return Colors.blue; // Booked date color
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
    return bookedDates.contains(normalizeDate(date));
  }

  DateTime normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
