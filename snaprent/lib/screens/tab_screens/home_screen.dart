import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/core/mock_data.dart';
import 'package:snaprent/services/api_service.dart';
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

  String? selectedLocation;
  String? searchQuery;
  String? selectedPropertyType;
  String? maxRent;
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
  // ApiService is now accessed via ref.read(), no need to declare it here
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _scrollController = ScrollController()..addListener(_onScroll);
    _focusNode.addListener(() => setState(() {})); // update icon color

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
      // Correct Riverpod usage: read the provider
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
      // Correct Riverpod usage: read the provider
      final data = await ref
          .read(apiServiceProvider)
          .get('properties/search', filters);

      List<dynamic> fetchedProperties = [];
      if (data is List) {
        fetchedProperties = data;
        _totalPages = 1; // if backend returns list only
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

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),

          // Location dropdown + Filter icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.location_on, size: 16, color: Colors.indigo),
                  const SizedBox(width: 8),
                  DropdownButton<String?>(
                    value: selectedLocation,
                    underline: const SizedBox(),
                    onChanged: (newValue) {
                      setState(() => selectedLocation = newValue);
                      _refreshProperties();
                    },
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text('Select town'),
                      ),
                      ...towns.map(
                        (loc) => DropdownMenuItem(value: loc, child: Text(loc)),
                      ),
                    ],
                    menuMaxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.tune, color: Colors.indigo, size: 32),
                onPressed: () {
                  // open filter drawer logic here
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
