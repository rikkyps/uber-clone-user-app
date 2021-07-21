import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uber_rider/main.dart';
import 'package:uber_rider/ui/pages/main_page.dart';
import 'package:uber_rider/ui/pages/register_page.dart';
import 'package:uber_rider/ui/widgets/progress_dialog.dart';

class LoginPage extends StatelessWidget {
  static const String idScreen = 'login';
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 24),
        children: [
          SizedBox(
            height: 65,
          ),
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 150,
            ),
          ),
          SizedBox(
            height: 1,
          ),
          Center(
            child: Text(
              'Login as Rider',
              style: GoogleFonts.poppins()
                  .copyWith(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            width: MediaQuery.of(context).size.width - (2 * 24),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                border: InputBorder.none,
                hintStyle: GoogleFonts.poppins()
                    .copyWith(fontSize: 10, color: Colors.grey),
              ),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 15),
            width: MediaQuery.of(context).size.width - (2 * 24),
            decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12)),
            child: TextField(
              controller: _password,
              obscureText: true,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                  hintText: 'Password',
                  hintStyle: GoogleFonts.poppins()
                      .copyWith(fontSize: 10, color: Colors.grey),
                  border: InputBorder.none),
            ),
          ),
          SizedBox(
            height: 25,
          ),
          Container(
            height: 50,
            width: MediaQuery.of(context).size.width - (2 * 24),
            child: RaisedButton(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              color: Colors.amber,
              child: Text(
                'Login',
                style: GoogleFonts.poppins().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                if (!_email.text.contains('@')) {
                  displayToastMessage('Format email tidak valid', context);
                } else if (_password.text.isEmpty) {
                  displayToastMessage('Password harus diisi!', context);
                } else {
                  loginAndAuthenticationUser(context);
                }
              },
            ),
          ),
          SizedBox(
            height: 30,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Do not have Account?',
                style: GoogleFonts.poppins().copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[500]),
              ),
              GestureDetector(
                child: Text(' Register',
                    style: GoogleFonts.poppins().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.amber)),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, RegisterPage.idScreen, (route) => false);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void loginAndAuthenticationUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: 'Sedang proses login, harap tunggu!',
          );
        });
    final User firebaseUser = (await _firebaseAuth
            .signInWithEmailAndPassword(
                email: _email.text, password: _password.text)
            .catchError((error) {
      Navigator.pop(context);
      displayToastMessage('error : ' + error.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      userRef.child(firebaseUser.uid).once().then((DataSnapshot snapShot) {
        if (snapShot.value != null) {
          Navigator.pushNamedAndRemoveUntil(
              context, MainPage.idScreen, (route) => false);
          displayToastMessage('Login berhasil!', context);
        } else {
          Navigator.pop(context);
          _firebaseAuth.signOut();
          displayToastMessage(
              'Data user tidak terdaftar, mohon registrasi!', context);
        }
      });
    } else {
      Navigator.pop(context);
      displayToastMessage('Login error', context);
    }
  }
}
