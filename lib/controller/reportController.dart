import 'package:kas_manager/constFiles/strings.dart';
import 'package:kas_manager/model/transactionModel.dart';
import 'package:kas_manager/services/databaseHelper.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReportController with ChangeNotifier {
  DatabaseHelper? databaseHelper = DatabaseHelper.instance;
  ReportController() {
    if (databaseHelper != null) fetchTransaction();
  }

  //default report method is income
  String reportMethod = income;

  //menyimpan transaksi
  List<TransactionModel?> transactionList = [];
  List<TransactionModel?> transactionIncomeList = [];
  List<TransactionModel?> transactionExpenseList = [];

  double total = 0.0;
  double totalIncome = 0.0;
  double totalExpense = 0.0;
  double healthIncomeAmount = 0.0;
  double healthExpenseAmount = 0.0;
  double familyIncomeAmount = 0.0;
  double familyExpenseAmount = 0.0;
  double shoppingIncomeAmount = 0.0;
  double shoppingExpenseAmount = 0.0;
  double foodIncomeAmount = 0.0;
  double foodExpenseAmount = 0.0;
  double vehicleIncomeAmount = 0.0;
  double vehicleExpenseAmount = 0.0;
  double salonIncomeAmount = 0.0;
  double salonExpenseAmount = 0.0;
  double deviceIncomeAmount = 0.0;
  double deviceExpenseAmount = 0.0;
  double officeIncomeAmount = 0.0;
  double officeExpenseAmount = 0.0;
  double othersIncomeAmount = 0.0;
  double othersExpenseAmount = 0.0;

  //select report method is all, income or expense
  void cartButton(String value) {
    reportMethod = value;
    notifyListeners(); // memungkinkan UI untuk diberii notifikasi
  }

  void fetchTransaction(
      {DateTime? customFromDate, DateTime? customToDate}) async {
    print('custom date' + customFromDate.toString());
    DateTime fromDate = customFromDate ?? DateTime.now();
    DateTime toDate = customToDate ?? DateTime.now();

    transactionList = [];

    String fromDayPattern = 'd';
    String fromMonthPattern = 'M';

    String toDayPattern = 'd';
    String toMonthPattern = 'M';

    //date formatting
    //if date is less than 10, then add 0
    if (fromDate.day < 10) fromDayPattern = '0d';
    if (fromDate.month < 10) fromMonthPattern = '0M';
    if (toDate.day < 10) fromDayPattern = '0d';
    if (toDate.month < 10) fromMonthPattern = '0M';

    //formatted date string
    String fromDateFormat = "y-$fromMonthPattern-$fromDayPattern";
    String toDateFormat = "y-$toMonthPattern-$toDayPattern";

    var dataList = [];

    if (customFromDate == null && customToDate == null) {
      print('data semua');
      dataList = await databaseHelper!.getDataNon(transactionTable);
    } else {
      dataList = await databaseHelper!.getDateRangeData(
          transactionTable,
          DateFormat(fromDateFormat).format(fromDate),
          DateFormat(toDateFormat).format(toDate));
    }

    //get data from database

    dataList.forEach(
      (element) => print(element),
    );

    //converting to transactionModel
    transactionList = dataList.map((e) => TransactionModel.fromMap(e)).toList();

    //separating income and expense data
    transactionIncomeList =
        transactionList.where((element) => element!.isIncome == 1).toList();
    transactionExpenseList =
        transactionList.where((element) => element!.isIncome == 0).toList();

    //calculate total amount of income and expense
    totalIncome = transactionIncomeList.fold(
        0,
        (previousValue, element) =>
            previousValue + double.parse(element!.amount ?? "0.0"));

    totalExpense = transactionExpenseList.fold(
        0,
        (previousValue, element) =>
            previousValue + double.parse(element!.amount ?? "0.0"));

    //calculate balance amount
    total = totalIncome - totalExpense;

    //get each category income and expense amount
    healthIncomeAmount = amountCalc(transactionIncomeList, membershipDues);
    healthExpenseAmount = amountCalc(transactionExpenseList, membershipDues);
    familyIncomeAmount = amountCalc(transactionIncomeList, donation);
    familyExpenseAmount = amountCalc(transactionExpenseList, donation);
    shoppingIncomeAmount = amountCalc(transactionIncomeList, activityCosts);
    shoppingExpenseAmount = amountCalc(transactionExpenseList, activityCosts);
    foodIncomeAmount = amountCalc(transactionIncomeList, operational);
    foodExpenseAmount = amountCalc(transactionExpenseList, operational);
    othersIncomeAmount = amountCalc(transactionIncomeList, others);
    othersExpenseAmount = amountCalc(transactionExpenseList, others);

    notifyListeners();
  }

  double amountCalc(
          List<TransactionModel?> transactionIncomeList, String department) =>
      transactionIncomeList
          .where((element) => element!.category == department)
          .fold(
              0,
              (previousValue, element) =>
                  previousValue + double.parse(element!.amount ?? "0.0"));
}
