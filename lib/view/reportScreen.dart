import 'package:kas_manager/components/categorySelectHeader.dart';
import 'package:kas_manager/constFiles/colors.dart';
import 'package:kas_manager/constFiles/strings.dart';
import 'package:kas_manager/controller/reportController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:kas_manager/utils.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

class ReportScreen extends StatelessWidget {
  const ReportScreen({Key? key}) : super(key: key);
  static ReportController? reportController;

  @override
  Widget build(BuildContext context) {
    reportController = Provider.of<ReportController>(context);

    return Column(
      children: [
        //category selector
        CategorySelectHeader(),

        //pie chart, if not full report
        if (reportController!.reportMethod != fullReport)
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20),
            child: PieChart(
              dataMap: {
                membershipDues: chartValue(reportController!.healthIncomeAmount,
                    reportController!.healthExpenseAmount),
                donation: chartValue(reportController!.familyIncomeAmount,
                    reportController!.familyExpenseAmount),
                activityCosts: chartValue(
                    reportController!.shoppingIncomeAmount,
                    reportController!.shoppingExpenseAmount),
                operational: chartValue(reportController!.foodIncomeAmount,
                    reportController!.foodExpenseAmount),
                others: chartValue(reportController!.othersIncomeAmount,
                    reportController!.othersExpenseAmount),
              },
              animationDuration: Duration(seconds: 1),
              ringStrokeWidth: 40,
              chartType: ChartType.ring,
              legendOptions: LegendOptions(showLegends: true),
              chartValuesOptions: ChartValuesOptions(
                showChartValueBackground: true,
                showChartValues: true,
                showChartValuesInPercentage: true,
                showChartValuesOutside: true,
              ),
            ),
          ),

        //balance container, if full report
        if (reportController!.reportMethod == fullReport)
          Container(
            decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.85),
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            padding: EdgeInsets.all(10.0),
            width: double.infinity,
            child: Column(
              children: [
                Text("Balance: ${reportController!.total.toStringAsFixed(1)}",
                    style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                        color: whiteColor)),
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                          "Income:\n${formarCurrency(reportController!.totalIncome)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20.0, color: whiteColor)),
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                          "Expense:\n${formarCurrency(reportController!.totalExpense)}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 20.0, color: whiteColor)),
                    ),
                  ],
                ),
              ],
            ),
          ),

        //category list
        Expanded(
          child: ListView(
            physics: BouncingScrollPhysics(),
            children: [
              tile(
                title: "Iuran Anggota",
                svgName: memberSvg,
                incomeAmount: reportController!.healthIncomeAmount,
                expenseAmount: reportController!.healthExpenseAmount,
              ),
              tile(
                title: "Donasi",
                svgName: donationSvg,
                incomeAmount: reportController!.familyIncomeAmount,
                expenseAmount: reportController!.familyExpenseAmount,
              ),
              tile(
                title: "Biaya Kegiatan",
                svgName: activitySvg,
                incomeAmount: reportController!.shoppingIncomeAmount,
                expenseAmount: reportController!.shoppingExpenseAmount,
              ),
              tile(
                title: "Operasional",
                svgName: operationalSvg,
                incomeAmount: reportController!.foodIncomeAmount,
                expenseAmount: reportController!.foodExpenseAmount,
              ),
              tile(
                title: "Others",
                svgName: othersSvg,
                incomeAmount: reportController!.othersIncomeAmount,
                expenseAmount: reportController!.othersExpenseAmount,
              ),
            ],
          ),
        ),
      ],
    );
  }

  ListTile tile({
    required String title,
    required String svgName,
    required double incomeAmount,
    required double expenseAmount,
  }) {
    double percentage = 0;
    String trailingAmount = "0.0";
    if (reportController!.reportMethod == income) {
      percentage = incomeAmount / reportController!.totalIncome * 100;
      if (incomeAmount != 0)
        trailingAmount = "+${incomeAmount.toStringAsFixed(1)}";
    }

    if (reportController!.reportMethod == expense) {
      percentage = expenseAmount / reportController!.totalExpense * 100;
      if (expenseAmount != 0)
        trailingAmount = "-${expenseAmount.toStringAsFixed(1)}";
    }

    if (reportController!.reportMethod == fullReport) {
      trailingAmount = (incomeAmount - expenseAmount).toStringAsFixed(1);
    }

    return ListTile(
      title: Text(title),
      contentPadding: EdgeInsets.all(10.0),
      leading: Container(
        height: 50.0,
        width: 50.0,
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
            color: whiteColor,
            boxShadow: [BoxShadow(color: blackColor)],
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: SvgPicture.asset(
          svgPath(svgName),
          height: 35.0,
          color: svgColor,
        ),
      ),
      subtitle: reportController!.reportMethod == fullReport
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("$income: ${formarCurrency(incomeAmount)}",
                    style: TextStyle(color: incomeGreen)),
                Text("$expense: ${formarCurrency(expenseAmount)}",
                    style: TextStyle(color: expenseRed)),
              ],
            )
          : Text(
              "Percentage : ${percentage > 0 ? percentage.toStringAsFixed(1) : 0}%"),
      trailing: Text(formarCurrency(double.parse(trailingAmount)),
          style: TextStyle(
              fontWeight: FontWeight.bold,
              color: reportController!.reportMethod == income
                  ? incomeGreen
                  : reportController!.reportMethod == expense
                      ? expenseRed
                      : blackColor)),
    );
  }

  double chartValue(double incomeAmount, double expenseAmount) {
    if (reportController!.reportMethod == income) return incomeAmount;
    if (reportController!.reportMethod == expense) return expenseAmount;
    return incomeAmount - expenseAmount;
  }
}
