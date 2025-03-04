import 'package:flutter/material.dart';
import 'package:no/models/meteo_model.dart';
import 'dart:ui';
import 'package:flutter_svg/flutter_svg.dart';

class PageVetement extends StatelessWidget {
  final Meteo? meteo;
  final List<HourlyForecast> hourlyForecasts;

  const PageVetement({
    super.key,
    this.meteo,
    this.hourlyForecasts = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 30),
      child: ListView(
        children: [
          _buildMainRecommendation(), // Recommandations globales
          const SizedBox(height: 20),
          _buildClothingLayers(), // Conseils de superposition
          const SizedBox(height: 20),
          _buildWeatherSpecificTips(), // Conseils spécifiques
          const SizedBox(height: 20),
          _buildHourlyPreparations(), // Préparations horaires
        ],
      ),
    );
  }

  // Analyse des données météo pour les recommandations
  Widget _buildMainRecommendation() {
    if (meteo == null) return _buildLoading();

    final temp = meteo!.temp;
    final condition = meteo!.condition.toLowerCase();
    final precipitationType = _getPrecipitationType();
    final windStrength = _getWindStrength();

    return _buildRecommendationCard(
      title: 'Recommandations Globales',
      children: [
        _buildTemperatureSection(temp),
        _buildPrecipitationSection(precipitationType),
        _buildWindSection(windStrength),
        _buildSpecialConditions(condition),
      ],
    );
  }

  // Conseils de superposition
  Widget _buildClothingLayers() {
    return _buildRecommendationCard(
      title: 'Superposition des Couches',
      children: [
        _buildLayerRecommendation(
            'Base', 'Matière respirante (soie, polyester)'),
        _buildLayerRecommendation('Interne', 'Isolation (laine, polaire)'),
        _buildLayerRecommendation(
            'Externe', 'Protection (imperméable, coupe-vent)'),
        _buildLayerTip(),
      ],
    );
  }

  // Conseils spécifiques
  Widget _buildWeatherSpecificTips() {
    return _buildRecommendationCard(
      title: 'Conseils Spécifiques',
      children: [
        if (_isHumid()) _buildHumidityTip(),
        if (_isFreezing()) _buildFreezingTip(),
        if (_hasSunExposure()) _buildSunProtection(),
        if (_isNightTime()) _buildVisibilityTip(),
      ],
    );
  }

  // Préparations horaires
  Widget _buildHourlyPreparations() {
    final upcomingChanges = _getWeatherChanges();

    return _buildRecommendationCard(
      title: 'Préparations Horaires',
      children: [
        if (upcomingChanges.isNotEmpty)
          ...upcomingChanges.map((change) => _buildWeatherChangeAlert(change)),
        if (upcomingChanges.isEmpty)
          _buildInfoText(
              'Aucun changement majeur prévu dans les prochaines heures'),
      ],
    );
  }

  // Helper functions
  Widget _buildTemperatureSection(double temp) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Température: ${temp.round()}°C'),
        Text(_getTemperatureComment(temp), style: _textStyle()),
        _buildClothingGrid(_getTemperatureClothing(temp)),
      ],
    );
  }

  // Commentaire sur la température
  String _getTemperatureComment(double temp) {
    if (temp < -20) return 'Froid extrême - Risque d\'hypothermie';
    if (temp < -10) return 'Froid glacial - Protection maximale nécessaire';
    if (temp < 0) return 'Froid vif - Couches épaisses recommandées';
    if (temp < 10) return 'Doux mais variable - Privilégiez les couches';
    if (temp < 30) return 'Chaud - Vêtements légers et respirants';
    return 'Chaleur extrême - Protection contre la déshydratation';
  }

  // Vêtements recommandés en fonction de la température
  List<String> _getTemperatureClothing(double temp) {
    if (temp < -10)
      return [
        'Combinaison thermique',
        'Cagoule',
        'Gants chauffants',
        'Bottes fourrées'
      ];
    if (temp < 0)
      return [
        'Manteau long',
        'Pull en laine',
        'Collants thermiques',
        'Écharpe épaisse'
      ];
    if (temp < 10) return ['Doudoune', 'Gants', 'Bonnet', 'Bottes'];
    if (temp < 20) return ['Veste légère', 'Cardigan', 'Jean', 'Baskets'];
    if (temp < 30) return ['T-shirt', 'Short', 'Sandales', 'Chapeau'];
    return ['Débardeur', 'Jupe légère', 'Nu-pieds', 'Brume rafraîchissante'];
  }

  // Section des précipitations
  Widget _buildPrecipitationSection(String precipitationType) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
            'Précipitations: ${precipitationType.isNotEmpty ? precipitationType : 'Aucune'}'),
        if (precipitationType.isNotEmpty) ...[
          Text(_getPrecipitationComment(precipitationType),
              style: _textStyle()),
          _buildClothingGrid(_getPrecipitationGear(precipitationType)),
        ],
      ],
    );
  }

  // Commentaire sur les précipitations
  String _getPrecipitationComment(String type) {
    return {
          'rain': 'Pluie prévue - Imperméabilisation essentielle',
          'snow': 'Neige attendue - Isolation thermique critique',
          'drizzle': 'Bruine possible - Privilégiez le water-resistant',
          'thunderstorm': 'Orages violents - Évitez les objets métalliques',
        }[type] ??
        '';
  }

  // Équipement recommandé en fonction des précipitations
  List<String> _getPrecipitationGear(String type) {
    return {
          'rain': [
            'Imperméable',
            'Parapluie compact',
            'Sur-pantalon',
            'Bottes caoutchouc'
          ],
          'snow': [
            'Manteau snowboard',
            'Gants étanches',
            'Crampons',
            'Lunettes de glacier'
          ],
          'drizzle': [
            'Veste softshell',
            'Chaussures imperméables',
            'Capuche',
            'Bandana'
          ],
          'thunderstorm': [
            'K-way pliable',
            'Chaussures de marche',
            'Couverture de survie',
            'Gilet réfléchissant'
          ],
        }[type] ??
        [];
  }

  // Section du vent
  Widget _buildWindSection(String strength) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Vent: $strength'),
        Text(_getWindComment(strength), style: _textStyle()),
        _buildClothingGrid(_getWindGear(strength)),
      ],
    );
  }

  // Commentaire sur le vent
  String _getWindComment(String strength) {
    return {
          'Léger': 'Vent léger - Aucune protection spécifique nécessaire',
          'Modéré': 'Vent modéré - Prévoyez une protection légère',
          'Fort': 'Vent fort - Protection contre le refroidissement éolien',
          'Très fort': 'Vent violent - Évitez les sorties non essentielles',
        }[strength] ??
        'Conditions de vent normales';
  }

  // Équipement recommandé en fonction du vent
  List<String> _getWindGear(String strength) {
    return {
          'Léger': ['Écharpe légère', 'Ceinture pour manteau'],
          'Modéré': ['Veste coupe-vent', 'Bonnet ajusté'],
          'Fort': ['Combinaison intégrale', 'Lunettes protectrices', 'Cagoule'],
          'Très fort': [
            'Combinaison intégrale',
            'Lunettes protectrices',
            'Cagoule'
          ],
        }[strength] ??
        [];
  }

  // Conditions spéciales
  Widget _buildSpecialConditions(String condition) {
    final tips = {
      'fog': 'Brouillard - Utilisez des vêtements réfléchissants',
      'hail': 'Grêle - Protégez votre tête avec un casque',
      'smoke': 'Fumée - Portez un masque de protection',
    };

    return tips.containsKey(condition)
        ? Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              tips[condition]!,
              style: _textStyle(color: Colors.amber),
            ),
          )
        : const SizedBox.shrink();
  }

  // Grille des vêtements recommandés
  Widget _buildClothingGrid(List<String> items) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) => Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.white.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            _getClothingIcon(items[index]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                items[index],
                style: _textStyle(),
                overflow: TextOverflow.ellipsis,
                maxLines: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Icône des vêtements
  Widget _getClothingIcon(String item) {
    final icons = {
      'Combinaison thermique': 'assets/icons/thermal_suit.svg',
      'Cagoule': 'assets/icons/balaclava.svg',
      'Gants chauffants': 'assets/icons/heated_gloves.svg',
      'Bottes fourrées': 'assets/icons/fur_boots.svg',
      'Manteau long': 'assets/icons/long_coat.svg',
      'Pull en laine': 'assets/icons/wool_sweater.svg',
      'Collants thermiques': 'assets/icons/thermal_tights.svg',
      'Écharpe épaisse': 'assets/icons/thick_scarf.svg',
      'Doudoune': 'assets/icons/down_jacket.svg',
      'Gants': 'assets/icons/gloves.svg',
      'Bonnet': 'assets/icons/bonnet.svg',
      'Bottes': 'assets/icons/boots.svg',
      'Veste légère': 'assets/icons/light_jacket.svg',
      'Cardigan': 'assets/icons/cardigan.svg',
      'Jean': 'assets/icons/jeans.svg',
      'Baskets': 'assets/icons/sneakers.svg',
      'T-shirt': 'assets/icons/tshirt.svg',
      'Short': 'assets/icons/shorts.svg',
      'Sandales': 'assets/icons/sandals.svg',
      'Chapeau': 'assets/icons/hat.svg',
      'Débardeur': 'assets/icons/tank_top.svg',
      'Jupe légère': 'assets/icons/light_skirt.svg',
      'Nu-pieds': 'assets/icons/flip_flops.svg',
      'Brume rafraîchissante': 'assets/icons/cooling_spray.svg',
    };

    return icons.containsKey(item)
        ? SvgPicture.asset(
            icons[item]!,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
          )
        : Icon(Icons.check, color: Colors.white, size: 24);
  }

  // ... (méthodes d'analyse des données météo)

  bool _isHumid() => (meteo?.humidity ?? 0) > 70;
  bool _isFreezing() => (meteo?.temp ?? 0) < 0;
  bool _hasSunExposure() {
    final now = DateTime.now();
    return now.isAfter(meteo?.sunrise ?? now) &&
        now.isBefore(meteo?.sunset ?? now);
  }

  bool _isNightTime() =>
      DateTime.now().isAfter(meteo?.sunset ?? DateTime.now());

  // Type de précipitation
  String _getPrecipitationType() {
    final nextPrecip = hourlyForecasts.firstWhere(
      (h) =>
          h.condition.toLowerCase().contains('rain') ||
          h.condition.toLowerCase().contains('snow'),
      orElse: () =>
          HourlyForecast(time: DateTime.now(), temp: 0, condition: ''),
    );
    return nextPrecip.condition.toLowerCase().contains('snow')
        ? 'snow'
        : nextPrecip.condition.toLowerCase().contains('drizzle')
            ? 'drizzle'
            : nextPrecip.condition.toLowerCase().contains('thunder')
                ? 'thunderstorm'
                : nextPrecip.condition.isNotEmpty
                    ? 'rain'
                    : '';
  }

  // Force du vent
  String _getWindStrength() {
    final windSpeed = meteo?.windSpeed ?? 0;
    return windSpeed < 3
        ? 'Léger'
        : windSpeed < 10
            ? 'Modéré'
            : windSpeed < 20
                ? 'Fort'
                : 'Très fort';
  }

  // Changements météo importants
  List<String> _getWeatherChanges() {
    final changes = <String>[];
    final currentCondition = meteo?.condition.toLowerCase() ?? '';

    for (final forecast in hourlyForecasts.take(6)) {
      if (!forecast.condition.toLowerCase().contains(currentCondition)) {
        changes.add('${forecast.time.hour}h: ${forecast.condition}');
      }
    }
    return changes;
  }

  // ... (méthodes UI communes)

  // Carte de recommandation
  Widget _buildRecommendationCard(
      {required String title, required List<Widget> children}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: _boxDecoration(),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: _titleStyle()),
              const SizedBox(height: 10),
              ...children,
            ],
          ),
        ),
      ),
    );
  }

  // Titre de section
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: _textStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  // Recommandation de couche
  Widget _buildLayerRecommendation(String layer, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Text('$layer: ', style: _textStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(description, style: _textStyle())),
        ],
      ),
    );
  }

  // Astuce de superposition
  Widget _buildLayerTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'Astuce: Adaptez les couches selon l\'activité et la météo.',
        style: _textStyle(fontStyle: FontStyle.italic),
      ),
    );
  }

  // Astuce d'humidité
  Widget _buildHumidityTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'Humidité élevée - Privilégiez les matières respirantes.',
        style: _textStyle(),
      ),
    );
  }

  // Astuce de gel
  Widget _buildFreezingTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'Températures négatives - Couvrez bien les extrémités.',
        style: _textStyle(),
      ),
    );
  }

  // Protection solaire
  Widget _buildSunProtection() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'Exposition au soleil - Utilisez de la crème solaire et des lunettes.',
        style: _textStyle(),
      ),
    );
  }

  // Astuce de visibilité
  Widget _buildVisibilityTip() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'Faible luminosité - Portez des vêtements réfléchissants.',
        style: _textStyle(),
      ),
    );
  }

  // Alerte de changement météo
  Widget _buildWeatherChangeAlert(String change) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        'Changement prévu: $change',
        style: _textStyle(),
      ),
    );
  }

  // Texte d'information
  Widget _buildInfoText(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Text(
        text,
        style: _textStyle(),
      ),
    );
  }

  // Bloc de chargement
  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  // Décoration de la boîte
  BoxDecoration _boxDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.25),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
    );
  }

  // Style de titre
  TextStyle _titleStyle() {
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
      letterSpacing: 0.5,
    );
  }

  // Style de texte
  TextStyle _textStyle(
      {double fontSize = 16,
      FontWeight fontWeight = FontWeight.normal,
      FontStyle fontStyle = FontStyle.normal,
      Color color = Colors.white}) {
    return TextStyle(
      fontSize: fontSize,
      fontWeight: fontWeight,
      fontStyle: fontStyle,
      color: color.withOpacity(0.9),
      height: 1.4,
    );
  }
}
