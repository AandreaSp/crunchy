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
      final result = await _searchNearby(user);
      final target = result.nearestMcDonalds ?? result.nearestAny ?? user;

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
    return perm == LocationPermission.always ||
        perm == LocationPermission.whileInUse;
  }

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

    try {
      final res = await http.post(url, headers: headers, body: jsonEncode(body));
      if (res.statusCode != 200) {
        return const _NearbyResult();
      }

      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final raw = (data['places'] as List?) ?? const [];
      final places = raw.cast<Map<String, dynamic>>();

      LatLng? nearestAny;
      if (places.isNotEmpty) {
        final loc = places.first['location'] as Map<String, dynamic>;
        nearestAny = LatLng(
          (loc['latitude'] as num).toDouble(),
          (loc['longitude'] as num).toDouble(),
        );
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
    } catch (_) {
      return const _NearbyResult();
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