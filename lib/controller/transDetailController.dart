import 'package:kas_manager/constFiles/strings.dart';
import 'package:kas_manager/services/databaseHelper.dart';
import 'package:flutter/cupertino.dart';
import 'package:kas_manager/utils.dart';

class TransDetailController with ChangeNotifier {
  DatabaseHelper? databaseHelper = DatabaseHelper.instance;

  TextEditingController titleField = TextEditingController();
  TextEditingController amountField = TextEditingController();
  TextEditingController descriptionField = TextEditingController();

  bool isIncomeSelected = false;
  bool savedTransaction = false;

  String selectedDepartment = others;

  int? transactionId;
  String? date;

  bool buttonSelected = true;

  void changeHomeNdReportSection(bool value) {
    buttonSelected = value;
    notifyListeners();
  }

  void changeCategory() {
    isIncomeSelected = !isIncomeSelected;
    notifyListeners();
  }

  void changeDepartment(String name) {
    selectedDepartment = name;
    notifyListeners();
  }

  String titleIcon() {
    if (selectedDepartment == membershipDues) return svgPath(memberSvg);
    if (selectedDepartment == donation) return svgPath(donationSvg);
    if (selectedDepartment == activityCosts) return svgPath(activitySvg);
    if (selectedDepartment == operational) return svgPath(operationalSvg);

    return svgPath(othersSvg);
  }

  void toTransactionDetail({
    required bool isSaved,
    int? id,
    String? title,
    String? description,
    String? amount,
    bool? isIncome,
    String? department,
    String? dateTime,
  }) {
    savedTransaction = isSaved;
    transactionId = id;
    titleField.text = title ?? "";
    descriptionField.text = description ?? "";
    amountField.text = amount ?? "";
    isIncomeSelected = isIncome ?? false;
    selectedDepartment = department ?? others;
    date = dateTime ?? DateTime.now().toString();
    notifyListeners();
  }
}
