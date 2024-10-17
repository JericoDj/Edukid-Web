import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';
import 'view_material.dart';

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
        backgroundColor: MyColors.primaryColor,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'My Worksheets',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 20),
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
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: FutureBuilder<QuerySnapshot>(
                future: _firestore
                    .collection('Users')
                    .doc(_auth.currentUser?.uid)
                    .collection('Orders')
                    .get(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text('No orders found'));
                  }

                  final orders = snapshot.data!.docs;

                  return Container(
                    width: 800,
                    child: GridView.builder(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      shrinkWrap: true,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        mainAxisExtent: 400,
                        crossAxisCount: 3,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 50,
                        childAspectRatio: 1,
                      ),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        var order = orders[index];
                        var items = List.from(order['items']);
                        return FutureBuilder(
                          future: _fetchMatchingProducts(items),
                          builder: (context,
                              AsyncSnapshot<List<Widget>> productSnapshot) {
                            if (productSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }
                            if (!productSnapshot.hasData ||
                                productSnapshot.data!.isEmpty) {
                              return const SizedBox.shrink();
                            }

                            return Column(
                              children: productSnapshot.data!,
                            );
                          },
                        );
                      },
                    ),
                  );
                },
              ),
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
          color: isSelected
              ? Theme.of(context).primaryColor.withOpacity(0.2)
              : MyColors.white,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : MyColors.primaryColor.withOpacity(0.8),
            width: 2.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 10.0),
        child: Text(
          gradeName,
          style: TextStyle(
            color: isSelected
                ? MyColors.primaryColor
                : MyColors.primaryColor.withOpacity(0.8),
            fontSize: 10.0,
          ),
        ),
      ),
    );
  }

  Future<List<Widget>> _fetchMatchingProducts(List<dynamic> items) async {
    List<Widget> matchingWidgets = [];

    for (var item in items) {
      var title = item['title'];

      var productQuery = await _firestore
          .collection('Products')
          .where('Title', isEqualTo: title)
          .get();

      for (var product in productQuery.docs) {
        var productLevel = product['Level'];
        var productType = product['ProductType'];

        if (productLevel == selectedGrade) {
          if (productType == 'ProductType.single') {
            matchingWidgets.add(_buildSingleProductWidget(product));
          } else if (productType == 'ProductType.variable') {
            var matchedVariation = await _fetchMatchingVariation(
                item['selectedVariation'], product);
            if (matchedVariation != null) {
              matchingWidgets
                  .add(_buildVariableProductWidget(matchedVariation));
            }
          }
        }
      }
    }
    return matchingWidgets;
  }

  /// Widget for Single Product Type
  Widget _buildSingleProductWidget(DocumentSnapshot product) {
    String pdfUrl = product['PDF'] ?? ''; // PDF location for single products

    return Container(
      height: 400,
      width: 200,
      color: Colors.amber.withOpacity(0.3),
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Image.network(
                product['Thumbnail'],
                fit: BoxFit.contain,
                width: double.infinity,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['Title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),

                  /// View PDF button
                  ElevatedButton(
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        Get.to(() => ViewMaterial(pdfUrl: pdfUrl));
                      } else {
                        Get.snackbar('Error', 'PDF not found');
                      }
                    },
                    child: Text('View PDF'),
                  ),

                  /// Download PDF button
                  ElevatedButton(
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        _downloadPdf(pdfUrl, product['Title']);
                      } else {
                        Get.snackbar('Error', 'PDF not found');
                      }
                    },
                    child: Text('Download PDF'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget for Variable Product Type
  Future<Map<String, dynamic>?> _fetchMatchingVariation(
      Map selectedVariation, DocumentSnapshot product) async {
    var chapter = selectedVariation['Chapter'];
    var part = selectedVariation['Part'];

    var variations =
    List<Map<String, dynamic>>.from(product['ProductVariations']);
    for (var variation in variations) {
      var attributes = variation['AttributeValues'];
      if (attributes['Chapter'] == chapter && attributes['Part'] == part) {
        return variation;
      }
    }
    return null;
  }

  /// Widget for Variable Product
  Widget _buildVariableProductWidget(Map<String, dynamic> variation) {
    String pdfUrl =
        variation['PDF'] ?? ''; // PDF location for variable products

    return Container(
      height: 400,
      width: 200,
      child: Card(
        elevation: 5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(8)),
                child: Image.network(
                  variation['Image'],
                  fit: BoxFit.fill,
                  width: double.infinity,
                  height: 200,
                  alignment: Alignment.center,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    variation['Title'],
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    variation['SubTitle'],
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),

                  /// View PDF button
                  ElevatedButton(
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        Get.to(() => ViewMaterial(pdfUrl: pdfUrl));
                      } else {
                        Get.snackbar('Error', 'PDF not found');
                      }
                    },
                    child: Text('View PDF'),
                  ),

                  /// Download PDF button
                  ElevatedButton(
                    onPressed: () {
                      if (pdfUrl.isNotEmpty) {
                        _downloadPdf(
                            pdfUrl, variation['Title'], variation['SubTitle']);
                      } else {
                        Get.snackbar('Error', 'PDF not found');
                      }
                    },
                    child: Text('Download PDF'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Function to download PDF using XHR (for web)
  void _downloadPdf(String pdfUrl, String title, [String? subtitle]) {
    // Construct the file name using the title and optional subtitle
    String fileName = subtitle != null && subtitle.isNotEmpty
        ? '$title-$subtitle.pdf'
        : '$title.pdf';

    final xhr = html.HttpRequest();
    xhr.responseType = "blob"; // Get the file as a blob
    xhr.open("GET", pdfUrl);
    xhr.onLoad.listen((event) {
      final blob = xhr.response;
      final anchorElement = html.AnchorElement(
          href: html.Url.createObjectUrlFromBlob(blob))
        ..setAttribute('download', fileName) // Use the dynamic file name
        ..click();
      html.Url.revokeObjectUrl(anchorElement.href!); // Clean up after download
    });
    xhr.send();
  }
}
