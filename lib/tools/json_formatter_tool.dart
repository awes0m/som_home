import 'package:flutter/material.dart';
import 'html_viewer_widget.dart';

class JsonFormatterTool extends StatelessWidget {
  const JsonFormatterTool({super.key});

  @override
  Widget build(BuildContext context) {
    return const HtmlViewerWidget(
      assetPath: 'assets/smartJsonFormatterAnalyzer.html',
      title: 'Smart JSON Formatter',
    );
  }
}