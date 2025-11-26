import 'package:flutter/material.dart';
import 'html_viewer_widget.dart';

class ExpenseManagerTool extends StatelessWidget {
  const ExpenseManagerTool({super.key});

  @override
  Widget build(BuildContext context) {
    return const HtmlViewerWidget(
      assetPath: 'assets/expense_manger.html',
      title: 'Expense Manager',
    );
  }
}