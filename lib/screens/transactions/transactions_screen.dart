import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/transaction_provider.dart';

class TransactionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionProvider>(context);

    return Scaffold(
      appBar: AppBar(title: Text("Transactions")),
      body: provider.isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: provider.transactions.length,
              itemBuilder: (context, index) {
                final tx = provider.transactions[index];
                return ListTile(
                  title: Text(tx["description"] ?? "No Description"),
                  subtitle: Text("Amount: ${tx["amount"]}"),
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
