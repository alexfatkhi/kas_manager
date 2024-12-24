import 'package:kas_manager/constFiles/colors.dart';
import 'package:kas_manager/controller/transDetailController.dart';
import 'package:kas_manager/customWidgets/textButton.dart';
import 'package:kas_manager/services/save_user_sessions.dart';
import 'package:kas_manager/view/transactionDetail.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'homeScreen.dart';
import 'reportScreen.dart';

class Home extends StatefulWidget {
  Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? role = "";
  Future<void> _showUserRole() async {
    role = await getUserRole();
    setState(() {});
    print('Role pengguna: $role');
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showUserRole();
  }

  @override
  Widget build(BuildContext context) {
    //read does not rebuild when changes
    //HomeController providerRead = Provider.of<HomeController>(context);
    //write rebuild when changes
    //HomeController providerWatch = Provider.of<HomeController>(context);

    TransDetailController transDetailController =
        Provider.of<TransDetailController>(context);

    return Scaffold(
      backgroundColor: whiteColor,
      bottomNavigationBar: BottomAppBar(
        shape: CircularNotchedRectangle(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              CustomTextButton(
                text: "Home",
                textColor: transDetailController.buttonSelected
                    ? selectedTextButton
                    : nonSelectedTextButton,
                splash: false,
                press: () {
                  if (!transDetailController.buttonSelected)
                    transDetailController.changeHomeNdReportSection(true);
                },
              ),
              SizedBox(width: 10.0),
              CustomTextButton(
                text: "Report",
                textColor: transDetailController.buttonSelected
                    ? nonSelectedTextButton
                    : selectedTextButton,
                splash: false,
                press: () {
                  if (transDetailController.buttonSelected)
                    transDetailController.changeHomeNdReportSection(false);
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: (role == 'bendahara')
          ? FloatingActionButton(
              backgroundColor: primaryColor,
              child: Icon(Icons.add , color: Colors.white,),
              onPressed: () {
                transDetailController.toTransactionDetail(isSaved: false);
                print('sini');
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (BuildContext context) => TransactionDetail(
                              role: role.toString(),
                            )));
              },
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
          child: transDetailController.buttonSelected
              ? HomeScreen(
                  role: role.toString(),
                )
              : ReportScreen(),
        ),
      ),
    );
  }
}
