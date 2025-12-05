// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'controllers/app_controller.dart';
// import 'widgets/expense_page.dart';

// void main() {
//   runApp(
//     ChangeNotifierProvider(
//       create: (_) => AppController(),
//       child: const ExpenseApp(),
//     ),
//   );
// }

// class ExpenseApp extends StatelessWidget {
//   const ExpenseApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final controller = context.watch<AppController>();

//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: controller.data.darkTheme ? ThemeData.dark() : ThemeData.light(),
//       home: const ExpensePage(),
//     );
//   }
// }
