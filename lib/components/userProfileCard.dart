import 'dart:io';
import 'package:kas_manager/constFiles/colors.dart';
import 'package:kas_manager/services/save_user_sessions.dart';
import 'package:kas_manager/view/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileCard extends StatefulWidget {
  static File? imageFile;

  @override
  _UserProfileCardState createState() => _UserProfileCardState();
}

class _UserProfileCardState extends State<UserProfileCard> {
  Future<void> logoutUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Menghapus semua data yang tersimpan
  }

  String? role = "";
  String? username = "";
  Future<void> _showUserRole() async {
    role = await getUserRole();
    print('Role pengguna: $role');
    setState(() {});
  }

  Future<void> _showUsername() async {
    username = await getUserInfo();
    print('username pengguna: $username');
    setState(() {});
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _showUserRole();
    _showUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 50.0,
          width: 50.0,
          decoration: BoxDecoration(
              color: profileContainer,
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          child: UserProfileCard.imageFile == null
              ? Icon(Icons.person, size: 35, color: profileBG)
              : Image.file(UserProfileCard.imageFile!, fit: BoxFit.contain),
        ),
        SizedBox(width: 15.0),
        Expanded(
          child: Container(
            height: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome Back,",
                  style:
                      TextStyle(color: greyText, fontWeight: FontWeight.bold),
                ),
                Text(
                  "${username} -  ${role}",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.0),
                ),
              ],
            ),
          ),
        ),
        IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              logoutUser();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        LoginPage()), // Ganti dengan halaman login Anda
                (route) => false, // Menghapus semua route sebelumnya
              );
            })
      ],
    );
  }
}
