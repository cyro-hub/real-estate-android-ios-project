import 'package:flutter/material.dart';

Widget buildPrivacyPoliciesWidget(BuildContext context) {
  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildSection(
          title: "1. Introduction",
          content:
              "Welcome to SnapRent! These terms and privacy policies explain how we manage your personal information and govern your use of our app and services.",
        ),
        buildSection(
          title: "2. Information We Collect",
          content:
              "We may collect your name, email, phone number, property listings, booking history, and payment information to provide our services effectively. We may also collect usage data for analytics purposes.",
        ),
        buildSection(
          title: "3. How We Use Your Information",
          content:
              "Your data helps us process bookings, manage property listings, communicate updates, improve app features, and prevent fraudulent activities. Payment info is securely processed through trusted providers.",
        ),
        buildSection(
          title: "4. User Accounts & Property Listings",
          content:
              "Users can create accounts to list properties, make bookings, and manage rentals. You are responsible for the accuracy of your property details and compliance with local rental regulations.",
        ),
        buildSection(
          title: "5. Third-Party Services",
          content:
              "We may share your data with payment gateways, analytics providers, and trusted partners who assist us in operating the SnapRent platform.",
        ),
        buildSection(
          title: "6. Your Rights",
          content:
              "You can access, update, or delete your account information. You may also request deletion of your listings or data by contacting support@snaprent.com.",
        ),
        buildSection(
          title: "7. Data Security",
          content:
              "We implement industry-standard security measures to protect your data, including encryption and secure storage. However, no system is entirely foolproof.",
        ),
        buildSection(
          title: "8. Cookies and Tracking",
          content:
              "SnapRent uses cookies to enhance your browsing experience, remember preferences, and analyze usage. You may disable cookies in your device settings, but some features may be limited.",
        ),
        buildSection(
          title: "9. User Conduct",
          content:
              "Users must not post fraudulent listings, harass other users, or engage in illegal activity through SnapRent. Violations may result in account suspension or removal.",
        ),
        buildSection(
          title: "10. Changes to Terms and Privacy Policy",
          content:
              "We may update these terms and policies periodically. Notifications will be posted in-app. Continued use of SnapRent constitutes acceptance of any changes.",
        ),
        buildSection(
          title: "11. Contact Us",
          content:
              "For questions, concerns, or data requests, reach out to us at support@snaprent.com. Our team will respond promptly to address your inquiries.",
        ),
        const SizedBox(height: 100),
      ],
    ),
  );
}

Widget buildSection({required String title, required String content}) {
  return Card(
    margin: const EdgeInsets.symmetric(vertical: 8),
    elevation: 2,
    shadowColor: Colors.grey.shade300,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
            ),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    ),
  );
}
