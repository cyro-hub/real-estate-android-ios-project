import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:snaprent/core/constant.dart';
import 'package:snaprent/screens/property_screens/property_screen.dart';

class AccessPropertyCard extends StatelessWidget {
  final String propertyId;
  final String title;
  final String image;
  final int rentAmount;
  final String rentCurrency;
  final DateTime expiresIn;
  final String tokenPackageId;

  const AccessPropertyCard({
    super.key,
    required this.propertyId,
    required this.title,
    required this.image,
    required this.rentAmount,
    required this.rentCurrency,
    required this.expiresIn,
    required this.tokenPackageId,
  });

  bool get isExpired => DateTime.now().isAfter(expiresIn);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Optimized network image with caching & placeholder
          CachedNetworkImage(
            imageUrl: image,
            height: 180,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              height: 180,
              color: Colors.grey[300],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              height: 180,
              color: Colors.grey[300],
              child: const Center(child: Icon(Icons.error)),
            ),
          ),

          // Gradient overlay for title & price
          if (!isExpired)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.black54, Colors.transparent],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shorten(title, maxLength: 20),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "$rentCurrency ${formatPrice(rentAmount)}",
                      style: const TextStyle(
                        color: Colors.green,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Overlay if expired
          // if (isExpired)
          //   Container(
          //     height: 180,
          //     color: Colors.black.withOpacity(0.6),
          //     alignment: Alignment.center,
          //     child: ElevatedButton(
          //       onPressed: () {
          //         Navigator.of(context).push(
          //           MaterialPageRoute(
          //             builder: (_) =>
          //                 TokenScreen(tokenPackageId: tokenPackageId),
          //           ),
          //         );
          //       },
          //       style: ElevatedButton.styleFrom(
          //         backgroundColor: Colors.indigo,
          //         foregroundColor: Colors.white,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(12),
          //         ),
          //         padding: const EdgeInsets.symmetric(
          //           horizontal: 16,
          //           vertical: 12,
          //         ),
          //       ),
          //       child: const Row(
          //         mainAxisSize: MainAxisSize.min,
          //         children: const [
          //           Icon(Icons.recycling),
          //           SizedBox(width: 8),
          //           Text("Renew Token"),
          //         ],
          //       ),
          //     ),
          //   ),

          // View button if not expired
          if (!isExpired)
            Container(
              height: 180,
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => PropertyScreen(propertyId: propertyId),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility),
                    SizedBox(width: 8),
                    Text("View"),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
