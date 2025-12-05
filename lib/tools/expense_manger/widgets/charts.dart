import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/app_controller.dart';

class ChartsSection extends StatelessWidget {
  const ChartsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Monthly Trend", style: TextStyle(fontSize: 18)),
        SizedBox(
          height: 200,
          width: screenWidth - 32,
          child: const _MonthlyChart(),
        ),

        const SizedBox(height: 20),

        const Text("Income vs Expense", style: TextStyle(fontSize: 18)),
        SizedBox(
          height: 200,
          width: screenWidth - 32,
          child: const _IncomeExpenseChart(),
        ),
      ],
    );
  }
}

class _MonthlyChart extends StatelessWidget {
  const _MonthlyChart();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();

    final data = c.data.expenses;

    final monthly = <String, double>{};

    for (var e in data) {
      final key = e.date.substring(0, 7);
      monthly[key] = (monthly[key] ?? 0) +
          (e.type == "income" ? e.amount : -e.amount);
    }

    final keys = monthly.keys.toList();

    return LineChart(
      LineChartData(
        titlesData: const FlTitlesData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (int i = 0; i < keys.length; i++)
                FlSpot(i.toDouble(), monthly[keys[i]]!)
            ],
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
          ),
        ],
      ),
    );
  }
}

class _IncomeExpenseChart extends StatelessWidget {
  const _IncomeExpenseChart();

  @override
  Widget build(BuildContext context) {
    final c = context.watch<AppController>();

    final income = c.totalIncome;
    final expense = c.totalExpense;

    return BarChart(
      BarChartData(
        barGroups: [
          BarChartGroupData(x: 0, barRods: [
            BarChartRodData(toY: income, color: Colors.green),
          ]),
          BarChartGroupData(x: 1, barRods: [
            BarChartRodData(toY: expense, color: Colors.red),
          ]),
        ],
      ),
    );
  }
}
