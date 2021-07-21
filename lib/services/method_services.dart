part of 'services.dart';

class MethodServices {
  static Future<String> searchCoordinateAddress(
      Position position, context) async {
    String placeAddress = '';
    String endPoint =
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=' +
            apiKey;

    var response = await RequestServices.getRequest(endPoint: endPoint);

    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];

      Address userPickUpAddress = new Address();
      userPickUpAddress.latitude = position.latitude;
      userPickUpAddress.longitude = position.longitude;
      userPickUpAddress.placeName = placeAddress;

      Provider.of<AppData>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }

    return placeAddress;
  }

  static Future<DirectionDetail> getDirectionLocation(
      LatLng initialPosition, destinationPosition) async {
    String endPoint =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$apiKey';
    var res = await RequestServices.getRequest(endPoint: endPoint);

    if (res == 'Failed') {
      return null;
    }

    DirectionDetail directionDetail = DirectionDetail();

    directionDetail.endCodePoints =
        res['routes'][0]['overview_polyline']['points'];
    directionDetail.distanceText =
        res['routes'][0]['legs'][0]['distance']['text'];
    directionDetail.distanceValue =
        res['routes'][0]['legs'][0]['distance']['value'];
    directionDetail.durationText =
        res['routes'][0]['legs'][0]['duration']['text'];
    directionDetail.durationValue =
        res['routes'][0]['legs'][0]['duration']['value'];

    return directionDetail;
  }

  static int calculateFares(DirectionDetail directionDetail) {
    //format waktu dalam USD format
    double timeTravelFare = (directionDetail.durationValue / 60) * 0.20;
    double distanceTravelFare = (directionDetail.distanceValue / 1000) * 0.20;
    double totalFare = timeTravelFare + distanceTravelFare;

    //1$ = 14000 Rupiah
    double totalPay = totalFare * 14000;

    return totalPay.truncate();
  }
}
