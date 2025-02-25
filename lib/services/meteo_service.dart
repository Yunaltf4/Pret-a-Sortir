import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:no/models/meteo_model.dart';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';

class MeteoService {
  // Configuration de l'API
  static const baseUrl = 'http://api.openweathermap.org/data/2.5';
  final String apiKey;

  MeteoService(this.apiKey);

  // Récupération des données météo actuelles
  Future<Meteo> getMeteo(String nomVille) async {
    try {
      final rep = await http
          .get(
            Uri.parse(
                '$baseUrl/weather?q=$nomVille&appid=$apiKey&units=metric'),
          )
          .timeout(const Duration(seconds: 10));

      if (rep.statusCode == 200) {
        return Meteo.fromJson(jsonDecode(rep.body));
      } else {
        throw Exception('Erreur ${rep.statusCode}');
      }
      // Gestion des erreurs réseau et timeouts
    } on SocketException {
      throw Exception('Pas de connexion internet');
    } on TimeoutException {
      throw Exception('Temps de réponse dépassé');
    }
  }

  // Récupération des prévisions horaires
  Future<List<HourlyForecast>> getHourlyForecast(double lat, double lon) async {
    try {
      final rep = await http.get(
        Uri.parse(
            '$baseUrl/forecast?lat=$lat&lon=$lon&cnt=10&units=metric&appid=$apiKey'),
      );

      if (rep.statusCode == 200) {
        final jsonData = jsonDecode(rep.body);
        return (jsonData['list'] as List)
            .map((hour) => HourlyForecast.fromJson(hour))
            .toList();
      } else {
        throw Exception('Erreur API: ${rep.statusCode}');
      }
    } catch (e) {
      throw Exception('Problème de connexion: $e');
    }
  }

  // Géolocalisation de l'utilisateur
  Future<String> getVilleActuelle() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      // Gestion des permissions

      if (permission == LocationPermission.deniedForever) {
        print(
            "Permission de localisation refusée définitivement. Aller aux paramètres.");
        return "";
      }

      if (permission == LocationPermission.denied) {
        print("Permission de localisation refusée.");
        return "";
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      // Conversion des coordonnées en nom de ville
      List<Placemark> repere =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      if (repere.isEmpty || repere[0].locality == null) {
        print("Aucune ville trouvée pour cette localisation.");
        return "";
      }

      return repere[0].locality!;
    } catch (e) {
      print("Erreur lors de la récupération de la ville actuelle : $e");
      return "";
    }
  }
}
