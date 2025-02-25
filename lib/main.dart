import 'package:flutter/material.dart';
// Importations des différents modules de l'application
import 'pages/pages_meteo.dart'; // Page de météo
import 'pages/pages_vetement.dart'; // Page de recommandations vestimentaires
import 'dart:ui'; // Pour les effets visuels
import 'package:no/services/meteo_service.dart'; // Service de données météo
import 'package:no/models/meteo_model.dart'; // Modèles de données
import 'dart:async'; // Pour la gestion des timers
import 'dart:math'; // Pour les calculs mathématiques
import 'package:flutter/services.dart'; // Pour la configuration système

void main() {
  // Configuration initiale de l'application
  WidgetsFlutterBinding.ensureInitialized();
  // Verrouillage de l'orientation en portrait
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  // État de la page principale
  int _currentIndex = 0; // Index pour la navigation entre les pages
  final _meteoService = MeteoService(
      '3641f92b6daa0cfe486dab172645d785'); // Service météo avec clé API
  Meteo? _meteo; // Données météo actuelles
  List<HourlyForecast> _hourlyForecasts = []; // Prévisions horaires
  late Timer _refreshTimer; // Timer pour l'actualisation périodique

  // Calcul de la couleur du dégradé en fonction de l'heure
  Color _getTopColor() {
    if (_meteo == null) return Colors.orange;
    final now = DateTime.now();
    final sunrise = _meteo!.sunrise;
    final sunset = _meteo!.sunset;
    final sunriseStart = sunrise.subtract(const Duration(minutes: 20));
    final sunriseEnd = sunrise.add(const Duration(minutes: 5));
    final sunsetStart = sunset.subtract(const Duration(minutes: 20));
    final sunsetEnd = sunset.add(const Duration(minutes: 5));

    // Transition progressive entre les couleurs lors du lever/coucher
    // Utilisation d'une interpolation exponentielle pour un effet naturel
    if (now.isAfter(sunriseStart) && now.isBefore(sunriseEnd)) {
      final total = sunriseEnd.difference(sunriseStart).inSeconds;
      final progress = now.difference(sunriseStart).inSeconds;
      double t = pow(progress / total, 5).clamp(0.0, 1.0).toDouble();
      return Color.lerp(Colors.blue[900]!, Colors.orange[800]!, t)!;
    } else if (now.isAfter(sunsetStart) && now.isBefore(sunsetEnd)) {
      final total = sunsetEnd.difference(sunsetStart).inSeconds;
      final progress = now.difference(sunsetStart).inSeconds;
      double t = pow(progress / total, 5).clamp(0.0, 1.0).toDouble();
      return Color.lerp(Colors.orange[800]!, Colors.blue[900]!, t)!;
    } else {
      return now.isAfter(sunrise) && now.isBefore(sunset)
          ? Colors.orange[800]!
          : Colors.blue[900]!;
    }
  }

  // Couleur du bas du dégradé (jour/nuit)
  Color _getBottomColor() {
    if (_meteo == null) return Colors.white;
    final now = DateTime.now();
    return now.isAfter(_meteo!.sunrise) && now.isBefore(_meteo!.sunset)
        ? const Color.fromARGB(255, 200, 200, 200)
        : Colors.black;
  }

  // Récupération des données météo
  _fetchMeteo() async {
    try {
      // Récupération de la localisation et des données
      String nomVille = await _meteoService.getVilleActuelle();
      if (nomVille.isEmpty) nomVille = "Montréal";

      final meteo = await _meteoService.getMeteo(nomVille);

      try {
        final hourly =
            await _meteoService.getHourlyForecast(meteo.lat, meteo.lon);
        _hourlyForecasts = hourly;
      } catch (e) {
        print("Erreur prévisions horaires: $e");
        _hourlyForecasts = [];
      }

      setState(() => _meteo = meteo);
    } catch (e) {
      // Affichage des erreurs dans une boîte de dialogue
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur principale'),
          content: Text('Erreur: ${e.toString()}'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Observation des changements d'état de l'application
    WidgetsBinding.instance.addObserver(this);
    // Premier chargement des données
    _fetchMeteo();
    // Actualisation périodique toutes les 30 minutes
    _refreshTimer =
        Timer.periodic(const Duration(minutes: 30), (_) => _fetchMeteo());
  }

  @override
  void dispose() {
    // Nettoyage des ressources
    _refreshTimer.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Configuration des pages navigables
    final List<Widget> _pages = [
      PageMeteo(
        meteo: _meteo,
        hourlyForecasts: _hourlyForecasts,
      ),
      PageVetement(
        meteo: _meteo,
        hourlyForecasts: _hourlyForecasts,
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        // Animation fluide du dégradé de fond
        duration: const Duration(seconds: 2),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _getTopColor(),
              _getBottomColor(),
            ],
            stops: const [0.3, 1.0],
          ),
        ),
        child: SafeArea(
          child: SizedBox.expand(
            child: _pages[_currentIndex], // Affichage de la page active
          ),
        ),
      ),
      bottomNavigationBar: ClipRRect(
        // Barre de navigation personnalisée avec effet de flou
        borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 75,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              border: Border.all(
                color: Colors.white.withOpacity(0.25),
                width: 1.5,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              children: [
                // Boutons de navigation
                Expanded(
                  child: _buildNavButton(
                    context,
                    icon: Icons.wb_sunny,
                    label: 'Météo',
                    isActive: _currentIndex == 0,
                    onTap: () => setState(() => _currentIndex = 0),
                  ),
                ),
                Expanded(
                  child: _buildNavButton(
                    context,
                    icon: Icons.checkroom,
                    label: 'Vêtements',
                    isActive: _currentIndex == 1,
                    onTap: () => setState(() => _currentIndex = 1),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Méthode utilitaire pour créer les boutons de navigation
  Widget _buildNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    // Configuration visuelle dynamique selon l'état actif
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: isActive ? Colors.white.withOpacity(0.2) : Colors.transparent,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isActive ? Colors.white : Colors.white.withOpacity(0.7),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
