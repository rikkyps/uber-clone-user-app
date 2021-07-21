import 'package:flutter/material.dart';
import 'package:uber_rider/models/address.dart';

class AppData extends ChangeNotifier {
  Address pickUpLocation, dropOfLocation;

  void updatePickUpLocationAddress(Address pickUpAddress) {
    pickUpLocation = pickUpAddress;
    notifyListeners();
  }

  void updateDropOfLocationAddress(Address dropOfAddress) {
    dropOfLocation = dropOfAddress;
    notifyListeners();
  }
}
