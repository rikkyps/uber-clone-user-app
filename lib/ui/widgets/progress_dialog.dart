import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ProgressDialog extends StatelessWidget {
  final String message;

  ProgressDialog({this.message});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        margin: EdgeInsets.all(15),
        width: double.infinity,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(6), color: Colors.white),
        child: Row(
          children: [
            SizedBox(
              width: 6,
            ),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              message,
              style: GoogleFonts.poppins()
                  .copyWith(fontSize: 12, fontWeight: FontWeight.bold),
            )
          ],
        ),
      ),
    );
  }
}
