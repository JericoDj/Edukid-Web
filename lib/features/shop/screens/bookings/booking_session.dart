import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:webedukid/common/data/repositories.authentication/authentication_repository.dart';
import 'package:webedukid/utils/constants/colors.dart';
import 'package:webedukid/utils/constants/sizes.dart';

import '../../../authentication/login/login.dart';
import '../booking_checkout/booking_checkout.dart';
import 'booking_session_controller.dart';

class BookingSessionScreen extends StatelessWidget {
  final controller = Get.put(BookingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        // Show a loading indicator while fetching data
        if (controller.loading.value) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        // Once data is loaded, display the calendar
        return SingleChildScrollView(
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
                    child: Text(
                      'Select a Date and Time',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Calendar with border
                      Expanded(
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(color: MyColors.primaryColor, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Obx(() {
                            return TableCalendar(
                              firstDay: DateTime.utc(2023, 1, 1),
                              lastDay: DateTime.utc(2025, 12, 31),
                              focusedDay: controller.focusedDate.value,
                              onDaySelected: (selectedDay, focusedDay) {
                                // Ensure only future dates can be selected
                                if (selectedDay.isAfter(DateTime.now())) {
                                  controller.updateChosenDate(_normalizeDate(selectedDay));
                                } else {
                                  Get.snackbar("Invalid Date", "You cannot select today's date or past dates.");
                                }
                              },
                              calendarBuilders: CalendarBuilders(
                                defaultBuilder: (context, date, focusedDay) {
                                  Color dayColor;

                                  // If the date is in the past (including today), disable it
                                  if (date.isBefore(DateTime.now()) ||
                                      date.isAtSameMomentAs(DateTime.now())) {
                                    dayColor = Colors.grey.withOpacity(0.5); // Gray out past dates
                                  } else {
                                    dayColor = controller.getDayColor(date);
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
                                        color: dayColor == Colors.yellow || dayColor == Colors.white
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                                  );
                                },
                                disabledBuilder: (context, date, focusedDay) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Colors.grey.withOpacity(0.5),
                                      shape: BoxShape.circle,
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '${date.day}',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                        ),
                      ),

                      SizedBox(width: 16.0),
                      // Timeslots with border
                      Expanded(
                        child: Container(
                          height: 400,
                          decoration: BoxDecoration(
                            border: Border.all(color: MyColors.primaryColor, width: 2.0),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          padding: EdgeInsets.all(8.0),
                          child: Obx(() {
                            final normalizedDate = _normalizeDate(controller.focusedDate.value);
                            final timeSlotsForDay = controller.getTimeSlotsForDate(normalizedDate);

                            // Check if the selected date is in the list of booked dates
                            if (controller.isDateBooked(normalizedDate)) {
                              return Center(
                                child: Text(
                                  "You already have a current session booked on this date",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: MyColors.primaryColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              );
                            }

                            // If no time slots are available for the selected date
                            if (timeSlotsForDay.isEmpty) {
                              return Center(
                                child: Text("Please Select a Date"),
                              );
                            }

                            // Otherwise, show the available time slots
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    "Time Slots for ${DateFormat.yMMMMd().format(normalizedDate)}",
                                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                ...timeSlotsForDay.map((timeSlot) {
                                  bool isChosen = controller.selectedTimeSlots[normalizedDate] == timeSlot;
                                  return ListTile(
                                    title: Text(
                                      '${timeSlot.format(context)}',
                                      style: TextStyle(color: isChosen ? Colors.white : Colors.black),
                                    ),
                                    tileColor: isChosen ? MyColors.buttonPrimary : Colors.transparent,
                                    trailing: Text(
                                      'Available Slots: ${controller.getAvailableSlots(normalizedDate, timeSlot)}',
                                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                        color: isChosen ? Colors.white : Colors.black,
                                      ),
                                    ),
                                    onTap: () => controller.selectTimeSlot(timeSlot),
                                  );
                                }).toList(),
                              ],
                            );
                          }),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: MySizes.spaceBtwItems),
                  Obx(() {
                    final selectedDatesWithTimeSlots = controller.getSelectedDates();
                    if (selectedDatesWithTimeSlots.isEmpty) {
                      return Container();
                    } else {
                      return Container(
                        width: 400,
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: MyColors.primaryColor),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: selectedDatesWithTimeSlots.map((date) {
                            TimeOfDay? selectedTime = controller.selectedTimeSlots[date];
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                children: [
                                  Icon(Icons.calendar_today, color: MyColors.primaryColor),
                                  SizedBox(width: 8.0),
                                  Expanded(
                                    child: Text(
                                      "${DateFormat.yMMMMd().format(date)} - ${selectedTime != null ? selectedTime.format(context) : 'No Time Slot Selected'}",
                                      style: TextStyle(fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                  Text(
                                    '\$${controller.pricePerSession.value}',
                                    style: TextStyle(fontSize: 16, color: Colors.black),
                                  ),
                                  SizedBox(width: 8.0),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () {
                                      // Functionality for deleting the selected date and time slot
                                      controller.selectedTimeSlots.remove(date);
                                      controller.focusedDate.refresh(); // Refresh the focused date to update the calendar view
                                    },
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
                            Get.snackbar("Error", "Please select at least one date and time.");
                            return;
                          }
                          // Handle authentication before proceeding
                          if (AuthenticationRepository.instance.authUser == null) {
                            Get.to(() => const LoginScreen()); // Redirect to login if not authenticated
                            return;
                          }
                          // If authenticated, proceed to BookingCheckOutScreen
                          Get.to(
                            BookingCheckOutScreen(
                              pickedDates: controller.getSelectedDates(),
                              pickedTimes: controller.selectedTimeSlots.values.toList(),
                              price: controller.pricePerSession.value,
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
                          style: TextStyle(color: Colors.white, fontSize: 16.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
