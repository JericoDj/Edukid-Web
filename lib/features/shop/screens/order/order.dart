import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:webedukid/features/shop/screens/order/my_materials.dart';
import 'package:webedukid/features/shop/screens/order/view_material.dart';
import 'common_widgets.dart'; // Import shared code
import '../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class OrderScreen extends StatefulWidget {
  final bool isInteractive;


  const OrderScreen({Key? key, required this.isInteractive}) : super(key: key);

  @override
  _OrderScreenState createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String selectedGrade = '';
  String? selectedPdfUrl;
  bool showDefaultPage = true;
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
      body: showDefaultPage
          ? MyMaterialsPage(isInteractive:  widget.isInteractive)
          : (selectedPdfUrl != null
          ? ViewMaterial(
        pdfUrl: selectedPdfUrl!,
        onClose: _closePdfView,
        isInteractive: widget.isInteractive,
      )
          : _buildOrderList()),
    );
  }

  Widget _buildGradeBox(BuildContext context, String gradeName) {
    final bool isSelected = selectedGrade == gradeName;

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected && selectedPdfUrl != null) {
            selectedPdfUrl = null;
          } else if (!isSelected) {
            selectedGrade = gradeName;
            selectedPdfUrl = null;
          }
          showDefaultPage = false;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: MyColors.primaryColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: isSelected ? Colors.yellow : MyColors.white, width: 1.5),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
        child: Center(
          child: Text(
            gradeName,
            style: TextStyle(
              color: isSelected ? Colors.yellow : MyColors.white,
              fontSize: 14.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOrderList() {
    return FutureBuilder<QuerySnapshot>(
        future: _firestore.collection('Users').doc(_auth.currentUser?.uid).collection('Orders').get(),      builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No orders found'));
      }

      final orders = snapshot.data!.docs;

      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemCount: orders.length,
          itemBuilder: (context, index) {
            var order = orders[index];
            var items = List.from(order['items']);
            return FutureBuilder(
              future: _fetchMatchingProducts(items),
              builder: (context, AsyncSnapshot<List<Widget>> productSnapshot) {
                if (productSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (!productSnapshot.hasData || productSnapshot.data!.isEmpty) {
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
            matchingWidgets.add(buildSingleProductWidget(product, (pdfUrl) {
              setState(() {
                selectedPdfUrl = pdfUrl;
              });
            }));
          } else if (productType == 'ProductType.variable') {
            var matchedVariation = await _fetchMatchingVariation(
                item['selectedVariation'], product);
            if (matchedVariation != null) {
              matchingWidgets.add(buildVariableProductWidget(matchedVariation, (pdfUrl) {
                setState(() {
                  selectedPdfUrl = pdfUrl;
                });
              }));
            }
          }
        }
      }
    }
    return matchingWidgets;
  }

  Future<Map<String, dynamic>?> _fetchMatchingVariation(
      Map selectedVariation, DocumentSnapshot product) async {
    var chapter = selectedVariation['Chapter'];
    var part = selectedVariation['Part'];

    var variations = List<Map<String, dynamic>>.from(product['ProductVariations']);
    for (var variation in variations) {
      var attributes = variation['AttributeValues'];
      if (attributes['Chapter'] == chapter && attributes['Part'] == part) {
        return variation;
      }
    }
    return null;
  }

  void _closePdfView() {
    setState(() {
      selectedPdfUrl = null;
    });
  }
}


