import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Helper function to launch phone or WhatsApp
Future<void> _launchContact(String type, String value) async {
  if (value.isEmpty) return;

  Uri uri;
  if (type == "phone") {
    uri = Uri(scheme: 'tel', path: value);
  } else if (type == "whatsapp") {
    uri = Uri.parse('https://wa.me/$value');
  } else {
    return;
  }

  if (!await launchUrl(uri)) {
    throw 'Could not launch $value';
  }
}

Widget buildLocationAndContact(Map<dynamic, dynamic> propertyData) {
  final location = propertyData['location'];
  final contact = propertyData['contact'];

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 24),
      const Text(
        "Location Details",
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 12),
      Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _locationRow(Icons.location_city, "Town", location['town']),
              _locationRow(Icons.apartment, "Quarter", location['quarter']),
              _locationRow(
                Icons.sports_score_outlined,
                "Street",
                location['street'],
              ),
              _locationRow(Icons.place, "Landmark", location['landmark']),
            ],
          ),
        ),
      ),

      const SizedBox(height: 12),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.userTie,
                          color: Colors.indigo,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Agent",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contact['agentName'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _launchContact("phone", contact['phone']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.phone,
                          color: Colors.indigo,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Phone",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contact['phone'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // WhatsApp row
              Material(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
                elevation: 2,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _launchContact("whatsapp", contact['whatsapp']),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 12,
                      horizontal: 16,
                    ),
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.whatsapp,
                          color: Colors.indigo,
                          size: 28,
                        ),
                        const SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "WhatsApp",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              contact['whatsapp'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
        ],
      ),
    ],
  );
}

Widget _locationRow(IconData icon, String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Icon(icon, color: Colors.indigo),
        const SizedBox(width: 10),
        Text("$label: ", style: const TextStyle(fontWeight: FontWeight.bold)),
        Flexible(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    ),
  );
}
