// screens/report_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/report_provider.dart';

class ReportScreen extends StatefulWidget {
  final int userId;
  final int bookId;
  const ReportScreen({super.key, required this.userId, required this.bookId});

  @override
  _ReportScreenState createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  DateTimeRange? _dateRange;
  int? _selectedAccountType;

  @override
  void initState() {
    super.initState();
    Provider.of<ReportProvider>(context, listen: false).fetchAccountTypes();
  }

  void _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dateRange = picked;
      });
    }
  }

  void _loadReports() {
    if (_dateRange == null || _selectedAccountType == null) return;

    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    // Load spending by account type
    reportProvider.fetchSpendingByAccountType(
      accountTypeId: _selectedAccountType!,
      startDate: _dateRange!.start.toIso8601String(),
      endDate: _dateRange!.end.toIso8601String(),
    );

    // Load spending by category
    reportProvider.fetchSpendingByCategory(
      userId: widget.userId,
      bookId: widget.bookId,
      transactionType: "expense", // could make this selectable later
      accountTypeId: _selectedAccountType!,
      startDate: _dateRange!.start.toIso8601String(),
      endDate: _dateRange!.end.toIso8601String(),
    );
  }

  // 🔹 Helper: Convert HEX to Color
  Color _hexToColor(String hex) {
    hex = hex.replaceAll("#", "");
    if (hex.length == 6) hex = "FF$hex"; // add alpha if missing
    return Color(int.parse(hex, radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = Provider.of<ReportProvider>(context);

    // Calculate total for pie chart
    double total = reportProvider.spendingByCategory.fold(
      0.0,
      (sum, item) => sum + (item["total"] as double),
    );

    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: Column(
        children: [
          // 🔹 Filters
          Row(
            children: [
              ElevatedButton(
                onPressed: _pickDateRange,
                child: Text(_dateRange == null
                    ? "Select Date Range"
                    : "${_dateRange!.start.toLocal().toString().split(' ')[0]} - ${_dateRange!.end.toLocal().toString().split(' ')[0]}"),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButton<int>(
                  isExpanded: true,
                  hint: const Text("Select Account Type"),
                  value: _selectedAccountType,
                  items: reportProvider.accountTypes
                      .map<DropdownMenuItem<int>>((type) {
                    return DropdownMenuItem<int>(
                      value: type["id"],
                      child: Text(type["name"]),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedAccountType = value;
                    });
                  },
                ),
              ),
            ],
          ),

          ElevatedButton(
            onPressed: _loadReports,
            child: const Text("Load Reports"),
          ),

          const Divider(),

          // 🔹 Spending by Account Type
          if (_selectedAccountType != null &&
              reportProvider.spendingByAccountType
                  .containsKey(_selectedAccountType))
            ListTile(
              title: Text("Total spent (Account Type: $_selectedAccountType)"),
              trailing: Text(
                reportProvider.spendingByAccountType[_selectedAccountType!]
                        ?.toStringAsFixed(2) ??
                    "0.00",
              ),
            ),

          const Divider(),

          // 🔹 Pie Chart above list
          if (reportProvider.spendingByCategory.isNotEmpty)
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: reportProvider.spendingByCategory.map((item) {
                    final percentage = total == 0
                        ? 0
                        : (item["total"] as double) / total * 100;
                    return PieChartSectionData(
                      color: _hexToColor(item["color"]),
                      value: item["total"],
                      title: "${percentage.toStringAsFixed(1)}%",
                      radius: 80,
                      titleStyle: const TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

          const SizedBox(height: 10),
          const Divider(),


          // 🔹 Spending by Category List
          Expanded(
            child: ListView.builder(
              itemCount: reportProvider.spendingByCategory.length,
              itemBuilder: (context, index) {
                final item = reportProvider.spendingByCategory[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _hexToColor(item["color"]),
                  ),
                  title: Text(item["category"]),
                  trailing: Text(item["total"].toStringAsFixed(2)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
