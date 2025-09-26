import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'providers/transaction_provider.dart';
import 'providers/account_provider.dart';
import 'providers/category_provider.dart';
import 'providers/book_provider.dart';
import 'providers/report_provider.dart';
import 'screens/main_screen.dart';

// Global navigator key to access context outside widgets
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  await Hive.openBox("categories");    // cache
  await Hive.openBox("pending_ops");   // pending sync
  await Hive.openBox("transactions");  // transactions
  await Hive.openBox("pending_tx");    // pending transactions

  runApp(AccountBookApp());
}

class AccountBookApp extends StatefulWidget {
  @override
  _AccountBookAppState createState() => _AccountBookAppState();
}

class _AccountBookAppState extends State<AccountBookApp> {
  StreamSubscription? subscription;

  @override
  void initState() {
    super.initState();

    // Listen for connectivity changes
    subscription = Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          Provider.of<CategoryProvider>(ctx, listen: false).syncPending();
          Provider.of<TransactionProvider>(ctx, listen: false).syncPending();
        }
      }
    });

    // Optional: sync immediately if online at startup
    Connectivity().checkConnectivity().then((status) {
      if (status != ConnectivityResult.none) {
        final ctx = navigatorKey.currentContext;
        if (ctx != null) {
          Provider.of<CategoryProvider>(ctx, listen: false).syncPending();
          Provider.of<TransactionProvider>(ctx, listen: false).syncPending();
        }
      }
    });
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TransactionProvider()),
        ChangeNotifierProvider(create: (_) => AccountProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey, // Needed to access context outside widget tree
        title: "Account Book",
        theme: ThemeData(primarySwatch: Colors.blue),
        home: MainScreen(),
      ),
    );
  }
}
