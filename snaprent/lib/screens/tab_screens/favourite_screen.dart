import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/services/route_observer.dart';
import 'package:snaprent/widgets/safe_scaffold.dart';

class FavouriteScreen extends ConsumerStatefulWidget {
  const FavouriteScreen({super.key});

  @override
  ConsumerState<FavouriteScreen> createState() => _FavouriteScreenState();
}

class _FavouriteScreenState extends ConsumerState<FavouriteScreen>
    with RouteAware {
  List<Map<String, dynamic>> favouriteProperties = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => _loadFavorites();
  @override
  void didPopNext() => _loadFavorites();

  Future<void> _loadFavorites() async {
    if (!mounted) return;
    setState(() => isLoading = true);

    final prefs = await SharedPreferences.getInstance();
    final favIds = prefs.getStringList('favoriteProperties') ?? [];

    if (favIds.isEmpty) {
      if (mounted) {
        setState(() {
          favouriteProperties = [];
          isLoading = false;
        });
      }
      return;
    }

    try {
      final data = await ref.read(apiServiceProvider).post(
        'properties/favourite',
        {'favIds': favIds},
        context,
      );

      if (mounted) {
        setState(() {
          favouriteProperties = List<Map<String, dynamic>>.from(data["data"]);
          isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  Future<void> _toggleFavorite(String propertyId) async {
    final prefs = await SharedPreferences.getInstance();
    final favList = prefs.getStringList('favoriteProperties') ?? [];

    if (favList.contains(propertyId)) {
      favList.remove(propertyId);
    }

    await prefs.setStringList('favoriteProperties', favList);

    if (mounted) {
      setState(
        () => favouriteProperties.removeWhere(
          (prop) => prop["_id"] == propertyId,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      // The RefreshIndicator should wrap the entire scrollable content
      child: RefreshIndicator(
        onRefresh: _loadFavorites,
        child: SingleChildScrollView(
          // Ensures the refresh gesture is always available
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            children: [
              if (isLoading)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: const Center(child: CircularProgressIndicator()),
                )
              else if (favouriteProperties.isEmpty)
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.75,
                  child: const Center(
                    child: Text(
                      "No favourites yet 🤔",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: favouriteProperties.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.75,
                        ),
                    itemBuilder: (context, index) {
                      final property = favouriteProperties[index];
                      final image =
                          property["image"] ??
                          "https://via.placeholder.com/150";
                      final title = property["title"] ?? "";
                      final town = property["town"] ?? "";
                      final quarter = property["quarter"] ?? "";
                      final price = property["rentAmount"] ?? 0;
                      final currency = property["currency"] ?? "FCFA";
                      final frequency =
                          property["paymentFrequency"] ?? "monthly";
                      final propertyId = property["_id"];

                      return GestureDetector(
                        onTap: () {
                          // Navigate to property detail page
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          elevation: 4,
                          clipBehavior: Clip.hardEdge,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Stack(
                                  children: [
                                    Positioned.fill(
                                      child: CachedNetworkImage(
                                        imageUrl: image,
                                        fit: BoxFit.cover,
                                        placeholder: (context, url) =>
                                            Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              ),
                                            ),
                                        errorWidget: (context, url, error) =>
                                            Container(
                                              color: Colors.grey[300],
                                              child: const Center(
                                                child: Icon(Icons.error),
                                              ),
                                            ),
                                      ),
                                    ),
                                    Positioned(
                                      top: 8,
                                      right: 8,
                                      child: GestureDetector(
                                        onTap: () =>
                                            _toggleFavorite(propertyId),
                                        child: Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.black45,
                                            shape: BoxShape.circle,
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.black45,
                                                blurRadius: 6,
                                                offset: Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(
                                            Icons.favorite,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      title,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$town • $quarter",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "${formatPrice(price)} $currency / $frequency",
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
