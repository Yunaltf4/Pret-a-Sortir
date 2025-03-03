// Modèles de données pour la météo

class Meteo {
  // Structure des données météo principales
  final String nomVille; // Nom de la ville
  final double temp; // Température actuelle
  final String condition; // Condition météo (ex: pluie, soleil)
  final double lat; // Latitude de la ville
  final double lon; // Longitude de la ville
  final DateTime time; // Heure locale de la météo
  final DateTime sunrise; // Heure du lever du soleil
  final DateTime sunset; // Heure du coucher du soleil
  final double windSpeed; // Vitesse du vent
  final int humidity; // Humidité
  final double uvIndex; // Indice UV

  Meteo({
    required this.nomVille,
    required this.temp,
    required this.condition,
    required this.lat,
    required this.lon,
    required this.time,
    required this.sunrise,
    required this.sunset,
    required this.windSpeed,
    required this.humidity,
    required this.uvIndex,
  });

  // Conversion des données JSON de l'API en objet Dart
  factory Meteo.fromJson(Map<String, dynamic> json) {
    return Meteo(
      nomVille: json['name'],
      temp: json['main']['temp'],
      condition: json['weather'][0]['main'],
      lat: json['coord']['lat'],
      lon: json['coord']['lon'],
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      sunrise:
          DateTime.fromMillisecondsSinceEpoch(json['sys']['sunrise'] * 1000),
      sunset: DateTime.fromMillisecondsSinceEpoch(json['sys']['sunset'] * 1000),
      windSpeed: json['wind']['speed'].toDouble(),
      humidity: json['main']['humidity'],
      uvIndex: json['main']['uvi']?.toDouble() ?? 0,
    );
  }
}

class HourlyForecast {
  // Structure des prévisions horaires
  final DateTime time; // Heure de la prévision
  final double temp; // Température prévue
  final String condition; // Condition météo prévue
  final int humidity; // Humidité prévue
  final double windSpeed; // Vitesse du vent prévue

  HourlyForecast({
    required this.time,
    required this.temp,
    required this.condition,
    this.humidity = 0,
    this.windSpeed = 0,
  });

  // Conversion des données JSON
  factory HourlyForecast.fromJson(Map<String, dynamic> json) {
    return HourlyForecast(
      time: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      temp: (json['main']['temp'] as num).toDouble(), // Conversion explicite
      condition: json['weather'][0]['main'],
      humidity: json['main']['humidity'] ?? 0,
      windSpeed: (json['wind']['speed'] as num?)?.toDouble() ??
          0.0, // Conversion sécurisée
    );
  }
}
