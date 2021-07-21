import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:uber_rider/models/address.dart';
import 'package:uber_rider/models/place_prediction.dart';
import 'package:uber_rider/providers/app_data.dart';
import 'package:uber_rider/services/services.dart';
import 'package:uber_rider/ui/widgets/progress_dialog.dart';
import '../../shared.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  TextEditingController _pickUpController = TextEditingController();
  TextEditingController _destinationController = TextEditingController();

  List<PlacePrediction> placePredictionList = [];

  @override
  Widget build(BuildContext context) {
    String placeAddress =
        Provider.of<AppData>(context).pickUpLocation.placeName ?? '';
    _pickUpController.text = placeAddress;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            //Header Section
            Container(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 0),
              height: MediaQuery.of(context).size.height * (1 / 3),
              width: double.infinity,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    blurRadius: 6,
                    color: Colors.grey,
                    offset: Offset(0.7, 0.7),
                    spreadRadius: 0.5)
              ], color: Colors.white),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  //TOP NAVIGATION
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          size: 30,
                        ),
                      ),
                      Text('Set Lokasi',
                          style: GoogleFonts.poppins(
                              fontSize: 18, fontWeight: FontWeight.w600)),
                      SizedBox(
                        width: 24,
                      )
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey)),
                    child: TextField(
                      controller: _pickUpController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Lokasi Jemputan',
                        prefixIcon: Icon(
                          Icons.location_searching,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                        isDense: false,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Container(
                    // padding: EdgeInsets.symmetric(horizontal: 10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey)),
                    child: TextField(
                      onChanged: (value) {
                        return getPlace(value);
                      },
                      controller: _destinationController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Tujuan',
                        isDense: false,
                        prefixIcon: Icon(
                          Icons.pin_drop,
                          color: Colors.blueAccent,
                          size: 20,
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(),
            //Search Prediction
            (placePredictionList.length > 0)
                ? Container(
                    margin: EdgeInsets.only(
                        top: MediaQuery.of(context).size.height * (1 / 2.8)),
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      itemCount: placePredictionList.length,
                      itemBuilder: (_, index) {
                        return Container(
                            margin: EdgeInsets.only(bottom: 10),
                            child: PredictionList(placePredictionList[index]));
                      },
                    ),
                  )
                : Container()
          ],
        ),
      ),
    );
  }

  void getPlace(String placeName) async {
    if (placeName.length > 1) {
      String endPoint =
          'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$apiKey&sessiontoken=1234567890&components=country:id';

      var res = await RequestServices.getRequest(endPoint: endPoint);
      if (res == 'failed') {
        return;
      }

      if (res['status'] == 'OK') {
        var predictions = res['predictions'];
        var predictionsList = (predictions as List)
            .map((e) => PlacePrediction.fromJson(e))
            .toList();

        setState(() {
          placePredictionList = predictionsList;
        });
      }
    }
  }
}

class PredictionList extends StatelessWidget {
  final PlacePrediction placePrediction;

  PredictionList(this.placePrediction);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: () {
        getPlaceAddressDetail(placePrediction.placeId, context);
      },
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(Icons.add_location, size: 24, color: Colors.blueAccent),
            SizedBox(
              width: 10,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: MediaQuery.of(context).size.width - (2 * 24) - 24 - 42,
                  child: Text(
                    placePrediction.mainText,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: Colors.black),
                  ),
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width - (2 * 24) - 24 - 42,
                  child: Text(placePrediction.secondary,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: GoogleFonts.poppins(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.grey)),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void getPlaceAddressDetail(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        message: 'Pick Tujuan, Mohon tunggu..',
      ),
    );
    String endPoint =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';
    var res = await RequestServices.getRequest(endPoint: endPoint);

    Navigator.pop(context);

    if (res == 'Failed') {
      return;
    }

    if (res['status'] == 'OK') {
      Address address = Address();
      address.placeName = res['result']['name'];
      address.placeId = placeId;
      address.latitude = res['result']['geometry']['location']['lat'];
      address.longitude = res['result']['geometry']['location']['lng'];
      address.placeFormatAddress = res['result']['formatted_address'];

      Provider.of<AppData>(context, listen: false)
          .updateDropOfLocationAddress(address);
      print('This is Drop Of Location');
      print(address.placeFormatAddress);

      Navigator.pop(context, 'getDirection');
    }
  }
}
