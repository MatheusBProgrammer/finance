import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:financas/components/chart.dart';
import 'package:financas/components/transaction_list.dart';
import 'package:flutter/material.dart';
import 'package:financas/components/transaction_form.dart';
import 'dart:convert';
import 'models/transaction.dart';
import 'package:flutter/foundation.dart';
import 'dart:io' show Platform;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData tema = ThemeData();
    return MaterialApp(
      home: const HomePage(),
      theme: tema.copyWith(
        //Theme.of(context).prymaryColor <-- para usar as cores padrão em Widgets filhos
        colorScheme: tema.colorScheme.copyWith(
          primary: Colors.purple,
          secondary: Colors.purple,
        ),
        textTheme: tema.textTheme.copyWith(
          titleLarge: const TextStyle(
            fontFamily: 'Quicksand', // Alterado para Quicksand
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        appBarTheme: const AppBarTheme(
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontFamily: 'Quicksand', // Alterado para Quicksand
            fontSize: 24,
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showChart = false;
  late SharedPreferences _prefs;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Future.wait([_initPrefs()]).then((_) {
      setState(() {
        _isLoading = false;
      });
    });
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTransactions();
  }

  List<Transaction> _transactions = [
    // Transaction(
    //     id: '1',
    //     title: 'title',
    //     value: 100,
    //     date: DateTime.now().subtract(Duration(days: 3))),
  ];

  void _saveTransactions() {
    final List<String> transactions = _transactions
        .map((transaction) => jsonEncode(transaction.toMap()))
        .toList();
    _prefs.setStringList('transactions', transactions.cast<String>());
  }

  void _loadTransactions() {
    final List<String>? transactions = _prefs.getStringList('transactions');
    if (transactions != null) {
      setState(() {
        _transactions = transactions
            .map((transaction) => Transaction.fromJson(transaction))
            .toList();
      });
    }
  }

  List<Transaction> get _recentTransactions {
    return _transactions.where((transac) {
      //obeter a data atual, subtrair 7 dias. para verificar se o dia se encontra no recorte semanal
      return transac.date.isAfter(DateTime.now().subtract(Duration(days: 7)));
    }).toList();
  }

  _addTransaction(String title, double value, DateTime date) {
    final newTransaction = Transaction(
      id: Random().nextDouble().toString(),
      title: title,
      value: value,
      date: date,
    );
    setState(() {
      _transactions.add(newTransaction);
    });
    _saveTransactions(); // Salva as transações no SharedPreferences
    Navigator.of(context).pop();
  }

  _openTransactionFormModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return TransactionForm(
          onSubmit: _addTransaction,
        );
      },
    );
  }

  _deleteTransaction(String id) {
    setState(() {
      _transactions.removeWhere((element) {
        return element.id == id;
      });
    });
    _saveTransactions(); // Salva as transações no SharedPreferences
  }

  @override
  Widget build(BuildContext context) {

    final IconList = Platform.isIOS ? CupertinoIcons.refresh : Icons.list;
    final chartList = Platform.isIOS ? CupertinoIcons.refresh: Icons.show_chart;

    bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final appBar = AppBar(
      centerTitle: true,
      backgroundColor: Colors.purple,
      title: const Text(
        'Despesas Pessoais',
        style: TextStyle(fontFamily: 'Quicksands'),
      ),
      actions: [
        if (isLandscape)
          IconButton(
              onPressed: () {
                setState(() {
                  _showChart = !_showChart;
                });
              },
              icon: Icon(_showChart ? IconList : chartList)),
        IconButton(
            onPressed: () => _openTransactionFormModal(context),
            icon: const Icon(Icons.add)),
      ],
    );
    final mobileHeight =
        MediaQuery.of(context).size.height - appBar.preferredSize.height;

    final bodyPage = SafeArea(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
              if (_showChart || !isLandscape)
                SizedBox(
                    height: mobileHeight * (isLandscape ? 0.75 : 0.25),
                    child: Chart(_recentTransactions),),
            if (!_showChart || !isLandscape)
              SizedBox(
                  height: mobileHeight * (isLandscape ? 1 : 0.7),
                  child: TransactionList(
                      transactions: _transactions, delete: _deleteTransaction)),
            /*
            *             if (_showChart || !isLandscape)
              SizedBox(
                height: availableHeight * (isLandscape ? 0.8 : 0.3),
                child: Chart(_recentTransactions),
              ),
            if (!_showChart || !isLandscape)
              SizedBox(
                height: availableHeight * (isLandscape ? 1 : 0.7),*/
          ],
        ),
      ),
    );

    return _isLoading
        ? const CircularProgressIndicator()
        : Platform.isIOS
            ? CupertinoPageScaffold(child: bodyPage)
            : Scaffold(
                appBar: appBar,
                body: bodyPage,
                floatingActionButton: Platform.isIOS
                    ? Container()
                    : Padding(
                        padding: const EdgeInsets.all(5),
                        child: FloatingActionButton(
                          backgroundColor: Colors.purple,
                          onPressed: () => _openTransactionFormModal(context),
                          child: const Icon(
                            Icons.add,
                            size: 42,
                          ),
                        ),
                      ),
                floatingActionButtonLocation:
                    FloatingActionButtonLocation.centerDocked,
              );
  }
}
