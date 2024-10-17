import 'dart:ui_web';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:html' as html; // Dart HTML package for web
import 'package:flutter_web_plugins/flutter_web_plugins.dart'; // For web plugins

class ViewMaterial extends StatelessWidget {
  final String pdfUrl; // The PDF URL to embed

  ViewMaterial({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      // If the platform is web, use iframe for PDF display
      String viewId = 'pdf-iframe-${pdfUrl.hashCode}';

      // Register the view factory for the iframe
      platformViewRegistry.registerViewFactory(
        viewId,
            (int viewId) => html.IFrameElement()
          ..src = pdfUrl
          ..style.border = 'none'
          ..width = '100%'
          ..height = '100%',
      );

      return Scaffold(
        appBar: AppBar(
          title: Text('View Material'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: HtmlElementView(viewType: viewId), // Embed iframe using HtmlElementView
        ),
      );
    } else {
      // If the platform is not web, show an unsupported message or alternative logic
      return Scaffold(
        appBar: AppBar(
          title: Text('View Material'),
          backgroundColor: Colors.teal,
        ),
        body: Center(
          child: Text('PDF viewing is only supported on web for now.'),
        ),
      );
    }
  }
}
