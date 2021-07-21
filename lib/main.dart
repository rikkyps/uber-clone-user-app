import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider/providers/app_data.dart';
import 'package:uber_rider/ui/pages/login_page.dart';
import 'package:uber_rider/ui/pages/main_page.dart';
import 'package:uber_rider/ui/pages/register_page.dart';
import 'package:firebase_core/firebase_core.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users');

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        theme: ThemeData(primarySwatch: Colors.amber),
        debugShowCheckedModeBanner: false,
        initialRoute: MainPage.idScreen,
        routes: {
          LoginPage.idScreen: (context) => LoginPage(),
          RegisterPage.idScreen: (context) => RegisterPage(),
          MainPage.idScreen: (context) => MainPage(),
        },
      ),
    );
  }
}

