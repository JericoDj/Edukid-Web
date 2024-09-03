import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'package:webedukid/utils/constants/sizes.dart';

import '../booking_checkout/booking_checkout.dart';
import 'booking_session.dart';
import 'booking_session_controller.dart';

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
            width: 800,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Select a Date and Time',
                      style: TextStyle(fontSize: 20)),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Calendar with border
                    Expanded(
                      child: Obx(() {
                        return Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: MyColors.primaryColor, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: TableCalendar(
                            firstDay: DateTime.utc(2023, 1, 1),
                            lastDay: DateTime.utc(2025, 12, 31),
                            focusedDay: controller.focusedDate.value,
                            onDaySelected: (selectedDay, focusedDay) {
                              controller.updateChosenDate(
                                  _normalizeDate(selectedDay));
                            },
                            calendarBuilders: CalendarBuilders(
                              defaultBuilder: (context, date, focusedDay) {
                                Color dayColor = controller
                                    .getDayColor(_normalizeDate(date));

                                return Container(
                                  decoration: BoxDecoration(
                                    color: dayColor,
                                    shape: BoxShape.circle,
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${date.day}',
                                    style: TextStyle(
                                      color: dayColor == Colors.yellow ||
                                          dayColor == Colors.white
                                          ? Colors.black
                                          : Colors
                                          .white, // Adjust text color based on background
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
                      }),
                    ),
                    SizedBox(width: 16.0),
                    // Add spacing between the calendar and timeslot
                    // Timeslots with border
                    Expanded(
                      child: Obx(() {
                        final timeSlotsForDay = controller.getTimeSlotsForDate(
                            _normalizeDate(controller.focusedDate.value));
                        return Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: MyColors.primaryColor, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: timeSlotsForDay.isEmpty
                              ? Center(child: Text("Please Select a Date"))
                              : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  "Time Slots for ${DateFormat.yMMMMd().format(controller.focusedDate.value)}",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                              ...timeSlotsForDay.map((timeSlot) {
                                bool isChosen =
                                    controller.selectedTimeSlots[
                                    _normalizeDate(controller
                                        .focusedDate.value)] ==
                                        timeSlot;
                                return ListTile(
                                  title: Text(
                                    '${timeSlot.format(context)}',
                                    style: TextStyle(color: isChosen ? Colors.white : Colors.black),
                                  ),
                                  tileColor: isChosen ? MyColors.buttonPrimary : Colors.transparent,
                                  trailing: Text(
                                    'Available Slots: ${controller.getAvailableSlots(_normalizeDate(controller.focusedDate.value), timeSlot)}',
                                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                      color: isChosen ? Colors.white : Colors.black, // Change text color based on selection
                                    ),
                                  ),
                                  onTap: () => controller.selectTimeSlot(timeSlot),
                                );


                              }).toList(),
                            ],
                          ),
                        );
                      }),
                    ),
                  ],
                ),
                SizedBox(height: MySizes.spaceBtwItems),
                Obx(() {
                  final selectedDatesWithTimeSlots =
                  controller.getSelectedDates();
                  if (selectedDatesWithTimeSlots.isEmpty) {
                    return Container(); // Return an empty container instead of a Center widget with text
                  } else {
                    return Container(
                      width: 500,
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: MyColors.primaryColor),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: selectedDatesWithTimeSlots.map((date) {
                          TimeOfDay? selectedTime =
                          controller.selectedTimeSlots[date];
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    color: MyColors.primaryColor),
                                SizedBox(width: 8.0),
                                Expanded(
                                  child: Text(
                                    "${DateFormat.yMMMMd().format(date)} - ${selectedTime != null ? selectedTime.format(context) : 'No Time Slot Selected'}",
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.black),
                                  ),
                                ),
                                Text(
                                  '\$${controller.pricePerSession.value}',
                                  // Display price per session here
                                  style: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    );
                  }
                }),
                SizedBox(height: 16.0),
                Center(
                  child: SizedBox(
                    width: 400,
                    height: 40,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.getSelectedDates().isEmpty) {
                          Get.snackbar("Error",
                              "Please select at least one date and time.");
                          return;
                        }
                        Get.to(
                          BookingCheckOutScreen(
                            pickedDates: controller.getSelectedDates(),
                            pickedTimes:
                            controller.selectedTimeSlots.values.toList(),
                            price: controller.pricePerSession
                                .value, // Pass the price per session
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: MyColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                      ),
                      child: Text(
                        'Book a Session \$${controller.pricePerSession.value}',
                        // Show price per session
                        style: TextStyle(color: Colors.white, fontSize: 16.0),
                      ),
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
