import 'package:kas_manager/components/recentTransList.dart';
import 'package:kas_manager/components/homeReportContainer.dart';
import 'package:kas_manager/components/userProfileCard.dart';
import 'package:kas_manager/constFiles/colors.dart';
import 'package:kas_manager/controller/transactionController.dart';
import 'package:kas_manager/controller/transDetailController.dart';
import 'package:kas_manager/customWidgets/textButton.dart';
import 'package:kas_manager/view/transactionList.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatelessWidget {
  final String role;

  const HomeScreen({Key? key, required this.role}) : super(key: key); 

  @override
  Widget build(BuildContext context) {
    TransactionController transactionController =
        Provider.of<TransactionController>(context);
    TransDetailController transactionDetailController =
        Provider.of<TransDetailController>(context);

    return transactionController.fetching
        ? Center(child: CircularProgressIndicator())
        : Column(
            children: [
              //userData
              UserProfileCard(),
              //balance container
              HomeReportContainer(transactionController: transactionController),
              //recent transactions title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                      flex: 4,
                      child: Text("Transaksi Terakhir",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold))),
                  Expanded(
                    child: CustomTextButton(
                      press: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  TransactionList(role: role,))),
                      textStyle: TextStyle(
                          color: selectedTextButton,
                          fontWeight: FontWeight.bold),
                      text: 'Lihat Semua',
                    ),
                  )
                ],
              ),
              //transaction List View
              RecentTransList(
                role: role,
                  transController: transactionController,
                  transDetailController: transactionDetailController),
            ],
          );
  }
}
