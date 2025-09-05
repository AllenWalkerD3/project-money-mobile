import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

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
    // ✅ fetch data once when the screen loads
    Future.microtask(() =>
        Provider.of<TransactionProvider>(context, listen: false)
            .fetchTransactions(widget.bookId));
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
        onPressed: () {
          provider.addTransaction({
            "description": "Coffee",
            "amount": 50,
            "transaction_type": "expense",
            "user_id": 1
          });
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
