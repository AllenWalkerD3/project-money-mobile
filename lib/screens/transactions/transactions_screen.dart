import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

import '../report_screen.dart';

class TransactionScreen extends StatefulWidget {
  final int bookId;
  final String bookName;

  TransactionScreen({super.key, required this.bookId, required this.bookName});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String? _selectedCategory;

  void _showTransactionDetails(BuildContext context, Map<String, dynamic> tx) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Wrap(
            children: [
              Center(
                child: Container(
                  width: 50,
                  height: 5,
                  margin: EdgeInsets.only(bottom: 15),
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              Text(
                "Transaction Details",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 20),

              _detailRow("Description", tx["description"] ?? "—"),
              _detailRow("Amount", tx["amount"]?.toString() ?? "—"),
              _detailRow("Type", tx["transaction_type"]?.toString().toUpperCase() ?? "—"),
              _detailRow("Category ID", tx["category_id"]?.toString() ?? "—"),
              _detailRow("Currency", tx["currency"] ?? "—"),
              _detailRow("Date", tx["datetime"] ?? "—"),
              _detailRow("Book Name", tx["book"]["book_name"]?.toString() ?? "—"),
              _detailRow("Remark", tx["remark"]?.toString() ?? "—"),
              // _detailRow("User ID", tx["user_id"]?.toString() ?? "—"),

              const SizedBox(height: 20),
              Center(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.close),
                  label: Text("Close"),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w600)),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<TransactionProvider>(
        context,
        listen: false,
      ).fetchTransactions(
        widget.bookId,
        int.tryParse(_selectedCategory ?? "0"),
        _startDate,
        _endDate,
      );
      Provider.of<CategoryProvider>(context, listen: false).fetchCategories();
    });
  }

  void _openAddTransactionForm(BuildContext context) {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    final catProvider = Provider.of<CategoryProvider>(context, listen: false);

    // Fetch categories before showing form
    catProvider.fetchCategories();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        final descController = TextEditingController();
        final amountController = TextEditingController();

        String transactionType = "expense";
        String? selectedCategory;
        String selectedCurrency = "ZAR"; // default

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Consumer<CategoryProvider>(
            builder: (context, catProv, _) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Add Transaction",
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: 16),

                    TextField(
                      controller: descController,
                      decoration: InputDecoration(labelText: "Description"),
                    ),
                    SizedBox(height: 12),

                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: "Amount"),
                    ),
                    SizedBox(height: 12),

                    // Transaction type
                    DropdownButton<String>(
                      value: transactionType,
                      items: ["expense", "income", "transfer"]
                          .map(
                            (type) => DropdownMenuItem(
                              value: type,
                              child: Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) {
                          transactionType = val;
                        }
                      },
                    ),
                    SizedBox(height: 12),

                    // Categories dropdown
                    catProv.isLoading
                        ? CircularProgressIndicator()
                        : DropdownButton<String>(
                            value: selectedCategory,
                            hint: Text("Select Category"),
                            items: catProv.categories.map((cat) {
                              return DropdownMenuItem<String>(
                                value: cat["id"].toString(),
                                child: Text(cat["name"]),
                              );
                            }).toList(),
                            onChanged: (val) {
                              selectedCategory = val;
                            },
                          ),
                    SizedBox(height: 12),

                    // Currency dropdown
                    DropdownButton<String>(
                      value: selectedCurrency,
                      items: ["ZAR", "USD", "EUR", "JPY"]
                          .map(
                            (cur) =>
                                DropdownMenuItem(value: cur, child: Text(cur)),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) selectedCurrency = val;
                      },
                    ),
                    SizedBox(height: 20),

                    ElevatedButton(
                      onPressed: () {
                        txProvider.addTransaction({
                          "description": descController.text,
                          "amount": double.tryParse(amountController.text) ?? 0,
                          "transaction_type": transactionType,
                          "category_id": selectedCategory,
                          "currency": selectedCurrency,
                          "user_id": 1,
                          "book_id": widget.bookId,
                        });
                        Navigator.pop(ctx);
                      },
                      child: Text("Save"),
                    ),
                    SizedBox(height: 20),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _pickDate(BuildContext context, bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  void _applyFilters() {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    txProvider.fetchTransactions(
      widget.bookId,
      _selectedCategory != null ? int.tryParse(_selectedCategory!) : null,
      _startDate,
      _endDate,
    );
  }

  void _removeFilters() {
    final txProvider = Provider.of<TransactionProvider>(context, listen: false);
    _selectedCategory = null;
    _startDate = null;
    _endDate = null;
    txProvider.fetchTransactions(widget.bookId, null, null, null);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);
    final catProvider = Provider.of<CategoryProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Transactions"),
        actions: [
          IconButton(
            icon: Icon(Icons.speaker_notes_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      ReportScreen(userId: 1, bookId: widget.bookId),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 🔹 Filters Section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => _pickDate(context, true),
                        child: Text(
                          _startDate == null
                              ? "Start Date"
                              : _startDate!.toIso8601String().split("T")[0],
                        ),
                      ),
                    ),
                    Expanded(
                      child: TextButton(
                        onPressed: () => _pickDate(context, false),
                        child: Text(
                          _endDate == null
                              ? "End Date"
                              : _endDate!.toIso8601String().split("T")[0],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                catProvider.isLoading
                    ? CircularProgressIndicator()
                    : DropdownButton<String>(
                        value: _selectedCategory,
                        hint: Text("Select Category"),
                        isExpanded: true,
                        items: catProvider.categories.map((cat) {
                          return DropdownMenuItem<String>(
                            value: cat["id"].toString(),
                            child: Text(cat["name"]),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCategory = val;
                          });
                        },
                      ),
                SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: _applyFilters,
                      child: Text("Apply Filters"),
                    ),
                    ElevatedButton(
                      onPressed: _removeFilters,
                      child: Text("Remove Filters"),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 🔹 Transactions List
          Expanded(
            child: provider.isLoading
                ? Center(child: CircularProgressIndicator())
                : provider.transactions.isEmpty
                ? Center(child: Text("No transactions found."))
                : ListView.builder(
                    itemCount: provider.transactions.length,
                    itemBuilder: (context, index) {
                      final tx = provider.transactions[index];
                      return ListTile(
                        title: Text(tx["description"] ?? "No Description"),
                        subtitle: Text(
                          "Amount: ${tx["amount"]} | Type: ${tx["transaction_type"].toString().toUpperCase()}",
                        ),
                        trailing: Text(
                          tx["currency"] ?? "",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        onTap: () => _showTransactionDetails(context, tx),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransactionForm(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
