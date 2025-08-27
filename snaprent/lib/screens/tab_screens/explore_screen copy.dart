import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:location/location.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/core/mock_data.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import '../property_screens/property_screen.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final Location _location = Location();

  final MapController _mapController = MapController();

  String? selectedPropertyType;

  // No longer needed
  // late ApiService api;

  // Default location (Cameroon)
  LatLng _currentLocation = const LatLng(4.0511, 9.7679);
  List<Marker> _propertyMarkers = [];
  bool _isSearching = false; // Loading overlay only when searching

  Timer? _debounce; // debounce for map panning
  LatLng?
  _lastFetchCenter; // store last fetched center to avoid fetching on zoom

  @override
  void initState() {
    super.initState();

    // Removed manual instantiation
    // api = ApiService(ref);

    // Load default properties immediately
    _searchProperties();

    // Try to get user location silently
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserLocationSilently();
    });
  }

  /// Try fetching user location silently; fallback to default without showing errors
  Future<void> _loadUserLocationSilently() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return; // fallback to default silently
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted)
          return; // fallback silently
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final userPos = LatLng(locationData.latitude!, locationData.longitude!);
        if (!mounted) return;

        // Move map to user location and fetch nearby properties
        setState(() {
          _currentLocation = userPos;
        });
        _mapController.move(userPos, 17);
        _searchProperties();
      }
    } catch (_) {
      // Ignore errors silently and continue with default
    }
  }

  Widget _propertyMarker(String id) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PropertyScreen(propertyId: id)),
        );
      },
      child: Image.asset(
        "assets/marker_icons/marker.png",
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.location_on, color: Colors.red),
      ),
    );
  }

  /// Called when user searches
  void _searchProperties([String? query, LatLng? center]) async {
    try {
      if (!mounted) return;
      setState(() => _isSearching = true);

      final targetLocation = center ?? _currentLocation;

      final Map<String, String> searchData = {
        "search": query ?? "",
        "propertyType": selectedPropertyType ?? "",
        "lon": targetLocation.longitude.toString(),
        "lat": targetLocation.latitude.toString(),
      };

      // Correct Riverpod usage: read the provider
      final response = await ref
          .read(apiServiceProvider)
          .get('properties/explore', searchData);

      if (!mounted) return;

      if (response != null && response['data'] != null) {
        final List properties = response['data'];

        setState(() {
          _propertyMarkers = properties.map((property) {
            final coords = property['location']['coordinates'];
            final lat = coords[1]; // API coordinates: [lon, lat]
            final lon = coords[0];

            return Marker(
              point: LatLng(lat, lon),
              width: 40,
              height: 40,
              child: _propertyMarker(property['_id']),
            );
          }).toList();

          _isSearching = false;
        });
      } else {
        setState(() => _isSearching = false);
        SnackbarHelper.show(context, "No properties found.", success: false);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSearching = false);
      SnackbarHelper.show(context, "Error: $e", success: false);
    }
  }

  double _distanceBetween(LatLng a, LatLng b) {
    final dx = a.latitude - b.latitude;
    final dy = a.longitude - b.longitude;
    return sqrt(dx * dx + dy * dy);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Map
          Positioned.fill(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                center: _currentLocation,
                zoom: 15,
                interactiveFlags: InteractiveFlag.all,
                onPositionChanged: (pos, hasGesture) {
                  if (hasGesture && pos.center != null) {
                    if (_lastFetchCenter == null ||
                        _distanceBetween(_lastFetchCenter!, pos.center!) >
                            0.0005) {
                      _debounce?.cancel();
                      _debounce = Timer(const Duration(milliseconds: 700), () {
                        _lastFetchCenter = pos.center!;
                        _searchProperties(null, pos.center); // pass map center
                      });
                    }
                  }
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.bongsco.app',
                ),
                MarkerLayer(markers: _propertyMarkers),
              ],
            ),
          ),

          // Green overlay
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.green.withOpacity(0.4)),
            ),
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 12,
            right: 12,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.6),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'Search property...',
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
                onSubmitted: (query) => _searchProperties(query),
              ),
            ),
          ),

          Positioned(
            top: MediaQuery.of(context).padding.top + 75,
            left: 12,
            right: 12,
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.6),
              child: SizedBox(
                height: 92,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: propertyTypes.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final type = propertyTypes[index];
                      final isSelected = selectedPropertyType == type["name"];

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedPropertyType = isSelected
                                ? null
                                : type["name"];
                          });
                          _searchProperties();
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.green
                                    : Colors.green[100],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                type["icon"],
                                color: isSelected ? Colors.white : Colors.green,
                                size: 28,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              capitalizeFirstLetter(type["name"]),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? Colors.indigo
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),

          // Loading overlay only when searching
          if (_isSearching)
            Positioned.fill(
              child: IgnorePointer(
                ignoring: false,
                child: Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
