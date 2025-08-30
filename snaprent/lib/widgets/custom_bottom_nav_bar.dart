import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:snaprent/l10n/app_localizations.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SafeArea(
        top: false, // only care about bottom
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
              child: BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                currentIndex: currentIndex,
                onTap: onTap,
                type: BottomNavigationBarType.fixed,
                selectedItemColor: Theme.of(context).colorScheme.primary,
                unselectedItemColor: Colors.grey,
                showSelectedLabels: true,
                showUnselectedLabels: true,
                items: [
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.home),
                    label: '${l10n.home}',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.explore),
                    label: '${l10n.explore}',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.dashboard),
                    label: '${l10n.dashboard}',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.vpn_key),
                    label: '${l10n.access}',
                  ),
                  BottomNavigationBarItem(
                    icon: const Icon(Icons.favorite),
                    label: '${l10n.favourite}',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
