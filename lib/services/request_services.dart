part of 'services.dart';

class RequestServices {
  static Future<dynamic> getRequest({String endPoint}) async {
    var response = await http.get(endPoint);

    try {
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data;
      } else {
        return 'Failed';
      }
    } catch (error) {
      return 'Failed';
    }
  }
}
