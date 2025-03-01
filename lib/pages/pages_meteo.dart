import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:no/models/meteo_model.dart';
import 'dart:ui';

class PageMeteo extends StatelessWidget {
  final Meteo? meteo;
  final List<HourlyForecast> hourlyForecasts;

  const PageMeteo({
    super.key,
    this.meteo,
    this.hourlyForecasts = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: Column(
        children: [
          _buildMainWeatherBlock(), // Bloc météo principal
          const SizedBox(height: 10),
          _buildHourlyBlock(), // Prévisions horaires
          const SizedBox(height: 10),
          _buildComingSoonBlock(), // Section fonctionnalités futures
        ],
      ),
    );
  }

  // Affichage des informations principales
  Widget _buildMainWeatherBlock() {
    if (meteo == null) {
      return _buildLoadingBlock();
    }
    return Expanded(
      flex: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: _blockDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meteo?.nomVille ?? 'Chargement...',
                            style: _textStyle(fontSize: 20),
                          ),
                          const SizedBox(height: 2.5),
                          Text(
                            '${meteo?.temp.round() ?? '--'}°C',
                            style: _textStyle(fontSize: 27),
                          ),
                          const SizedBox(height: 2.5),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('☀️ Lever',
                                      style: _textStyle(fontSize: 12)),
                                  Text(
                                      '${meteo?.sunrise.hour.toString().padLeft(2, '0')}:${meteo?.sunrise.minute.toString().padLeft(2, '0')}',
                                      style: _textStyle(fontSize: 14)),
                                ],
                              ),
                              const SizedBox(width: 25),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('🌙 Coucher',
                                      style: _textStyle(fontSize: 12)),
                                  Text(
                                      '${meteo?.sunset.hour.toString().padLeft(2, '0')}:${meteo?.sunset.minute.toString().padLeft(2, '0')}',
                                      style: _textStyle(fontSize: 14)),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      // Utilisation de Lottie pour les animations météo
                      Lottie.asset(
                        _getWeatherAnimation(
                          meteo?.condition,
                          isDay:
                              _isDayTime(meteo, meteo?.time ?? DateTime.now()),
                        ),
                        width: 120,
                        height: 120,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Liste horizontale des prévisions horaires
  Widget _buildHourlyBlock() {
    return Expanded(
      flex: 1,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: _blockDecoration(),
            child: hourlyForecasts.isEmpty
                ? _buildErrorBlock(
                    message: 'Prévisions horaires non disponibles')
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: hourlyForecasts.length,
                    itemBuilder: (context, index) {
                      final hourly = hourlyForecasts[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 10),
                        child: Container(
                          width: 90,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Icône
                                Lottie.asset(
                                  _getWeatherAnimation(
                                    hourly.condition,
                                    isDay: _isDayTime(meteo, hourly.time),
                                  ),
                                  width: 50,
                                  height: 50,
                                ),

                                // Température
                                Text(
                                  '${hourly.temp.round()}°',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),

                                // Heure
                                Text(
                                  '${hourly.time.hour.toString().padLeft(2, '0')}h',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ),
      ),
    );
  }

  // Section fonctionnalités futures
  Widget _buildComingSoonBlock() {
    return Expanded(
      flex: 2,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 30),
            decoration: _blockDecoration(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  'assets/meteo/rocket.json',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 20),
                Text(
                  'Fonctionnalité à venir!',
                  style: _textStyle(fontSize: 20),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Je travail sur des prévisions détaillées pour les prochains jours.',
                    textAlign: TextAlign.center,
                    style: _textStyle(
                        fontSize: 16, color: Colors.white.withOpacity(0.8)),
                  ),
                ),
                const SizedBox(height: 20)
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Bloc de chargement
  Widget _buildLoadingBlock({String message = 'Chargement...'}) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(height: 20),
            Text(message, style: _textStyle()),
          ],
        ),
      ),
    );
  }

  // Bloc d'erreur
  Widget _buildErrorBlock({required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              color: Colors.white.withOpacity(0.7), size: 40),
          const SizedBox(height: 10),
          Text(
            message,
            style:
                _textStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
          )
        ],
      ),
    );
  }

  // Décoration des blocs
  BoxDecoration _blockDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.35),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  // Style de texte
  TextStyle _textStyle({double fontSize = 24, Color color = Colors.white}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: color,
      letterSpacing: 0.5,
    );
  }

  // Sélection de l'animation météo avec gestion jour/nuit
  String _getWeatherAnimation(String? condition, {required bool isDay}) {
    if (condition == null) return 'assets/meteo/default.json';
    switch (condition.toLowerCase()) {
      case 'clear':
        return isDay ? 'assets/meteo/soleil.json' : 'assets/meteo/lune.json';
      case 'clouds':
        return isDay
            ? 'assets/meteo/nuage_jour.json'
            : 'assets/meteo/nuage.json';
      case 'rain':
        return 'assets/meteo/pluie.json';
      case 'snow':
        return 'assets/meteo/neige.json';
      default:
        return 'assets/meteo/default.json';
    }
  }

  // Vérifie si c'est le jour pour une heure donnée
  bool _isDayTime(Meteo? meteo, DateTime time) {
    if (meteo == null) return true;

    // Conversion des heures au même jour que le temps analysé
    final sunriseToday = DateTime(
      time.year,
      time.month,
      time.day,
      meteo.sunrise.hour,
      meteo.sunrise.minute,
    );

    final sunsetToday = DateTime(
      time.year,
      time.month,
      time.day,
      meteo.sunset.hour,
      meteo.sunset.minute,
    );

    return time.isAfter(sunriseToday) && time.isBefore(sunsetToday);
  }
}
