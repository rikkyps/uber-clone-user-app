import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider/models/direction_detail.dart';
import 'package:uber_rider/providers/app_data.dart';
import 'package:uber_rider/services/services.dart';
import 'package:uber_rider/ui/pages/search_page.dart';
import 'package:uber_rider/ui/widgets/progress_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MainPage extends StatefulWidget {
  static const String idScreen = 'mainScreen';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  Completer<GoogleMapController> _mapController = Completer();
  GoogleMapController _newMapController;

  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  Position currentPosition;

  DirectionDetail tripDirectionDetails;

  var geoLocator = Geolocator();

  double bottomPaddingOfMap = 310;

  Set<Polyline> polylineSet = {};
  List<LatLng> polylinesCoordinate = [];

  Set<Marker> markers = {};
  Set<Circle> circles = {};

  double rideDetailContainer = 0;
  double searchContainerHeight = 300;

  bool isDrawerOpened = true;

  resetApp() {
    setState(() {
      isDrawerOpened = true;
      searchContainerHeight = 300;
      rideDetailContainer = 0;
      bottomPaddingOfMap = 310;
      polylineSet.clear();
      circles.clear();
      markers.clear();
      polylinesCoordinate.clear();
    });

    locatePosition();
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      isDrawerOpened = false;
      rideDetailContainer = 240;
      searchContainerHeight = 0;
      bottomPaddingOfMap = 250;
    });
  }

  void locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latLngPosition = LatLng(position.latitude, position.longitude);

    CameraPosition cameraPosition =
        new CameraPosition(target: latLngPosition, zoom: 14);
    _newMapController
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    String address =
        await MethodServices.searchCoordinateAddress(position, context);
    print('This is your address :' + address);
  }

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> getPlaceDirection() async {
    var initialLocation =
        Provider.of<AppData>(context, listen: false).pickUpLocation;
    var destinationLocation =
        Provider.of<AppData>(context, listen: false).dropOfLocation;

    var initialLatLng =
        LatLng(initialLocation.latitude, initialLocation.longitude);
    var destinationLatLng =
        LatLng(destinationLocation.latitude, destinationLocation.longitude);

    showDialog(
        context: context,
        builder: (BuildContext context) => ProgressDialog(
              message: 'Mohon tunggu..',
            ));

    var details = await MethodServices.getDirectionLocation(
        initialLatLng, destinationLatLng);

    setState(() {
      tripDirectionDetails = details;
    });

    Navigator.pop(context);
    print('ini endcode point :');
    print(details.distanceValue);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodePolylinePoint =
        polylinePoints.decodePolyline(details.endCodePoints);

    polylinesCoordinate.clear();
    if (decodePolylinePoint.isNotEmpty) {
      decodePolylinePoint.forEach((PointLatLng pointLatLng) {
        polylinesCoordinate
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
    }

    polylineSet.clear();

    Polyline polyline = Polyline(
        color: Colors.amber,
        polylineId: PolylineId('Polyline ID'),
        jointType: JointType.round,
        points: polylinesCoordinate,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true);

    setState(() {
      polylineSet.add(polyline);
    });

    LatLngBounds latLngBounds;

    if (initialLatLng.latitude > destinationLatLng.latitude &&
        initialLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds =
          LatLngBounds(southwest: destinationLatLng, northeast: initialLatLng);
    } else if (initialLatLng.latitude > destinationLatLng.latitude) {
      latLngBounds = LatLngBounds(
          southwest:
              LatLng(destinationLatLng.latitude, initialLatLng.longitude),
          northeast:
              LatLng(initialLatLng.latitude, destinationLatLng.longitude));
    } else if (initialLatLng.longitude > destinationLatLng.longitude) {
      latLngBounds = LatLngBounds(
          southwest:
              LatLng(initialLatLng.latitude, destinationLatLng.longitude),
          northeast:
              LatLng(destinationLatLng.latitude, initialLatLng.longitude));
    } else {
      latLngBounds =
          LatLngBounds(southwest: initialLatLng, northeast: destinationLatLng);
    }

    _newMapController
        .animateCamera(CameraUpdate.newLatLngBounds(latLngBounds, 70));

    Marker initialMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        markerId: MarkerId('initialLocation'),
        infoWindow: InfoWindow(
            title: initialLocation.placeName, snippet: 'Lokasi Jemput'),
        position: initialLatLng);

    Marker destinationMarker = Marker(
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        markerId: MarkerId('destinationLocation'),
        infoWindow: InfoWindow(
            title: destinationLocation.placeName, snippet: 'Lokasi Antar'),
        position: destinationLatLng);

    Circle initialCircle = Circle(
        fillColor: Colors.green,
        center: initialLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.greenAccent,
        circleId: CircleId('initialCircleId'));

    Circle destinationCircle = Circle(
        fillColor: Colors.red,
        center: destinationLatLng,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.redAccent,
        circleId: CircleId('destinationCircleId'));

    setState(() {
      markers.add(initialMarker);
      markers.add(destinationMarker);
      circles.add(initialCircle);
      circles.add(destinationCircle);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text('Main Page'),
      ),
      drawer: Container(
        color: Colors.white,
        width: MediaQuery.of(context).size.width * 2 / 3,
        child: Drawer(
          child: ListView(
            children: [
              //Drawer Header
              Container(
                height: 165,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ),
                  child: Row(
                    children: [
                      Image.asset(
                        'assets/images/user_icon.png',
                        height: 65,
                        width: 65,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Text('Profile Name',
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w600)),
                          ),
                          SizedBox(
                            child: Text('user@mail.com',
                                style: GoogleFonts.poppins(
                                    fontSize: 12, fontWeight: FontWeight.w300)),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
              Divider(
                height: 1,
                color: Colors.grey,
              ),
              SizedBox(
                height: 16,
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text(
                  'History',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.person),
                title: Text(
                  'Profile',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ListTile(
                leading: Icon(Icons.info),
                title: Text(
                  'About',
                  style: GoogleFonts.poppins(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              )
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            //Google Maps
            GoogleMap(
              padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
              mapType: MapType.normal,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              polylines: polylineSet,
              markers: markers ?? markers,
              circles: circles ?? circles,
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: (GoogleMapController controller) {
                _mapController.complete(controller);
                _newMapController = controller;
                setState(() {
                  bottomPaddingOfMap = 300;
                });
                locatePosition();
              },
            ),

            //Hamber Button for Drawer
            Positioned(
              top: 38,
              left: 22,
              child: GestureDetector(
                onTap: () {
                  if (isDrawerOpened) {
                    scaffoldKey.currentState.openDrawer();
                  } else {
                    resetApp();
                  }
                },
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          blurRadius: 6,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        ),
                      ]),
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Icon((isDrawerOpened) ? Icons.menu : Icons.close,
                        color: Colors.black),
                    radius: 20,
                  ),
                ),
              ),
            ),

            //Bottom Nav
            Positioned(
              left: 0.0,
              right: 0.0,
              bottom: 0.0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: Duration(milliseconds: 160),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 15),
                  height: searchContainerHeight,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(18),
                        topRight: Radius.circular(18),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.grey,
                            blurRadius: 6,
                            spreadRadius: 0.5,
                            offset: Offset(0.7, 0.7))
                      ]),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hallo bro!',
                        style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black,
                            fontWeight: FontWeight.w400),
                      ),
                      Text(
                        'Mau kemana?',
                        style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          var res = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => SearchPage()));
                          if (res == 'getDirection') {
                            displayRideDetailsContainer();
                          }
                        },
                        child: Container(
                          height: 40,
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    blurRadius: 6,
                                    color: Colors.grey,
                                    offset: Offset(0.7, 0.7),
                                    spreadRadius: 0.5)
                              ],
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.search,
                                size: 24,
                                color: Colors.lightBlue,
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Text(
                                'Cari tujuan anda',
                                style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.home, size: 24, color: Colors.grey),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width -
                                          (2 * 24) -
                                          24 -
                                          10,
                                      child: Text(
                                        Provider.of<AppData>(context)
                                                    .pickUpLocation !=
                                                null
                                            ? Provider.of<AppData>(context)
                                                .pickUpLocation
                                                .placeName
                                            : 'Add Home',
                                        // 'Add Home',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                      ),
                                    ),
                                    Text(
                                      'Tambahkan alamat rumah anda',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              height: 2,
                              color: Colors.grey,
                              thickness: 2,
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(Icons.work, size: 24, color: Colors.grey),
                                SizedBox(
                                  width: 10,
                                ),
                                Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Kantor',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      'Tambahkan alamat kantor anda',
                                      style: GoogleFonts.poppins(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w300,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            Divider(
                              height: 2,
                              color: Colors.grey,
                              thickness: 2,
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),

            //Rider Detail Pricing
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedSize(
                vsync: this,
                curve: Curves.bounceIn,
                duration: Duration(milliseconds: 160),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 17),
                  height: rideDetailContainer,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                      boxShadow: [
                        BoxShadow(
                          blurRadius: 16,
                          color: Colors.black,
                          spreadRadius: 0.5,
                          offset: Offset(0.7, 0.7),
                        )
                      ]),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: Colors.tealAccent,
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Image.asset(
                              'assets/images/taxi.png',
                              height: 70,
                              width: 80,
                            ),
                            SizedBox(
                              width: 16,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Car',
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w400),
                                ),
                                Text(
                                  (tripDirectionDetails != null)
                                      ? tripDirectionDetails.distanceText
                                      : '',
                                  style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w300,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                            Spacer(),
                            Text(
                              (tripDirectionDetails != null)
                                  ? 'Rp. ${MethodServices.calculateFares(tripDirectionDetails)}'
                                  : '',
                              style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w300,
                                  color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Icon(FontAwesomeIcons.moneyCheckAlt,
                                size: 18, color: Colors.black54),
                            SizedBox(
                              width: 16,
                            ),
                            Text('Cash',
                                style: GoogleFonts.poppins(fontSize: 14)),
                            SizedBox(
                              height: 6,
                            ),
                            Icon(Icons.keyboard_arrow_down,
                                color: Colors.black54, size: 16),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Container(
                        height: 45,
                        width: MediaQuery.of(context).size.width - (2 * 24),
                        child: RaisedButton(
                          color: Colors.amber[300],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            'Pesan',
                            style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black),
                          ),
                          onPressed: () {},
                        ),
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
