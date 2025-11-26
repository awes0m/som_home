import 'package:flutter/material.dart';
import 'html_viewer_widget.dart';

class JsonMultiCorrelatorTool extends StatelessWidget {
  const JsonMultiCorrelatorTool({super.key});

  @override
  Widget build(BuildContext context) {
    return const HtmlViewerWidget(
      assetPath: 'assets/json_multi_corelator.html',
      title: 'Multi JSON Correlator',
    );
  }
}