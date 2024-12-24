import 'package:kas_manager/constFiles/strings.dart';
import 'package:kas_manager/model/transactionModel.dart';
import 'package:kas_manager/services/databaseHelper.dart';
import 'package:flutter/cupertino.dart';

class TransactionController with ChangeNotifier {
  DatabaseHelper? databaseHelper = DatabaseHelper.instance;

  List<TransactionModel?> transactionList = [];

  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double total = 0.0;

  bool fetching = false;

  TransactionController() {
    if (databaseHelper != null) fetchTransaction();
  }

  void fetchTransaction() async {
    fetching = true;
    transactionList = [];
    totalIncome = 0.0;
    totalExpense = 0.0;
    total = 0.0;

    final dataList = await databaseHelper!.getData(transactionTable);

    transactionList = dataList.map((e) => TransactionModel.fromMap(e)).toList();

    transactionList.forEach((element) {
      if (element!.isIncome == 1) {
        totalIncome += double.parse(element.amount ?? "0.0");
      } else {
        totalExpense += double.parse(element.amount ?? "0.0");
      }
    });

    total = totalIncome - totalExpense;

    fetching = false;

    notifyListeners();
  }

  void insertTransaction(TransactionModel transactionModel) async =>
      await databaseHelper!
          .insertData(transactionTable, transactionModel.transactionToMap())
          .catchError((onError) => print("Insertion On Error: $onError"));

  void updateTransaction(TransactionModel transactionModel) async =>
      await databaseHelper!
          .updateData(transactionTable, transactionModel.transactionToMap(),
              transactionModel.id ?? 0)
          .catchError((onError) => print("Update On Error: $onError"));

  void deleteTransaction(int id) async => await databaseHelper!
      .deleteData(transactionTable, id)
      .catchError((onError) => print("Deletion On Error: $onError"));

  String tileIcon(String departmentName) {
    if (departmentName == membershipDues) return svgPath(memberSvg);
    if (departmentName == donation) return svgPath(donationSvg);
    if (departmentName == activityCosts) return svgPath(activitySvg);
    if (departmentName == operational) return svgPath(operationalSvg);

    return svgPath(othersSvg);
  }
}
