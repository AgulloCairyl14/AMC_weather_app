class Weather {
  final String cityName;
  final String main;
  final String description;
  final double temp;
  final int pressure;
  final int humidity;
  final double windSpeed;

  Weather({
    required this.cityName,
    required this.main,
    required this.description,
    required this.temp,
    required this.pressure,
    required this.humidity,
    required this.windSpeed,
  });

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      cityName: json['name'],
      main: json['weather'][0]['main'],
      description: json['weather'][0]['description'],
      temp: json['main']['temp'].toDouble(),
      pressure: json['main']['pressure'],
      humidity: json['main']['humidity'],
      windSpeed: json['wind']['speed'].toDouble(),
    );
  }
}
