
import 'package:flutter/material.dart';

import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../booking_checkout.dart';

class BookingDetails extends StatelessWidget {
  const BookingDetails({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final BookingCheckOutScreen widget;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Details:',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: MySizes.fontSizeLg,
          ),
        ),
        SizedBox(height: 16),
        ListView.builder(
          shrinkWrap: true,
          itemCount: widget.pickedDates.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 2,
              margin: EdgeInsets.symmetric(vertical: 8),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_getMonth(widget.pickedDates[index].month)} ${widget.pickedDates[index].day}, ${widget.pickedDates[index].year}',
                            style: TextStyle(
                              color: MyColors.primaryColor,
                              fontSize: MySizes.fontSizeSm,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            widget.pickedTimes[index] != null ? '${widget.pickedTimes[index]!.format(context)}' : 'Time not selected',
                            style: TextStyle(fontSize: MySizes.fontSizeSm),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Text(
                        '\$${widget.price.toStringAsFixed(2)}', // Use the provided price for each item
                        style: TextStyle(
                          fontSize: MySizes.fontSizeMd,
                          fontWeight: FontWeight.bold,
                          color: MyColors.primaryColor,
                        ),
                        textAlign: TextAlign.end,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _getMonth(int month) {
    switch (month) {
      case 1:
        return 'January';
      case 2:
        return 'February';
      case 3:
        return 'March';
      case 4:
        return 'April';
      case 5:
        return 'May';
      case 6:
        return 'June';
      case 7:
        return 'July';
      case 8:
        return 'August';
      case 9:
        return 'September';
      case 10:
        return 'October';
      case 11:
        return 'November';
      case 12:
        return 'December';
      default:
        return '';
    }
  }
}
