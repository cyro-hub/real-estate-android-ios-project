import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/core/mock_data.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/safe_scaffold.dart';
import 'package:snaprent/widgets/snack_bar.dart';
import 'package:shimmer/shimmer.dart';

class UsersPropertiesScreen extends ConsumerStatefulWidget {
  const UsersPropertiesScreen({super.key});

  @override
  ConsumerState<UsersPropertiesScreen> createState() =>
      _UsersPropertiesScreenState();
}

class _UsersPropertiesScreenState extends ConsumerState<UsersPropertiesScreen> {
  bool isLoading = false;
  bool isFetchingMore = false;
  int page = 1;
  int totalPages = 1; // track total pages from backend
  final int limit = 10;

  List<Map<String, dynamic>> properties = [];

  final List<Map<String, String>> statusFilters = [
    {"name": "All", "value": ""},
    {"name": "Active", "value": "true"},
    {"name": "Inactive", "value": "false"},
  ];

  String? selectedDate; // stores filter name
  String selectedStatus = "All"; // stores filter name
  String? selectedPropertyType;

  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchProperties(page: 1);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll to bottom to fetch more
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        !isFetchingMore &&
        !isLoading &&
        page < totalPages) {
      _fetchProperties(page: page + 1);
    }
  }

  Future<void> _refreshProperties() async {
    page = 1;
    totalPages = 1; // reset total pages on refresh
    properties.clear();
    await _fetchProperties(page: 1);
  }

  Future<void> _fetchProperties({required int page}) async {
    if (!mounted) return;

    if (page == 1) {
      setState(() => isLoading = true);
    } else {
      setState(() => isFetchingMore = true);
    }

    try {
      final selectedCreatedAtFilter = createdAtFilterList.firstWhere(
        (filter) => filter["name"] == selectedDate,
        orElse: () => {"from": "", "to": ""},
      );

      final selectedStatusFilter = statusFilters.firstWhere(
        (filter) => filter["name"] == selectedStatus,
        orElse: () => {"value": ""},
      );

      String from = selectedCreatedAtFilter["from"].toString();
      String to = selectedCreatedAtFilter["to"].toString();
      String status = selectedStatusFilter["value"] ?? "";

      final Map<String, String> filter = {
        "to": to,
        "from": from,
        "status": status,
        "limit": limit.toString(),
        "page": page.toString(),
        "type": selectedPropertyType ?? "",
      };

      // Use ref.read to get the ApiService instance
      final api = ref.read(apiServiceProvider);
      final data = await api.get('properties/owner', filter);

      if (!mounted) return;

      List<dynamic> fetchedProperties = [];
      if (data is List) {
        fetchedProperties = data;
        totalPages = 1; // fallback if backend doesn't return meta
      } else if (data is Map<String, dynamic> && data['data'] is List) {
        fetchedProperties = data['data'];
        totalPages = data['meta']?['totalPages'] ?? 1;
      }

      setState(() {
        if (page == 1) {
          properties = List<Map<String, dynamic>>.from(fetchedProperties);
        } else {
          properties.addAll(List<Map<String, dynamic>>.from(fetchedProperties));
        }
        this.page = page;
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
        isLoading = false;
        isFetchingMore = false;
      });
    }
  }

  Future<void> _updateProperty(Map<String, dynamic> property) async {
    // Navigate to update property screen
  }

  Widget _buildShimmerPropertyCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 150, height: 18, color: Colors.grey[300]),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: 80, height: 24, color: Colors.grey[300]),
                      Container(
                        width: 100,
                        height: 36,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filters Row
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                // Date filter
                Icon(Icons.date_range, size: 16, color: Colors.indigo),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: selectedDate,
                  hint: const Text("Select Date"),
                  underline: const SizedBox(),
                  onChanged: (newValue) {
                    setState(() => selectedDate = newValue);
                    _refreshProperties();
                  },
                  items: createdAtFilterList.map((filter) {
                    return DropdownMenuItem<String?>(
                      value: filter['name'],
                      child: Text(filter['name'].toString()),
                    );
                  }).toList(),
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                const SizedBox(width: 24),
                // Status filter
                Icon(Icons.check_circle, size: 16, color: Colors.indigo),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: selectedStatus,
                  underline: const SizedBox(),
                  onChanged: (newValue) {
                    setState(() => selectedStatus = newValue.toString());
                    _refreshProperties();
                  },
                  items: statusFilters.map((filter) {
                    return DropdownMenuItem<String?>(
                      value: filter['name'],
                      child: Text(filter['name'].toString()),
                    );
                  }).toList(),
                  menuMaxHeight: MediaQuery.of(context).size.height * 0.7,
                ),
              ],
            ),
          ),

          // Property types horizontal scroll
          SizedBox(
            height: 80,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
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
                        selectedPropertyType = isSelected ? null : type["name"];
                      });
                      _refreshProperties();
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
          ),

          // Properties list with pull-to-refresh and infinite scroll
          Expanded(
            child: isLoading && properties.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _refreshProperties,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: properties.length + (isFetchingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index < properties.length) {
                          return _buildPropertyCard(properties[index]);
                        } else {
                          return _buildShimmerPropertyCard();
                        }
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shadowColor: Colors.grey.shade300,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: property['image'] != null
                ? Image.network(
                    property['image'],
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  )
                : Container(
                    height: 180,
                    width: double.infinity,
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.home, size: 60, color: Colors.grey),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property['title'] ?? 'Untitled Property',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton.icon(
                      onPressed: () => {},
                      icon: Icon(
                        property['status'] ?? false
                            ? Icons.check_circle
                            : Icons.cancel,
                        color: property['status'] ?? false
                            ? Colors.green
                            : Colors.red,
                      ),
                      label: Text(
                        property['status'] ?? false ? "Active" : "Inactive",
                        style: TextStyle(
                          color: property['status'] ?? false
                              ? Colors.green
                              : Colors.red,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _updateProperty(property),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.edit, size: 16, color: Colors.white),
                          SizedBox(width: 8),
                          Text("Update", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
