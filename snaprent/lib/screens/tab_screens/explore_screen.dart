import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/core/mock_data.dart';
import 'package:snaprent/screens/property_screens/property_screen.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/property_widgets/marker_property_widget.dart';
import 'package:snaprent/widgets/snack_bar.dart';

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final Location _location = Location();
  late GoogleMapController _mapController;
  String? selectedPropertyType;

  LatLng _currentLocation = const LatLng(4.0511, 9.7679);
  Set<Marker> _propertyMarkers = {};
  bool _isSearching = false;

  Timer? _debounce;
  LatLng? _lastFetchCenter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchProperties();
      _loadUserLocationSilently();
    });
  }

  /// Get user location
  Future<void> _loadUserLocationSilently() async {
    try {
      bool serviceEnabled = await _location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await _location.requestService();
        if (!serviceEnabled) return;
      }

      PermissionStatus permissionGranted = await _location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await _location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) return;
      }

      final locationData = await _location.getLocation();
      if (locationData.latitude != null && locationData.longitude != null) {
        final userPos = LatLng(locationData.latitude!, locationData.longitude!);
        if (!mounted) return;

        setState(() {
          _currentLocation = userPos;
        });

        _mapController.animateCamera(CameraUpdate.newLatLngZoom(userPos, 16));

        _searchProperties();
      }
    } catch (_) {}
  }

  Future<Marker> _propertyMarker(
    String id,
    String type,
    LatLng position,
  ) async {
    // Find the matching icon from your list
    final Map<String, dynamic> propertyType = propertyTypes.firstWhere(
      (item) => item["name"] == type,
      orElse: () => {"icon": Icons.help}, // A default icon if no match is found
    );

    final IconData iconData = propertyType["icon"];
    final BitmapDescriptor customIcon = await getCustomMarkerIcon(iconData);

    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: customIcon,
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => PropertyScreen(propertyId: id)),
        );
      },
    );
  }

  Future<void> _searchProperties([String? query, LatLng? center]) async {
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

        Set<Marker> newMarkers = {};

        for (var property in properties) {
          final coords = property['location']['coordinates'];
          final lat = coords[1];
          final lon = coords[0];

          Marker marker = await _propertyMarker(
            property['_id'],
            property['type'],
            LatLng(lat, lon),
          );
          newMarkers.add(marker);
        }

        setState(() {
          _propertyMarkers.clear();
          _propertyMarkers = newMarkers;
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
          // Google Map
          Positioned.fill(
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                target: _currentLocation,
                zoom: 15,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _propertyMarkers,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.hybrid,
              zoomControlsEnabled: false,
              tiltGesturesEnabled: false,
              rotateGesturesEnabled: false,
              onCameraIdle: () {
                if (_lastFetchCenter != null) {
                  _searchProperties(null, _lastFetchCenter);
                }
              },
              onCameraMove: (pos) {
                if (_lastFetchCenter == null ||
                    _distanceBetween(_lastFetchCenter!, pos.target) > 0.0005) {
                  _debounce?.cancel();
                  _debounce = Timer(const Duration(milliseconds: 700), () {
                    _lastFetchCenter = pos.target;
                  });
                }
              },
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child: Container(color: Colors.black.withOpacity(0.3)),
            ),
          ),
          Positioned(
            bottom: 130,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: const Color.fromARGB(187, 63, 81, 181),
              child: const Icon(Icons.my_location, color: Colors.white),
              onPressed: () {
                _mapController.animateCamera(
                  CameraUpdate.newLatLngZoom(_currentLocation, 16),
                );
              },
            ),
          ),

          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 16,
            left: 4,
            right: 4,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.5),
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

          // Property types
          Positioned(
            top: MediaQuery.of(context).padding.top + 75,
            left: 4,
            right: 4,
            child: Material(
              elevation: 1,
              borderRadius: BorderRadius.circular(12),
              color: Colors.white.withOpacity(0.5),
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
                                    ? Colors.indigo
                                    : const Color.fromARGB(86, 252, 252, 252),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                type["icon"],
                                color: isSelected
                                    ? Colors.white
                                    : Colors.indigo,
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

          // Loading overlay
          if (_isSearching)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
