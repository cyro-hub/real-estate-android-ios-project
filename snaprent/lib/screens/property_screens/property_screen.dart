import 'package:flutter/material.dart';
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:snaprent/core/extensions.dart";
import "package:snaprent/widgets/btn_widgets/primary_btn.dart";
import "package:snaprent/widgets/error.dart";
import "package:snaprent/core/constant.dart";
import "package:snaprent/widgets/property_widgets/amenitie.dart";
import "package:snaprent/widgets/property_widgets/house_rule.dart";
import "package:snaprent/widgets/property_widgets/location_and_contact.dart";
import 'package:snaprent/services/api_service.dart';
import "package:snaprent/widgets/snack_bar.dart";
import 'package:cached_network_image/cached_network_image.dart';

class PropertyScreen extends ConsumerStatefulWidget {
  final String propertyId;
  const PropertyScreen({super.key, required this.propertyId});

  @override
  ConsumerState<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends ConsumerState<PropertyScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  Map<dynamic, dynamic>? propertyData;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    // ApiService no longer initialized here
    fetchProperty(widget.propertyId);
  }

  // Removed the context argument from this method
  Future<void> fetchProperty(String propertyId) async {
    try {
      // Correct Riverpod usage: read the provider inside the method
      final data = await ref.read(apiServiceProvider).get('/properties', {
        "_id": propertyId,
      });

      if (!mounted) return;

      setState(() {
        propertyData = data["data"];
        isLoading = false;
        errorMessage = null;
        _currentPage = 0;
      });
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(
        context,
        'Error fetching property: $e',
        success: false,
      );
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load property details. Please try again.';
      });
    }
  }

  // Removed the context argument from this method
  Future<void> fetchAndAppendDetails(String? propertyId) async {
    try {
      if (!mounted) return;

      await Future.delayed(const Duration(milliseconds: 300));
      final data = await ref.read(apiServiceProvider).get(
        '/properties/get-access',
        {"_id": propertyId!},
      );

      final newDetails = data["data"] as Map<String, dynamic>?;
      if (!mounted) return;

      setState(() {
        propertyData = {
          ...(propertyData ?? {}), // if null, use empty {}
          ...(newDetails ?? {}), // also guard newDetails
        };

        isLoading = false;
        errorMessage = null;
        _currentPage = 0;
      });
      SnackbarHelper.show(context, data['message'], success: data["success"]);
    } catch (e) {
      if (!mounted) return;
      SnackbarHelper.show(
        context,
        'Error getting property access',
        success: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (errorMessage != null) {
      return buildErrorScreen(errorMessage!, () {
        setState(() {
          isLoading = true;
          errorMessage = null;
        });
        fetchProperty(widget.propertyId);
      });
    }

    final images = List<String>.from(propertyData?['images'] ?? []);
    final amenities = propertyData?['amenities'] ?? {};
    final houseRules = propertyData?['houseRules'] ?? {};
    final rentAmount = propertyData?['rentAmount'] ?? 0;
    final currency = propertyData?['currency'] ?? '';
    final paymentFrequency = propertyData?['paymentFrequency'] ?? '';
    final description = propertyData?['description'] ?? '';
    final title = propertyData?['title'] ?? '';
    final propertyType = propertyData?['type'] ?? '';
    final roomSize = propertyData?['roomSize'] ?? '';

    return Scaffold(
      body: Stack(
        children: [
          // Full screen image carousel behind
          Positioned.fill(
            child: Stack(
              children: [
                PageView.builder(
                  controller: _pageController,
                  itemCount: images.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    return CachedNetworkImage(
                      imageUrl: images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 50),
                        ),
                      ),
                    );
                  },
                ),
                // Prev/Next arrows
                Positioned(
                  left: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        if (_currentPage > 0) {
                          _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: IconButton(
                      icon: const Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white,
                        size: 30,
                      ),
                      onPressed: () {
                        if (_currentPage < images.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        }
                      },
                    ),
                  ),
                ),
                // Dots indicator, raised above drawer
                Positioned(
                  bottom: 40,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      images.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 12 : 8,
                        height: _currentPage == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Colors.white
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Draggable Bottom Drawer
          DraggableScrollableSheet(
            initialChildSize: 0.32,
            minChildSize: 0.25,
            maxChildSize: 0.9,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, -3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[400],
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),

                      // Property Type badge & Price Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              propertyType,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          Text(
                            '$currency ${formatPrice(rentAmount)} / $paymentFrequency',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Title
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description
                      Text(
                        description,
                        style: const TextStyle(fontSize: 16, height: 1.4),
                      ),

                      const SizedBox(height: 20),

                      // Size and Rating (static rating here, you can replace)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.square_foot,
                                size: 20,
                                color: Colors.grey,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                roomSize,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                          Row(
                            children: const [
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Icon(Icons.star, color: Colors.amber, size: 20),
                              Icon(
                                Icons.star_half,
                                color: Colors.amber,
                                size: 20,
                              ),
                              Icon(
                                Icons.star_border,
                                color: Colors.amber,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              Text("3.5", style: TextStyle(fontSize: 16)),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Amenities Section
                      const Text(
                        "Amenities",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          if (amenities['kitchen'] != null)
                            AmenityItem(
                              icon: Icons.kitchen,
                              label:
                                  "${amenities['kitchen'].toString()} Kitchen",
                            ),
                          if (amenities['furnished'] == true)
                            const AmenityItem(
                              icon: Icons.chair,
                              label: 'Furnished',
                            ),
                          if (amenities['waterAvailable'] == true)
                            const AmenityItem(
                              icon: Icons.water,
                              label: 'Water',
                            ),
                          if (amenities['electricity'] == true)
                            const AmenityItem(
                              icon: Icons.electric_bolt,
                              label: 'Electricity',
                            ),
                          if (amenities['internet'] == true)
                            const AmenityItem(icon: Icons.wifi, label: 'Wi-Fi'),
                          if (amenities['parking'] == true)
                            const AmenityItem(
                              icon: Icons.local_parking,
                              label: 'Parking',
                            ),
                          if (amenities['balcony'] == true)
                            const AmenityItem(
                              icon: Icons.balcony,
                              label: 'Balcony',
                            ),
                          if (amenities['ceilingFan'] == true)
                            const AmenityItem(
                              icon: Icons.toys,
                              label: 'Ceiling Fan',
                            ),
                          if (amenities['tiledFloor'] == true)
                            const AmenityItem(
                              icon: Icons.grid_on,
                              label: 'Tiled Floor',
                            ),
                          if (amenities['toilet'] != null)
                            AmenityItem(
                              icon: Icons.wc,
                              label:
                                  '${amenities['toilet'].toString().capitalize()} Toilet',
                            ),
                          if (amenities['bathroom'] != null)
                            AmenityItem(
                              icon: Icons.bathtub,
                              label:
                                  '${amenities['bathroom'].toString().capitalize()} Bathroom',
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "HouseRules",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 16,
                        runSpacing: 12,
                        children: [
                          if (houseRules['smokingAllowed'] == true)
                            HouseRuleItem(label: "Smoking Allowed"),
                          if (houseRules['petsAllowed'] == true)
                            HouseRuleItem(label: "Pet Allowed"),
                          if (houseRules['visitorsAllowed'] == true)
                            HouseRuleItem(label: "Visitors Allowed"),
                          if (houseRules['quietHours'] != null)
                            HouseRuleItem(
                              label:
                                  'Quiet Hours ${houseRules['quietHours'].toString().capitalize()}',
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),
                      // Access Details Button
                      if (propertyData?['location'] == null ||
                          propertyData?['contact'] == null)
                        PrimaryBtn(
                          text: "Access Details",
                          onPressed: () {
                            fetchAndAppendDetails(propertyData?['_id']);
                          },
                        ),

                      const SizedBox(height: 20),

                      if (propertyData?['location'] != null &&
                          propertyData?['contact'] != null)
                        buildLocationAndContact(propertyData!),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
