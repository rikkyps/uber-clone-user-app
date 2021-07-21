class PlacePrediction {
  String secondary;
  String mainText;
  String placeId;

  PlacePrediction({this.secondary, this.mainText, this.placeId});

  factory PlacePrediction.fromJson(Map<String, dynamic> data) =>
      PlacePrediction(
          secondary: data['structured_formatting']['secondary_text'],
          mainText: data['structured_formatting']['main_text'],
          placeId: data['place_id']);
}
