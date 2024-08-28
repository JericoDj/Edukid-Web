
import 'package:flutter/material.dart';
import 'package:webedukid/features/shop/screens/order/widgets/orders_list.dart';
import 'package:webedukid/features/shop/screens/order/widgets/user_worksheet_downloadable_listview.dart';

import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String selectedGrade = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'My Worksheets',
          style: TextStyle(
            color: Colors.white, // Set text color to white
          ),
        ),
        backgroundColor: MyColors.primaryColor, // Set app bar color to primary color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGradeBox(context, 'Grade 1'),
                _buildGradeBox(context, 'Grade 2'),
                _buildGradeBox(context, 'Grade 3'),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildGradeBox(context, 'Grade 4'),
                _buildGradeBox(context, 'Grade 5'),
                _buildGradeBox(context, 'Grade 6'),
              ],
            ),
            const SizedBox(height: MySizes.spaceBtwSections),
            WorksheetDownloadble(),
            const SizedBox(height: MySizes.spaceBtwSections),
            Expanded(
              child: MyOrderListItems(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeBox(BuildContext context, String gradeName) {
    final isSelected = selectedGrade == gradeName;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedGrade = gradeName;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : MyColors.primaryColor.withOpacity(0.8),
            width: 2.0,
          ),
        ),
        padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 24.0),
        child: Text(
          gradeName,
          style: TextStyle(
            color: isSelected ? MyColors.primaryColor : MyColors.primaryColor.withOpacity(0.8), // Switch text color
            fontSize: 18.0,
          ),
        ),
      ),
    );
  }
}

