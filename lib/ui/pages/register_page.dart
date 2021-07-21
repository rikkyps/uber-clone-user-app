import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:uber_rider/main.dart';
import 'package:uber_rider/ui/pages/login_page.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uber_rider/ui/pages/main_page.dart';
import '../widgets/progress_dialog.dart';

class RegisterPage extends StatelessWidget {
  static const String idScreen = 'register';

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
              'Register as Rider',
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
              controller: _nameController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                hintText: 'Name',
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
              controller: _emailController,
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
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                  hintText: 'Phone',
                  hintStyle: GoogleFonts.poppins()
                      .copyWith(fontSize: 10, color: Colors.grey),
                  border: InputBorder.none),
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
              controller: _passwordController,
              obscureText: true,
              keyboardType: TextInputType.visiblePassword,
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
                'Register',
                style: GoogleFonts.poppins().copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: () {
                if (_nameController.text.length < 2) {
                  displayToastMessage('Form nama minimal 3 karakter.', context);
                } else if (!_emailController.text.contains('@')) {
                  displayToastMessage('Format email tidak sesuai', context);
                } else if (_phoneController.text.isEmpty) {
                  displayToastMessage('Nomor hp harus diisi', context);
                } else if (_passwordController.text.length < 5) {
                  displayToastMessage('Password minimal 6 karakter', context);
                } else {
                  registerNewUser(context);
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
                'Already have an account?',
                style: GoogleFonts.poppins().copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                    color: Colors.grey[500]),
              ),
              GestureDetector(
                child: Text(' Login',
                    style: GoogleFonts.poppins().copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.amber)),
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginPage.idScreen, (route) => false);
                },
              )
            ],
          )
        ],
      ),
    );
  }

  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  void registerNewUser(BuildContext context) async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ProgressDialog(
            message: 'Sedang proses register, harap tunggu!',
          );
        });
    final User firebaseUser = (await _firebaseAuth
            .createUserWithEmailAndPassword(
                email: _emailController.text,
                password: _passwordController.text)
            .catchError((error) {
      Navigator.pop(context);
      displayToastMessage('Error: ' + error.toString(), context);
    }))
        .user;

    if (firebaseUser != null) {
      //User created on database
      userRef.child(firebaseUser.uid);

      Map userDataMap = {
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      userRef.child(firebaseUser.uid).set(userDataMap);
      displayToastMessage('Selamat, registrasi anda berhasil', context);

      Navigator.pushNamedAndRemoveUntil(
          context, MainPage.idScreen, (route) => false);
    } else {
      Navigator.pop(context);
      //Error user no created on database
      displayToastMessage('Registrasi gagal!', context);
    }
  }
}

displayToastMessage(String message, BuildContext context) {
  Fluttertoast.showToast(msg: message);
}
