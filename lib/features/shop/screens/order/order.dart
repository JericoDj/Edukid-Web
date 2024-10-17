import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({Key? key}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String selectedGrade = '';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColors.primaryColor, // Set app bar color to primary color
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Worksheets',
              style: TextStyle(
                color: Colors.white, // Set text color to white
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20), // Space between title and grade boxes
            _buildGradeBox(context, 'Grade 1'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 2'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 3'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 4'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 5'),
            const SizedBox(width: 5),
            _buildGradeBox(context, 'Grade 6'),
          ],
        ),
        centerTitle: true, // Center the row in the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: MySizes.spaceBtwSections),
            // There is a widget here (WorksheetDownloadble), don't remove this comment
            const SizedBox(height: MySizes.spaceBtwSections),

            /// Fetch orders from Firestore and display them
            Expanded(
              child: _buildOrdersList(),
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
          color: isSelected ? Theme.of(context).primaryColor.withOpacity(0.2) : MyColors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : MyColors.primaryColor.withOpacity(0.8),
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0), // Adjusted padding for smaller boxes
        child: Text(
          gradeName,
          style: TextStyle(
            color: isSelected ? MyColors.primaryColor : MyColors.primaryColor.withOpacity(0.8),
            fontSize: 10.0,
          ),
        ),
      ),
    );
  }

  /// Fetch orders from Firestore and build a filtered list view based on selected grade
  Widget _buildOrdersList() {
    User? user = _auth.currentUser; // Get current authenticated user

    if (user == null) {
      return Center(child: Text('Please log in to see your orders'));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: _firestore.collection('Users').doc(user.uid).collection('Orders').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No orders found'));
        }

        final orders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            var items = List.from(order['items']);

            return FutureBuilder(
              future: _fetchMatchingProducts(items),
              builder: (context, AsyncSnapshot<List<Widget>> productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
                  return SizedBox.shrink(); // No matching products for the selected grade
                }

                return Column(
                  children: productSnapshot.data!,
                );
              },
            );
          },
        );
      },
    );
  }

  /// Fetch matching products based on the items in the order and the selected grade
  Future<List<Widget>> _fetchMatchingProducts(List<dynamic> items) async {
    List<Widget> matchingWidgets = [];

    for (var item in items) {
      var title = item['title'];

      // Query the Products collection for the matching title
      var productQuery = await _firestore.collection('Products')
          .where('Title', isEqualTo: title)
          .get();

      for (var product in productQuery.docs) {
        var productLevel = product['Level'];
        var productType = product['ProductType'];

        // Check if the product level matches the selected grade
        if (productLevel == selectedGrade) {
          if (productType == 'ProductType.single') {
            // Single product type
            matchingWidgets.add(_buildSingleProductWidget(product));
          } else if (productType == 'ProductType.variable') {
            // Handle variable product type
            var matchedVariation = await _fetchMatchingVariation(item['selectedVariation'], product);
            if (matchedVariation != null) {
              matchingWidgets.add(_buildVariableProductWidget(matchedVariation));
            }
          }
        }
      }
    }
    return matchingWidgets;
  }

  /// Build widget for single product
  Widget _buildSingleProductWidget(DocumentSnapshot product) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(product['Thumbnail'], height: 150, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(product['Title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    // Add logic to download PDF
                  },
                  child: Text('Download PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Fetch matching product variation based on selectedVariation (Chapter, Part)
  Future<Map<String, dynamic>?> _fetchMatchingVariation(Map selectedVariation, DocumentSnapshot product) async {
    var chapter = selectedVariation['Chapter'];
    var part = selectedVariation['Part'];

    // Match Chapter and Part in ProductVariations array
    var variations = List<Map<String, dynamic>>.from(product['ProductVariations']);
    for (var variation in variations) {
      var attributes = variation['AttributeValues'];
      if (attributes['Chapter'] == chapter && attributes['Part'] == part) {
        return variation;
      }
    }
    return null;
  }

  /// Build widget for variable product variation
  Widget _buildVariableProductWidget(Map<String, dynamic> variation) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(variation['Image'], height: 150, width: double.infinity, fit: BoxFit.cover),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(variation['Title'], style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text(variation['SubTitle'], style: TextStyle(fontSize: 14, color: Colors.grey)),
                SizedBox(height: 4),
                ElevatedButton(
                  onPressed: () {
                    // Add logic to download PDF
                  },
                  child: Text('Download PDF'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
