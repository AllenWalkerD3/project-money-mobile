import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/category_provider.dart';

class TransactionScreen extends StatefulWidget {
  final int bookId;

  TransactionScreen({super.key, required this.bookId});

  @override
  _TransactionScreenState createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransactions(widget.bookId));
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
                  Text("Add Transaction",
                      style: Theme.of(context).textTheme.titleLarge),
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
                        .map((type) =>
                            DropdownMenuItem(value: type, child: Text(type)))
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
                        .map((cur) => DropdownMenuItem(
                              value: cur,
                              child: Text(cur),
                            ))
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


  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Transactions")),
      body: provider.isLoading
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
                        "Amount: ${tx["amount"]}, Type: ${tx["transaction_type"]}, Date: ${tx["datetime"]}",
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddTransactionForm(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
