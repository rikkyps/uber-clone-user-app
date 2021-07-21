import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:uber_rider/models/address.dart';
import 'package:uber_rider/models/direction_detail.dart';
import 'package:uber_rider/providers/app_data.dart';
import '../shared.dart';

part 'request_services.dart';
part 'method_services.dart';
