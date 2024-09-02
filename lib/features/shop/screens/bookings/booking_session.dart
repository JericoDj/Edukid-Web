import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

import '../booking_checkout/booking_checkout.dart';

class BookingSessionScreen extends StatelessWidget {
  final controller = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            alignment: Alignment.center,
            width: 600,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select a Date and Time', style: TextStyle(fontSize: 20)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Obx(() {
                        return TableCalendar(
                          firstDay: DateTime.utc(2023, 1, 1),
                          lastDay: DateTime.utc(2025, 12, 31),
                          focusedDay: controller.focusedDate.value,
                          selectedDayPredicate: (day) => controller.selectedDates.contains(_normalizeDate(day)),
                          onDaySelected: (selectedDay, focusedDay) {
                            controller.updateSelectedDates(_normalizeDate(selectedDay));
                          },
                          calendarStyle: CalendarStyle(
                            todayDecoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                            selectedDecoration: BoxDecoration(
                              color: controller.selectedTimeSlots.containsKey(controller.focusedDate.value)
                                  ? Colors.green
                                  : Colors.yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                          calendarBuilders: CalendarBuilders(
                            defaultBuilder: (context, date, focusedDay) {
                              Color? dayColor = controller.getDayColor(_normalizeDate(date));
                              if (dayColor == null) {
                                return Center(
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(color: Colors.black), // Default text color
                                  ),
                                );
                              }
                              return Container(
                                decoration: BoxDecoration(
                                  color: dayColor,
                                  shape: BoxShape.circle,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  '${date.day}',
                                  style: TextStyle(
                                    color: dayColor == Colors.yellow ? Colors.black : Colors.white,
                                  ),
                                ),
                              );
                            },
                            todayBuilder: (context, date, focusedDay) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue,
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
                        );
                      }),
                    ),
                    Expanded(
                      child: Obx(() {
                        final timeSlotsForDay = controller.getTimeSlotsForDate(_normalizeDate(controller.focusedDate.value));
                        if (timeSlotsForDay.isEmpty) {
                          return Center(child: Text("Please Select a Date"));
                        } else {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Time Slots for ${DateFormat.yMMMMd().format(controller.focusedDate.value)}",
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...timeSlotsForDay.map((timeSlot) {
                                bool isSelected = controller.selectedTimeSlots[_normalizeDate(controller.focusedDate.value)] == timeSlot;
                                return ListTile(
                                  title: Text(
                                    '${timeSlot.format(context)}',
                                    style: TextStyle(color: isSelected ? Colors.white : Colors.black),
                                  ),
                                  tileColor: isSelected ? Colors.green : Colors.transparent,
                                  trailing: Text('Available Slots: ${controller.getAvailableSlots(_normalizeDate(controller.focusedDate.value), timeSlot)}'),
                                  onTap: () => controller.selectTimeSlot(timeSlot),
                                );
                              }).toList(),
                            ],
                          );
                        }
                      }),
                    ),
                  ],
                ),
                Obx(() {
                  if (controller.selectedDates.isEmpty) {
                    return Center(child: Text("No Dates Selected"));
                  } else {
                    return Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: controller.selectedDates.map((date) {
                          TimeOfDay? selectedTime = controller.selectedTimeSlots[date];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: Colors.blue),
                                SizedBox(width: 8.0),
                                Text(
                                  "${DateFormat.yMMMMd().format(date)} - ${selectedTime != null ? selectedTime.format(context) : 'No Time Slot Selected'}",
                                  style: TextStyle(fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                }),
                Obx(() {
                  return Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Total Price: \$${controller.calculateTotalPrice()}'),
                  );
                }),
                SizedBox(height: 16.0),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.selectedDates.isEmpty || controller.selectedTimeSlots.isEmpty) {
                          Get.snackbar("Error", "Please select at least one date and time.");
                          return;
                        }
                        Get.to(
                          BookingCheckOutScreen(
                            pickedDates: controller.selectedDates.toList(),
                            pickedTimes: controller.selectedTimeSlots.values.toList(),
                            price: controller.calculateTotalPrice(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                      child: Obx(() => Text(
                        'Book a Session \$${controller.calculateTotalPrice()}',
                        style: TextStyle(color: Colors.white, fontSize: 18.0),
                      )),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Helper method to normalize date (remove time part)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class BookingController extends GetxController {
  var focusedDate = DateTime.now().obs;
  var selectedDates = <DateTime>{}.obs;
  var selectedTimeSlots = <DateTime, TimeOfDay>{}.obs;
  var dateSpecificTimeSlots = <DateTime, List<TimeOfDay>>{}.obs;
  var pricePerSession = 10.0.obs;

  @override
  void onInit() {
    super.onInit();
  }

  void updateSelectedDates(DateTime date) {
    date = _normalizeDate(date);
    focusedDate.value = date;
    if (selectedDates.contains(date)) {
      selectedDates.remove(date);
      selectedTimeSlots.remove(date);
      dateSpecificTimeSlots.remove(date);
    } else {
      selectedDates.add(date);
      updateTimeSlots(date);
    }
  }

  void updateTimeSlots(DateTime date) {
    // Set different time slots for each date
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
    if (selectedDates.contains(date)) {
      selectedTimeSlots[date] = timeSlot;
      update(); // Notify listeners to refresh the UI
    }
  }

  int getAvailableSlots(DateTime date, TimeOfDay timeSlot) {
    // Implement logic to return the number of available slots for a given time slot on a given date
    return 4;
  }

  double calculateTotalPrice() {
    return selectedTimeSlots.length * pricePerSession.value;
  }

  // Method to determine the color for each date
  Color? getDayColor(DateTime date) {
    if (_isSameDate(date, DateTime.now())) return Colors.blue; // Current date
    if (selectedTimeSlots.containsKey(date)) return Colors.green; // Selected date with timeslot
    if (selectedDates.contains(date) && !selectedTimeSlots.containsKey(date)) return Colors.yellow; // Selected date without timeslot
    return null; // Default color for unselected dates (null means no color applied, keeping default)
  }

  // Helper method to normalize date (remove time part)
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  // Helper method to compare dates ignoring the time part
  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
