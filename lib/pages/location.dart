import 'dart:async';
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

  static const String _googleApiKey = AppSecrets.placesKey;
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

    if (_googleApiKey.isEmpty) {
      setState(() {
        _error = 'Chiave Places assente';
        _loading = false;
      });
      return;
    }

    try {
      final hasPermission = await _ensureLocationPermission();
      if (!hasPermission) {
        setState(() {
          _loading = false;
          _error = 'Permesso posizione negato';
        });
        return;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () async {
          final last = await Geolocator.getLastKnownPosition();
          return last ??
              Position(
                latitude: 0,
                longitude: 0,
                timestamp: DateTime.now(),
                accuracy: 0,
                altitude: 0,
                heading: 0,
                speed: 0,
                speedAccuracy: 0,
                altitudeAccuracy: 0,
                headingAccuracy: 0,
              );
        },
      );

      final user = LatLng(pos.latitude, pos.longitude);
      final mc = await _searchMcDonalds(user);

      if (mc == null) {
        setState(() {
          _initialCamera = CameraPosition(target: user, zoom: 13);
          _markers = {};
          _loading = false;
          _error = 'Nessun McDonald’s trovato entro ${(_radiusMeters / 1000).toStringAsFixed(1)} km';
        });
        return;
      }

      final markers = <Marker>{
        Marker(
          markerId: const MarkerId('mc'),
          position: mc,
          infoWindow: const InfoWindow(title: "McDonald's più vicino"),
        ),
      };

      setState(() {
        _markers = markers;
        _initialCamera = CameraPosition(target: mc, zoom: 13);
        _loading = false;
      });

      _controller?.animateCamera(CameraUpdate.newLatLngZoom(mc, 13));
    } catch (e) {
      setState(() {
        _error = 'Errore durante il caricamento';
        _loading = false;
      });
    }
  }

  Future<bool> _ensureLocationPermission() async {
    final service = await Geolocator.isLocationServiceEnabled();
    if (!service) return false;
    var perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
    }
    if (perm == LocationPermission.deniedForever) {
      await openAppSettings();
      return false;
    }
    return perm == LocationPermission.always || perm == LocationPermission.whileInUse;
  }

  Future<LatLng?> _searchMcDonalds(LatLng user) async {
    final url = Uri.parse('https://places.googleapis.com/v1/places:searchText');
    final headers = {
      'Content-Type': 'application/json',
      'X-Goog-Api-Key': _googleApiKey,
      'X-Goog-FieldMask': 'places.location,places.displayName',
    };
    final body = {
      'textQuery': "McDonald's",
      'maxResultCount': _maxResults,
      'rankPreference': 'DISTANCE',
      'locationBias': {
        'circle': {
          'center': {'latitude': user.latitude, 'longitude': user.longitude},
          'radius': _radiusMeters.toDouble(),
        },
      },
    };

    try {
      final res = await http.post(url, headers: headers, body: jsonEncode(body));
      if (res.statusCode != 200) return null;
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final raw = (data['places'] as List?) ?? const [];
      if (raw.isEmpty) return null;
      final first = raw.first as Map<String, dynamic>;
      final loc = first['location'] as Map<String, dynamic>;
      return LatLng(
        (loc['latitude'] as num).toDouble(),
        (loc['longitude'] as num).toDouble(),
      );
    } catch (_) {
      return null;
    }
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
    if (_error != null && _initialCamera == null) {
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
    final hasMc = _markers.any((m) => m.markerId.value == 'mc');
    return Scaffold(
      body: _initialCamera == null
          ? const Center(child: Text('Nessuna posizione'))
          : Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: _initialCamera!,
                  myLocationEnabled: false,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: _markers,
                  onMapCreated: (c) => _controller = c,
                ),
                if (_error != null)
                  Positioned(
                    left: 16,
                    right: 16,
                    top: 48,
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.75),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _error!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                if (hasMc)
                  Positioned(
                    right: 16,
                    bottom: 24,
                    child: FloatingActionButton.extended(
                      icon: const Icon(Icons.navigation),
                      label: const Text('Indicazioni'),
                      onPressed: () async {
                        final m = _markers.firstWhere((m) => m.markerId.value == 'mc');
                        await _openDirections(m.position);
                      },
                    ),
                  ),
              ],
            ),
    );
  }
}
