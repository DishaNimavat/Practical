


import 'dart:convert';

import 'package:flutter_practical_aveosoft/model/image_list_model_response.dart';
import 'package:flutter_practical_aveosoft/utils/constants.dart';
import 'package:http/http.dart' as http;

class APIController {

  static Future< List<ImageListDataModelResponse>> fetchDataFromServerUsingGetMethod() async {
    return http.get(Uri.parse(IMAGE_URL)).then((http.Response response) {
      final int statusCode = response.statusCode;
      if (statusCode < 200 || statusCode > 400) {
        throw Exception("Error while fetching data $statusCode");
      }

      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((job) =>  ImageListDataModelResponse.fromJson(job)).toList();
    });
  }

}
