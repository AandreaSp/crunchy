import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

import 'package:crunchy/generated/secrets.g.dart';
import 'package:crunchy/services/location_persistence.dart';

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

  // Persistenza
  final LocationPersistence _persist = const LocationPersistence();
  bool _restoredFromCache = false;

  // Config
  static const String _googleApiKey = AppSecrets.placesKey;
  static const int _radiusMeters = 5000;
  static const int _maxResults = 10;

  @override
  void initState() {
    super.initState();
    _boot();
  }

  Future<void> _boot() async {
    await _restoreLastResult();
    await _initFlow();
  }

  Future<void> _restoreLastResult() async {
    try {
      final (lat, lng) = await _persist.loadLastLatLng();
      if (lat != null && lng != null) {
        final savedTarget = LatLng(lat, lng);
        setState(() {
          _restoredFromCache = true;
          _initialCamera = CameraPosition(target: savedTarget, zoom: 13);
          _markers = {
            Marker(
              markerId: const MarkerId('mc'),
              position: savedTarget,
              infoWindow: const InfoWindow(title: "McDonald's (ultimo risultato)"),
            ),
          };
          _loading = false;
          _error = null;
        });
      }
    } catch (_) {
    }
  }

  Future<void> _initFlow() async {
    setState(() {
      _loading = true;
      _error = null;
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
          _error = 'Permesso posizione negato o servizi disattivati';
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
          _initialCamera ??= CameraPosition(target: user, zoom: 13);
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

      await _persist.saveLastLatLng(mc.latitude, mc.longitude);

      setState(() {
        _markers = markers;
        _initialCamera = CameraPosition(target: mc, zoom: 13);
        _loading = false;
        _error = null;
        _restoredFromCache = false; // ora abbiamo un risultato fresco
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
    final hasMc = _markers.any((m) => m.markerId.value == 'mc');

    return Scaffold(
      body: Stack(
        children: [
          if (_initialCamera != null)
            GoogleMap(
              initialCameraPosition: _initialCamera!,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _markers,
              onMapCreated: (c) => _controller = c,
            )
          else if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            const Center(child: Text('Nessuna posizione')),

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
                    color: Colors.black.withValues(alpha: 0.75),
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

          if (_loading && _initialCamera != null)
            const Positioned.fill(
              child: IgnorePointer(
                child: Center(child: CircularProgressIndicator()),
              ),
            ),

          if (_restoredFromCache && !_loading && hasMc)
            Positioned(
              left: 16,
              right: 16,
              bottom: 104,
              child: _InfoPill(
                text:
                    'Mostrando ultimo risultato salvato. Tocca “Aggiorna” per ricalcolare da posizione attuale.',
              ),
            ),

          if (hasMc)
            Positioned(
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: FloatingActionButton.extended(
                      heroTag: 'refresh',
                      icon: const Icon(Icons.refresh),
                      label: const Text('Aggiorna'),
                      onPressed: _initFlow,
                    ),
                  ),
                  FloatingActionButton.extended(
                    heroTag: 'directions',
                    icon: const Icon(Icons.navigation),
                    label: const Text('Indicazioni'),
                    onPressed: () async {
                      final m = _markers.firstWhere((m) => m.markerId.value == 'mc');
                      await _openDirections(m.position);
                    },
                  ),
                ],
              ),
            ),

          if (!hasMc && !_loading)
            Positioned(
              right: 16,
              bottom: 24,
              child: FloatingActionButton.extended(
                icon: const Icon(Icons.refresh),
                label: const Text('Riprova'),
                onPressed: _initFlow,
              ),
            ),
        ],
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final String text;
  const _InfoPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      borderRadius: BorderRadius.circular(12),
      color: Colors.black.withValues(alpha: 0.75),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
