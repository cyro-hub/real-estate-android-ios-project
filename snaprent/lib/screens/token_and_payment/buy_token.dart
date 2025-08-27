import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snaprent/services/api_service.dart';
import 'package:snaprent/widgets/safe_scaffold.dart';
import 'package:snaprent/widgets/snack_bar.dart';

class BuyTokenScreen extends ConsumerStatefulWidget {
  const BuyTokenScreen({super.key});

  @override
  ConsumerState<BuyTokenScreen> createState() => _BuyTokenScreenState();
}

class _BuyTokenScreenState extends ConsumerState<BuyTokenScreen> {
  int quantity = 1; // Default quantity
  int hours = 24; // Default duration in hours
  double basePricePerToken = 250; // Price per 24h token
  bool isBuying = false;

  double get totalPrice {
    return (basePricePerToken * quantity) * (hours / 24);
  }

  DateTime get expiryTime {
    return DateTime.now().add(Duration(hours: hours));
  }

  Future<void> _buyToken() async {
    if (isBuying) return;

    setState(() {
      isBuying = true;
    });

    try {
      final tokenDetails = {"hours": hours, "quantity": quantity};

      // Use ref.read() to get the ApiService instance
      final api = ref.read(apiServiceProvider);
      final response = await api.post('token', tokenDetails);

      if (mounted) {
        if (response != null && response['success'] == true) {
          SnackbarHelper.show(
            context,
            response['message'] ?? "Token purchased successfully.",
          );
        } else {
          SnackbarHelper.show(
            context,
            response?['message'] ??
                "Failed to purchase token. Please try again.",
            success: false,
          );
        }
      }
    } catch (e) {
      if (mounted) {
        SnackbarHelper.show(context, "Error: $e", success: false);
      }
    } finally {
      if (mounted) {
        setState(() {
          isBuying = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeScaffold(
      child: Padding(
        padding: const EdgeInsets.all(0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Quantity',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.remove_circle_outline,
                            color: Colors.indigo,
                          ),
                          onPressed: isBuying
                              ? null
                              : () {
                                  if (quantity > 1) setState(() => quantity--);
                                },
                        ),
                        Text(
                          '$quantity',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: Colors.indigo,
                          ),
                          onPressed: isBuying
                              ? null
                              : () => setState(() => quantity++),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Duration Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Duration',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(Icons.timer, color: Colors.indigo),
                        Text(
                          '$hours hours',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.indigo,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.indigo,
                        inactiveTrackColor: Colors.indigo.shade100,
                        thumbColor: Colors.indigo,
                        overlayColor: Colors.indigo.withOpacity(0.2),
                        valueIndicatorColor: Colors.indigo,
                        valueIndicatorTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: Slider(
                        value: hours.toDouble(),
                        min: 24,
                        max: 168,
                        divisions: 7,
                        label: '$hours h',
                        onChanged: isBuying
                            ? null
                            : (value) => setState(() => hours = value.toInt()),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Total Price + Expiry Preview
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              color: Colors.indigo.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      'Total Price: ${totalPrice.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Expires at: ${DateFormat('dd MMM yyyy, hh:mm a').format(expiryTime)}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 40),
            // Buy Button
            ElevatedButton.icon(
              onPressed: isBuying ? null : _buyToken,
              icon: isBuying
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.shopping_cart),
              label: isBuying
                  ? const Text('Purchasing...', style: TextStyle(fontSize: 18))
                  : const Text('Buy Token', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
