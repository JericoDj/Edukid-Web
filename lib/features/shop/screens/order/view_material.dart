import 'dart:html' as html;
import 'package:flutter/material.dart';
import 'dart:ui_web' as ui; // Import platformViewRegistry from dart:ui_web

class ViewMaterial extends StatefulWidget {
  final String pdfUrl;
  final VoidCallback onClose;
  final bool isInteractive;

  ViewMaterial({
    Key? key,
    required this.pdfUrl,
    required this.onClose,
    required this.isInteractive
  }) : super(key: key);

  @override
  _ViewMaterialState createState() => _ViewMaterialState();
}

class _ViewMaterialState extends State<ViewMaterial> {
  late bool isInteractive;
  String? viewId;

  @override
  void initState() {
    super.initState();
    isInteractive = widget.isInteractive;
    _registerIframe();
  }

  @override
  void didUpdateWidget(covariant ViewMaterial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isInteractive != widget.isInteractive || oldWidget.pdfUrl != widget.pdfUrl) {
      setState(() {
        isInteractive = widget.isInteractive;
        _registerIframe();  // Re-register the iframe with the updated size or new URL
      });
    }
  }

  void _registerIframe() {
    viewId = 'pdf-iframe-${DateTime.now().millisecondsSinceEpoch}';  // Use unique ID to ensure it refreshes
    ui.platformViewRegistry.registerViewFactory(
      viewId!,
          (int viewId) => html.IFrameElement()
        ..src = widget.pdfUrl
        ..style.border = 'none'
        ..style.height = isInteractive ? '100%' : '600px'  // Dynamically adjust height
        ..style.width = isInteractive ? '100%' : '23%',    // Dynamically adjust width
    );
  }

  @override
  void dispose() {
    // Perform clean-up when navigating away
    viewId = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              ignoring: !isInteractive,
              child: viewId != null ? HtmlElementView(viewType: viewId!) : Container(), // Ensure the iframe is registered
            ),
          ),
        ],
      ),
    );
  }
}
