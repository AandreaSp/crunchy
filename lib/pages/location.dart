import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:crunchy/generated/secrets.g.dart';

class LocationPage extends StatefulWidget {
  const LocationPage({super.key});

  @override
  State<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends State<LocationPage> {
  GoogleMapController? _controller;
  CameraPosition? _initialCamera;
  Set<Marker> _markers = {};
  bool _loading = true;
  String? _error;

  // API key generata via Gradle
  static const String _googleApiKey = AppSecrets.placesKey;

  // Parametri Nearby Search (senza filtro testo lato server)
  static const int _radiusMeters = 5000;
  static const int _maxResults = 10;

  @override
  void initState() {
    super.initState();
    _initFlow();
  }

  Future<void> _initFlow() async {
    setState(() {
      _loading = true;
      _error = null;
      _markers = {};
      _initialCamera = null;
    });

    debugPrint('🔑 API Key loaded: ${_googleApiKey.isEmpty ? "EMPTY" : "OK (${_googleApiKey.substring(0, 10)}...)"}');

    if (_googleApiKey.isEmpty) {
      setState(() {
        _error = 'Chiave Places assente';
        _loading = false;
      });
      return;
    }

    try {
      final hasPermission = await _ensureLocationPermission();
      debugPrint('🛰️ Permission granted: $hasPermission');

      if (!hasPermission) {
        setState(() {
          _error = 'Permesso posizione negato';
          _loading = false;
        });
        return;
      }

      // In sviluppo puoi usare coordinate fisse. In produzione usa Geolocator.
      const user = LatLng(41.576288, 14.674754);
      debugPrint('📍 User coords: ${user.latitude}, ${user.longitude}');

      final result = await _searchNearby(user);

      final target = result.nearestMcDonalds ?? result.nearestAny ?? user;
      debugPrint('🎯 Target coords: ${target.latitude}, ${target.longitude} '
          '(mc=${result.nearestMcDonalds != null}, any=${result.nearestAny != null})');

      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('me'),
          position: user,
          infoWindow: const InfoWindow(title: 'La tua posizione'),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
        Marker(
          markerId: const MarkerId('my_restaurant'),
          position: target,
          infoWindow: InfoWindow(
            title: result.nearestMcDonalds != null
                ? "McDonald's più vicino"
                : (result.nearestAny != null
                    ? 'Ristorante più vicino'
                    : 'Nessun ristorante trovato'),
          ),
        ),
      };

      setState(() {
        _markers = markers;
        _initialCamera = CameraPosition(target: target, zoom: 13);
        _loading = false;
      });

      _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(target, 13),
      );
    } catch (e, st) {
      debugPrint('❌ Init error: $e');
      debugPrint('🧵 Stack: $st');

      setState(() {
        _error = 'Errore durante il caricamento';
        _loading = false;
      });
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final service = await Geolocator.isLocationServiceEnabled();
    debugPrint('🔧 Location service enabled: $service');
    if (!service) return false;

    var perm = await Geolocator.checkPermission();
    debugPrint('🔐 Permission status before: $perm');
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      debugPrint('🔐 Permission status after request: $perm');
    }
    if (perm == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

  // Prima opzione: Nearby Search senza "query"/"keyword".
  // Filtra "McDonald" lato client e, se non presente, usa il primo (già per distanza).
  Future<_NearbyResult> _searchNearby(LatLng user) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places:searchNearby');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _googleApiKey,
      'X-Goog-FieldMask': 'places.location,places.displayName',
    };
    final body = {
      'includedTypes': ['restaurant'],
      'maxResultCount': _maxResults,
      'locationRestriction': {
        'circle': {
          'center': {'latitude': user.latitude, 'longitude': user.longitude},
          'radius': _radiusMeters.toDouble(),
        },
      },
      'rankPreference': 'DISTANCE',
    };

    debugPrint('➡️ Nearby POST body: $body');

    late http.Response res;
    try {
      res = await http.post(url, headers: headers, body: jsonEncode(body));
    } catch (e) {
      debugPrint('🌐 HTTP error: $e');
      return const _NearbyResult();
    }

    debugPrint('🌍 Nearby status=${res.statusCode}');
    debugPrint('🌍 Nearby body=${res.body}');

    if (res.statusCode != 200) {
      return const _NearbyResult();
    }

    Map<String, dynamic> data;
    try {
      data = jsonDecode(res.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('🧩 JSON parse error: $e');
      return const _NearbyResult();
    }

    final raw = (data['places'] as List?) ?? const [];
    debugPrint('📦 Places count: ${raw.length}');

    final places = raw.cast<Map<String, dynamic>>();

    LatLng? nearestAny;
    if (places.isNotEmpty) {
      final loc = places.first['location'];
      nearestAny = LatLng(
        (loc['latitude'] as num).toDouble(),
        (loc['longitude'] as num).toDouble(),
      );
      debugPrint('🥇 Nearest ANY: ${nearestAny.latitude}, ${nearestAny.longitude}');
    }

    LatLng? nearestMc;
    for (final p in places) {
      final dn = p['displayName'] as Map<String, dynamic>?;
      final name = (dn?['text'] as String? ?? '').toLowerCase();
      if (name.contains('mcdonald')) {
        final loc = p['location'] as Map<String, dynamic>;
        nearestMc = LatLng(
          (loc['latitude'] as num).toDouble(),
          (loc['longitude'] as num).toDouble(),
        );
        break;
      }
    }


    return _NearbyResult(nearestAny: nearestAny, nearestMcDonalds: nearestMc);
  }

  Future<void> _openDirections(LatLng target) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${target.latitude},${target.longitude}&travelmode=driving',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!),
              const SizedBox(height: 12),
              FilledButton(onPressed: _initFlow, child: const Text('Riprova')),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: _initialCamera == null
          ? const Center(child: Text('Nessuna posizione'))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera!,
                  myLocationEnabled: true,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  onMapCreated: (c) => _controller = c,
                ),
                Positioned(
                  right: 16,
                  bottom: 24,
                  child: FloatingActionButton.extended(
                    icon: const Icon(Icons.navigation),
                    label: const Text('Indicazioni'),
                    onPressed: () async {
                      final m = _markers.firstWhere(
                        (m) => m.markerId.value == 'my_restaurant',
                        orElse: () => _markers.first,
                      );
                      await _openDirections(m.position);
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _NearbyResult {
  final LatLng? nearestAny;
  final LatLng? nearestMcDonalds;
  const _NearbyResult({this.nearestAny, this.nearestMcDonalds});
}
