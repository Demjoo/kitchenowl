import 'dart:convert';
import 'dart:io';

import 'package:kitchenowl/models/transaction.dart';
import 'package:path_provider/path_provider.dart';

class TransactionStorage {
  static TransactionStorage _instance;

  TransactionStorage._internal();
  static TransactionStorage getInstance() {
    if (_instance == null) _instance = TransactionStorage._internal();
    return _instance;
  }

  Future<String> get _localPath async {
    final temp = await getTemporaryDirectory();
    final directory = Directory(temp.path + '/kitchenowl');
    if (!await directory.exists()) directory.create();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/transactions.json');
  }

  Future<List<Transaction>> readTransactions() async {
    try {
      final file = await _localFile;
      final String content = await file.readAsString();
      return List<Transaction>.from(
          json.decode(content).map((e) => Transaction.fromJson(e)));
    } catch (e) {
      return [];
    }
  }

  Future<File> clearTransactions() async {
    try {
      final file = await _localFile;
      if (await file.exists()) return file.delete();
    } catch (e) {}
    return null;
  }

  Future<File> addTransaction(Transaction t) async {
    final transactions = await readTransactions();
    transactions.add(t);
    final file = await _localFile;
    return file.writeAsString(
        json.encode(transactions.map((t) => t.toJson()).toList()));
  }
}