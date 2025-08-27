import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/services/route_observer.dart';
import 'package:snaprent/widgets/safe_scaffold.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../widgets/property_widgets/access_property_card.dart';

class MyAccessScreen extends ConsumerStatefulWidget {
  const MyAccessScreen({super.key});

  @override
  ConsumerState<MyAccessScreen> createState() => _MyAccessScreenState();
}

class _MyAccessScreenState extends ConsumerState<MyAccessScreen>
    with RouteAware {
  int _index = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> properties = [];

  @override
  void initState() {
    super.initState();
    // Removed the manual ApiService initialization
    _fetchProperties();
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

  // RouteAware callbacks
  @override
  void didPush() => _fetchProperties(); // First time screen is pushed
  @override
  void didPopNext() => _fetchProperties(); // When returning from another screen

  Future<void> _fetchProperties() async {
    if (!mounted) return;
    setState(() => isLoading = true);
    try {
      // Correct Riverpod usage: read the provider inside the method
      final response = await ref
          .read(apiServiceProvider)
          .get('properties/token', {});

      if (!mounted) return;
      if (response != null && response['data'] != null) {
        final data = List<Map<String, dynamic>>.from(
          response['data'].map((p) {
            final expiresAt = DateTime.now().add(
              Duration(hours: (p['expiresIn'] as num).toInt()),
            );
            return {
              'propertyId': p['propertyId'],
              'tokenPackageId': p['tokenPackageId'].toString(),
              'title': p['title'],
              'image': p['image'],
              'rentAmount': p['rentAmount'],
              'currency': p['currency'] ?? 'FCFA',
              'landmark': p['landmark'],
              'town': p['town'],
              'expiresAt': expiresAt,
              'isExpired': p['isExpired'] ?? false,
            };
          }),
        );
        setState(() {
          properties = data;
          isLoading = false;
        });
      } else {
        setState(() {
          properties = [];
          isLoading = false;
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        properties = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
          ? const Center(child: Text('No properties found'))
          : RefreshIndicator(
              onRefresh: _fetchProperties,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: _buildStepper(),
              ),
            ),
    );
  }

  Stepper _buildStepper() {
    // Sort by expiry date
    final sorted = [...properties]
      ..sort(
        (a, b) =>
            (a['expiresAt'] as DateTime).compareTo(b['expiresAt'] as DateTime),
      );

    // Group by expiry string
    final Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var prop in sorted) {
      final key = prop['isExpired'] == true
          ? "Expired"
          : timeago.format(prop['expiresAt'], allowFromNow: true);
      grouped.putIfAbsent(key, () => []).add(prop);
    }

    return Stepper(
      physics: const ClampingScrollPhysics(),
      currentStep: _index,
      onStepTapped: (index) => setState(() => _index = index),
      controlsBuilder: (context, details) => const SizedBox.shrink(),
      steps: grouped.entries.map((entry) {
        final expiryText = entry.key;
        final props = entry.value;

        return Step(
          title: Text("Expires $expiryText"),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: props.map((prop) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: AccessPropertyCard(
                  propertyId: prop['propertyId'],
                  tokenPackageId: prop['tokenPackageId'],
                  title: prop['title'],
                  image: prop['image'],
                  rentAmount: prop['rentAmount'],
                  rentCurrency: prop['currency'],
                  expiresIn: prop['expiresAt'],
                ),
              );
            }).toList(),
          ),
        );
      }).toList(),
    );
  }
}
