import 'dart:math';

import 'package:kas_manager/constFiles/colors.dart';
import 'package:kas_manager/constFiles/strings.dart';
import 'package:kas_manager/controller/reportController.dart';
import 'package:kas_manager/controller/transDetailController.dart';
import 'package:kas_manager/controller/transactionController.dart';
import 'package:kas_manager/customWidgets/snackbar.dart';
import 'package:kas_manager/model/transactionModel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';


class MoneyFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Hapus semua karakter selain angka, titik, dan koma
    final rawText = newValue.text.replaceAll(RegExp(r'[^\d.,]'), '');

    // Hapus semua titik dan koma untuk proses parsing angka
    final text = rawText.replaceAll('.', '').replaceAll(',', '.');

    if (text.isEmpty) return newValue;

    // Pisahkan bagian angka sebelum dan sesudah koma/desimal
    final parts = text.split('.');
    final integerPart = _formatNumber(parts[0]); // Format bagian ribuan

    // Jika ada desimal, gabungkan kembali
    final formattedText = parts.length > 1
        ? '$integerPart,${parts[1]}' // Format dengan koma sebagai desimal
        : integerPart;

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }

  String _formatNumber(String input) {
    // Menambahkan titik setiap 3 digit
    return input.replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+$)'),
      (Match match) => '${match.group(1)}.',
    );
  }
}


