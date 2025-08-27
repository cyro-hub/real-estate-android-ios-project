import 'package:flutter/material.dart';

class SafeScaffold extends StatelessWidget {
  final Widget child;
  final PreferredSizeWidget? appBar;

  const SafeScaffold({super.key, required this.child, this.appBar});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: false,
      appBar: appBar,
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        left: true,
        right: true,
        bottom: true, // respects bottom safe area
        top: true, // respects top safe area
        minimum: const EdgeInsets.only(
          left: 8.0,
          right: 8.0,
          top: 8.0,
          bottom: 114.0, // leave 100px space at bottom
        ),
        child: child,
      ),
    );
  }
}
