import 'package:flutter/material.dart';
import 'html_viewer_widget.dart';

class JsonAnalyzerTool extends StatelessWidget {
  const JsonAnalyzerTool({super.key});

  @override
  Widget build(BuildContext context) {
    return const HtmlViewerWidget(
      assetPath: 'assets/jsonCorelatorAnalyzer.html',
      title: 'JSON Analyzer HQ',
    );
  }
}