import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:webedukid/utils/constants/colors.dart';

class BookingController extends GetxController {
  var focusedDate = DateTime.now().obs;
  var chosenDate = DateTime.now().obs;
  var refocusFlag = false.obs; // Track whether the date is being refocused
  var selectedTimeSlots = <DateTime, TimeOfDay>{}.obs;
  var dateSpecificTimeSlots = <DateTime, List<TimeOfDay>>{}.obs;
  var pricePerSession = 10.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void updateChosenDate(DateTime date) {
    date = _normalizeDate(date);

    // Check if the chosen date is the same as the selected date and has a timeslot
    if (_isSameDate(chosenDate.value, date) && selectedTimeSlots.containsKey(date)) {
      if (refocusFlag.value) {
        // Deselect the date and remove associated time slots
        selectedTimeSlots.remove(date);
        dateSpecificTimeSlots.remove(date);

        // Reset focus and color
        focusedDate.value = DateTime.now();  // Change focus to a valid date within range
        refocusFlag.value = false;

        chosenDate.value = DateTime(1900);  // Use a placeholder date to remove selection
        focusedDate.refresh();  // Trigger UI update after deselection
      } else {
        refocusFlag.value = true;
      }
    } else {
      chosenDate.value = date;
      refocusFlag.value = false;
      if (!selectedTimeSlots.containsKey(date)) {
        updateTimeSlots(date);
      }
      focusedDate.value = date;  // Keep the focus on the new date until deselected
    }

    focusedDate.refresh();  // Ensure the UI is refreshed after all operations
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
      focusedDate.refresh(); // This will trigger the UI update without changing the value
    }
  }

  int getAvailableSlots(DateTime date, TimeOfDay timeSlot) {
    return 4;
  }

  double calculateTotalPrice() {
    return selectedTimeSlots.length * pricePerSession.value;
  }

  Color getDayColor(DateTime date) {
    if (_isSameDate(date, focusedDate.value)) {
      if (selectedTimeSlots.containsKey(date)) {
        return MyColors.buttonPrimary;
      } else {
        return MyColors.buttonTertiary;
      }
    }

    if (selectedTimeSlots.containsKey(date)) {
      return MyColors.buttonPrimary;
    }

    return Colors.white;
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
