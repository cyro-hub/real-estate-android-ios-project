import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/core/mock_data.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/filter_drawer.dart';
import 'package:snaprent/widgets/setting_drawer_widget.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import '../../widgets/safe_scaffold.dart';
import 'package:snaprent/widgets/property_widgets/property_card.dart';
import 'package:shimmer/shimmer.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<String> towns = defaultTowns;
  List<Map<String, dynamic>> properties = [];

  String? searchQuery;
  String? selectedLocation;
  String? selectedPropertyType;
  double? maxRent;
  String? paymentFrequency;
  String? toilet;
  String? bathroom;
  String? kitchen;
  bool? waterAvailable;
  bool? electricity;
  bool? parking;

  bool _isLoading = false;
  bool _isFetchingMore = false;
  int _page = 1;
  int _totalPages = 1;
  final int _limit = 10;

  late FocusNode _focusNode;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_onScroll);
    _focusNode.addListener(() => setState(() {}));

    fetchTowns();
    _fetchProperties(page: 1);
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !_isFetchingMore &&
        !_isLoading &&
        _page < _totalPages) {
      _fetchProperties(page: _page + 1);
    }
  }

  Map<String, String> buildQueryParameters({int? page}) {
    final Map<String, String> queryParams = {};

    void addIfNotEmpty(String key, dynamic value) {
      if (value == null) return;
      if (value is String && value.trim().isEmpty) return;
      if (value is bool) {
        if (value == false) return;
        queryParams[key] = value.toString();
        return;
      }
      if (value is double) {
        if (value == 0) return;
        queryParams[key] = value.toInt().toString();
        return;
      }
      queryParams[key] = value.toString();
    }

    addIfNotEmpty('location', selectedLocation);
    addIfNotEmpty('search', searchQuery);
    addIfNotEmpty('type', selectedPropertyType);
    addIfNotEmpty('maxRent', maxRent);
    addIfNotEmpty('paymentFrequency', paymentFrequency);
    addIfNotEmpty('toilet', toilet);
    addIfNotEmpty('bathroom', bathroom);
    addIfNotEmpty('kitchen', kitchen);
    addIfNotEmpty('waterAvailable', waterAvailable);
    addIfNotEmpty('electricity', electricity);
    addIfNotEmpty('parking', parking);
    addIfNotEmpty('limit', _limit);
    if (page != null) addIfNotEmpty('page', page);

    return queryParams;
  }

  Future<void> fetchTowns() async {
    final prefs = await SharedPreferences.getInstance();
    final lastFetch = prefs.getInt('towns_last_fetch') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    const twoDays = 24 * 60 * 60 * 1000;

    if (prefs.containsKey('towns') && now - lastFetch < twoDays) {
      final cachedTowns = prefs.getStringList('towns');
      if (cachedTowns != null) {
        if (!mounted) return;
        setState(() => towns = cachedTowns);
        return;
      }
    }

    try {
      final data = await ref.read(apiServiceProvider).get('properties/town');
      if (!mounted) return;
      setState(() => towns = List<String>.from(data["data"]));
      await prefs.setStringList('towns', towns);
      await prefs.setInt('towns_last_fetch', now);
    } catch (e) {
      if (!mounted) return;
      setState(() => towns = defaultTowns);
    }
  }

  Future<void> _refreshProperties() async {
    _page = 1;
    properties.clear();
    await _fetchProperties(page: 1);
  }

  Future<void> _fetchProperties({required int page}) async {
    if (page == 1) {
      setState(() => _isLoading = true);
    } else {
      setState(() => _isFetchingMore = true);
    }

    try {
      final filters = buildQueryParameters(page: page);
      final data = await ref
          .read(apiServiceProvider)
          .get('properties/search', filters);

      List<dynamic> fetchedProperties = [];
      if (data is List) {
        fetchedProperties = data;
        _totalPages = 1;
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        fetchedProperties = data['data'];
        _totalPages = data['meta']?['totalPages'] ?? 1;
      }

      if (!mounted) return;
      setState(() {
        if (page == 1) {
          properties = List<Map<String, dynamic>>.from(fetchedProperties);
        } else {
          properties.addAll(List<Map<String, dynamic>>.from(fetchedProperties));
        }
        _page = page;
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(
        context,
        'Error fetching properties: $e',
        success: false,
      );
    } finally {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _isFetchingMore = false;
      });
    }
  }

  void _showFilterDrawer() async {
    final results = await showGeneralDialog(
      context: context,
      barrierLabel: "Filter Drawer",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.4),
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, __, ___) {
        final double screenHeight = MediaQuery.of(context).size.height;
        final double screenWidth = MediaQuery.of(context).size.width;

        return Align(
          alignment: Alignment
              .bottomCenter, // Align to bottom-center for bottom-up slide
          child: Material(
            type: MaterialType.transparency,
            child: Container(
              width: screenWidth, // Full screen width
              height: screenHeight,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(0), // No border radius
                  topRight: Radius.circular(0), // No border radius
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: FilterDrawer(
                towns: towns,
                initialSelectedLocation: selectedLocation,
                initialMaxRent: maxRent,
                initialPaymentFrequency: paymentFrequency,
                initialToilet: toilet,
                initialBathroom: bathroom,
                initialKitchen: kitchen,
                initialWaterAvailable: waterAvailable,
                initialElectricity: electricity,
                initialParking: parking,
              ),
            ),
          ),
        );
      },
      transitionBuilder: (_, animation, __, child) {
        return SlideTransition(
          position: Tween(
            begin: const Offset(0, 1), // Start from off-screen bottom
            end: Offset.zero, // End at its normal position
          ).animate(animation),
          child: child,
        );
      },
    );

    if (results != null) {
      final filterResults = results as Map<String, dynamic>;

      // print('Filter Results: $filterResults');
      setState(() {
        selectedLocation = filterResults['location'];
        maxRent = filterResults['maxRent'];
        paymentFrequency = filterResults['paymentFrequency'];
        toilet = filterResults['toilet'];
        bathroom = filterResults['bathroom'];
        kitchen = filterResults['kitchen'];
        waterAvailable = filterResults['waterAvailable'];
        electricity = filterResults['electricity'];
        parking = filterResults['parking'];
      });
      _refreshProperties();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                borderRadius: BorderRadius.circular(
                  8,
                ), // optional rounded ripple
                onTap: _showFilterDrawer, // Calls the new filter drawer
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.indigo,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      selectedLocation ?? 'Select town',
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 28,
                      color: Colors.indigo,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings,
                  color: Colors.indigo,
                  size: 28,
                ),
                onPressed: () {
                  showSettingsDrawer(context, ref); // Calls the settings drawer
                },
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Search box
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              focusNode: _focusNode,
              decoration: InputDecoration(
                hintText: 'Search properties...',
                prefixIcon: Icon(
                  Icons.search,
                  color: _focusNode.hasFocus ? Colors.blue : Colors.grey,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 10,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => searchQuery = value,
              onSubmitted: (_) => _refreshProperties(),
            ),
          ),

          const SizedBox(height: 12),

          // Property Type Horizontal Scroll
          SizedBox(
            height: 80,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: propertyTypes.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final type = propertyTypes[index];
                final isSelected = selectedPropertyType == type["name"];
                return GestureDetector(
                  onTap: () {
                    setState(
                      () => selectedPropertyType = isSelected
                          ? null
                          : type["name"],
                    );
                    _refreshProperties();
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.indigo
                              : Colors.indigo[100],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          type["icon"],
                          color: isSelected ? Colors.white : Colors.indigo,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        capitalizeFirstLetter(type["name"]),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.indigo : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 1),

          // Properties list with pull-to-refresh & infinite scroll
          Expanded(
            child: _isLoading && properties.isEmpty
                ? ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => Container(
                      width: double.infinity,
                      margin: const EdgeInsets.all(4),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 380,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _refreshProperties,
                    child: ListView.builder(
                      controller: _scrollController,
                      itemCount: properties.length + (_isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < properties.length) {
                          final property = properties[index];
                          return PropertyCard(
                            image:
                                (property['images'] != null &&
                                    property['images'] is List &&
                                    (property['images'] as List).isNotEmpty)
                                ? property['images'][0] ?? ''
                                : '',
                            type: property['type'] ?? '',
                            rentAmount: property['rentAmount'] ?? 0,
                            size: property['size']?.toString() ?? '',
                            title: property['title'] ?? '',
                            currency: property['currency'] ?? '',
                            paymentFrequency:
                                property['paymentFrequency'] ?? '',
                            description: property['description'] ?? '',
                            rating: (property['rating'] is num)
                                ? property['rating'].toDouble()
                                : 0.0,
                            propertyId: property['_id'] ?? '',
                            hasAccess: property['hasAccess'] ?? false,
                          );
                        } else {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
