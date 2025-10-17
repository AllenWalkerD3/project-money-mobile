import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/book_provider.dart';
import 'transactions/transactions_screen.dart';
import 'transactions/category_screen.dart';

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch books when screen loads
    Future.microtask(
      () => Provider.of<BookProvider>(context, listen: false).fetchBooks(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bookProvider = Provider.of<BookProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Account Books"),
        actions: [
          IconButton(
            icon: Icon(Icons.category),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => CategoryScreen()),
              );
            },
          ),
        ],
      ),
      body: bookProvider.isLoading
          ? Center(child: CircularProgressIndicator())
          : bookProvider.books.isEmpty
          ? Center(child: Text("No account books found"))
          : ListView.builder(
              itemCount: bookProvider.books.length,
              itemBuilder: (context, index) {
                final book = bookProvider.books[index];
                return ListTile(
                  title: Text(book["book_name"] ?? "Unnamed"),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TransactionScreen(bookId: book["id"], bookName: book["book_name"]),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}
