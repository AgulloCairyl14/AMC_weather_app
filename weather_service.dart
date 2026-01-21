import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/weather.dart';

class WeatherService {
  static const String apikey = '920335502a6829a4424d5620a67cda33';
  static const String baseUrl = 'https://api.openweathermapp.org/data/2.5/weather';

  static future<Weather> getWeather(string cityName) async {
    try {
    final url = '$baseurl?q=$cityName&appid=$apikey&units=metric';

    final http.Response response = await http.get (
      Url.parse(url),
      headers:{'Content-Type': 'applications/json'},
    )

    if(response.statusCode == 200) {
      final Map<String, dyanamic> data = json.decode(response.body);
      return Weather.fromJson(data);
    }
    else if (response.statusCode ==404) {
      throw Exception('City not found');
    }
    else{
      throw Exception('failed to weather data');

    }
  }
  catch(e) {
    throw Exception()
  }
}