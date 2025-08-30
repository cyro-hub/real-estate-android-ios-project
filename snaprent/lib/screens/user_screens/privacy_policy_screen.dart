import 'package:flutter/material.dart';
import 'package:snaprent/widgets/user_widgets/privacy_policies_widget.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: const TermsAndPrivacyScreen(),
    );
  }
}

class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms & Privacy Policy")),
      body: buildPrivacyPoliciesWidget(context),
    );
  }
}