class TransactionDetail extends StatelessWidget {
  final String role;
  TransactionDetail({Key? key, required this.role}) : super(key: key);
  static TransDetailController? transDetailController;
  static TransactionController? transController;
  static ReportController? reportController;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _showNotification() async {
    if (await Permission.notification.isGranted) {
      print("Notification permission granted. Showing notification.");

      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'warning_budget', // ID channel unik
        'warning_budget', // Nama channel
        channelDescription: 'warning_budget_channel_desc', // Deskripsi channel
        importance: Importance.max,
        priority: Priority.high,
        enableVibration: true, // Optional: enable vibration
      );

      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

//notifikasi
      await flutterLocalNotificationsPlugin.show(
        0, // ID notifikasi
        'Transaksi Besar', // Judul
        'Anda menerima pesan ini dikarenakan terdapat transaksi yang besar melebihi 300.000.', // Pesan
        platformChannelSpecifics, // Detail notifikasi
      );
    } else {
      print("Notification permission not granted. Cannot show notification.");
    }
  }

  @override
  Widget build(BuildContext context) {
    transDetailController = Provider.of<TransDetailController>(context);
    transController = Provider.of<TransactionController>(context);
    reportController = Provider.of<ReportController>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: whiteColor,
        elevation: 0.0,
        leadingWidth: 25.0,
        title: Row(
          children: [
            Text(
              transDetailController!.isIncomeSelected ? income : expense,
              style:
                  TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
            ),
            IconButton(
                icon: Icon(Icons.refresh_outlined),
                tooltip: "Change Category",
                onPressed: () => transDetailController!.changeCategory())
          ],
        ),
        actions: (role == 'bendahara')
            ? [
                Row(
                  children: [
                    Container(
                      margin: EdgeInsets.all(10.0),
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius:
                              BorderRadius.all(Radius.circular(15.0))),
                      child: TextButton(
                        onPressed: () async {
                          final DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2030),
                          );

                          if (pickedDate != null) {
                            save(context, pickedDate);
                          }
                        },
                        child: Text(
                          transDetailController!.savedTransaction
                              ? "Ubah"
                              : "Simpan",
                          style: TextStyle(color: whiteColor),
                        ),
                      ),
                    ),
                  ],
                )
              ]
            : null,
        iconTheme: IconThemeData(color: blackColor),
      ),
      body: Column(
        children: [
          GridView(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3, childAspectRatio: 1.4),
            children: [
              categoryIcons(
                  text: membershipDues,
                  svgName: memberSvg,
                  isSelected: transDetailController!.selectedDepartment ==
                          membershipDues
                      ? true
                      : false,
                  onPress: () =>
                      transDetailController!.changeDepartment(membershipDues)),
              categoryIcons(
                  text: donation,
                  svgName: donationSvg,
                  isSelected:
                      transDetailController!.selectedDepartment == donation
                          ? true
                          : false,
                  onPress: () =>
                      transDetailController!.changeDepartment(donation)),
              categoryIcons(
                  text: activityCosts,
                  svgName: activitySvg,
                  isSelected:
                      transDetailController!.selectedDepartment == activityCosts
                          ? true
                          : false,
                  onPress: () =>
                      transDetailController!.changeDepartment(activityCosts)),
              categoryIcons(
                  text: operational,
                  svgName: operationalSvg,
                  isSelected:
                      transDetailController!.selectedDepartment == operational
                          ? true
                          : false,
                  onPress: () =>
                      transDetailController!.changeDepartment(operational)),
              categoryIcons(
                  text: others,
                  svgName: othersSvg,
                  isSelected:
                      transDetailController!.selectedDepartment == others
                          ? true
                          : false,
                  onPress: () =>
                      transDetailController!.changeDepartment(others)),
            ],
          ),
          Container(
            color: primaryColor,
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Expanded(
                    flex: 5,
                    child: TextField(
                      controller: transDetailController!.titleField,
                      cursorColor: greyText,
                      style: TextStyle(
                          color: greyText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          hintText: "Judul harus diisi",
                          hintStyle: TextStyle(color: greyText),
                          prefixIcon: Padding(
                            padding:
                                const EdgeInsets.only(right: 15.0, left: 5.0),
                            child: SvgPicture.asset(
                              transDetailController!.titleIcon(),
                              height: 5.0,
                              color: whiteColor,
                            ),
                          ),
                          border: InputBorder.none),
                    )),
                Spacer(),
                Expanded(
                    flex: 2,
                    child: TextField(
                      controller: transDetailController!.amountField,
                      textAlign: TextAlign.end,
                      keyboardType: TextInputType.numberWithOptions(
                          decimal: true, signed: false),
                      inputFormatters: [MoneyFormatter()],
                      cursorColor: greyText,
                      style: TextStyle(
                          color: greyText,
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                          hintText: "Nominal",
                          hintStyle: TextStyle(color: greyText),
                          border: InputBorder.none),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                controller: transDetailController!.descriptionField,
                textAlign: TextAlign.start,
                minLines: 20,
                maxLines: 50,
                decoration: InputDecoration(
                    hintText: "Deskripsi....", border: InputBorder.none),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Padding categoryIcons({
    required String text,
    required String svgName,
    required bool isSelected,
    required Function() onPress,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
      child: InkWell(
        splashFactory: InkSplash.splashFactory,
        splashColor: Colors.transparent,
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onTap: onPress,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
              color: isSelected ? Color(0xffeae1f9) : Colors.transparent,
              borderRadius: BorderRadius.all(Radius.circular(15.0))),
          child: Column(
            children: [
              Expanded(
                child: SvgPicture.asset(
                  svgPath(svgName),
                  height: 35.0,
                  color: svgColor,
                ),
              ),
              Text(
                text,
                style: TextStyle(color: svgColor, fontSize: 16),
                textAlign: TextAlign.center,
              )
            ],
          ),
        ),
      ),
    );
  }

  save(BuildContext context, DateTime dateTime) {
    if (transDetailController!.titleField.text.isEmpty) {
      snackBar(context: context, title: "Judul harus diisi");
    } else if (double.tryParse(
                transDetailController!.amountField.text.replaceAll('.', '')) ==
            null ||
        transDetailController!.amountField.text.contains("-")) {
      snackBar(context: context, title: "Nominal harus valid");
    } else {
      // Pastikan field diperbarui dengan data terkini
      final updatedTitle = transDetailController!.titleField.text.trim();

      // Hapus titik pemisah ribuan dari input nominal
      final updatedAmount = transDetailController!.amountField.text
          .replaceAll('.', ''); // Simpan angka tanpa format titik

      TransactionModel transactionModel = TransactionModel(
        id: transDetailController!.savedTransaction
            ? transDetailController!.transactionId
            : DateTime.now().millisecondsSinceEpoch + Random().nextInt(1000),
        title: updatedTitle,
        description: transDetailController!.descriptionField.text,
        amount: updatedAmount, // Nominal tanpa titik
        isIncome: transDetailController!.isIncomeSelected ? 1 : 0,
        category: transDetailController!.selectedDepartment,
        dateTime: dateTime.toString(),
      );

      if (transDetailController!.savedTransaction) {
        print('Masuk ke update: ${transactionModel.toString()}');
        transController!.updateTransaction(transactionModel);
      } else {
        if (int.parse(updatedAmount) > 300000) {
          // Periksa nilai nominal asli
          _showNotification();
        }
        print('Masuk ke insert: ${transactionModel.toString()}');
        transController!.insertTransaction(transactionModel);
      }

      // Refresh data setelah menyimpan transaksi
      transController!.fetchTransaction();
      reportController!.fetchTransaction();
      Navigator.pop(context);
    }
  }
}
