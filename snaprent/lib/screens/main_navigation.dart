import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snaprent/screens/tab_screens/dashboard_screen.dart';
import 'package:snaprent/screens/tab_screens/favourite_screen.dart';

import '../widgets/custom_bottom_nav_bar.dart';
import 'tab_screens/home_screen.dart';
import 'tab_screens/explore_screen.dart';
import 'tab_screens/access_screen.dart';
import '../services/screen_guard.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  final List<GlobalKey<NavigatorState>> _navigatorKeys = List.generate(
    5,
    (_) => GlobalKey<NavigatorState>(),
  );

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> tabConfig = [
      {'screen': const HomeScreen(), 'private': false},
      {'screen': const ExploreScreen(), 'private': false},
      {'screen': const DashboardScreen(), 'private': true},
      {'screen': const MyAccessScreen(), 'private': true},
      {'screen': const FavouriteScreen(), 'private': false},
    ];

    final List<Widget> screens = tabConfig.map((tab) {
      if (tab['private'] == true) {
        return ScreenGuard(screen: tab['screen']);
      }
      return tab['screen'] as Widget;
    }).toList();

    return WillPopScope(
      onWillPop: () async {
        final isFirstRouteInCurrentTab = !await _navigatorKeys[_currentIndex]
            .currentState!
            .maybePop();

        if (!isFirstRouteInCurrentTab) return false;

        if (_currentIndex != 0) {
          setState(() => _currentIndex = 0);
          return false;
        }

        return true;
      },
      child: Scaffold(
        extendBody: true, // allows content to go behind bottom nav bar
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            IndexedStack(
              index: _currentIndex,
              children: List.generate(screens.length, (index) {
                return Navigator(
                  key: _navigatorKeys[index],
                  onGenerateRoute: (settings) {
                    return MaterialPageRoute(builder: (_) => screens[index]);
                  },
                );
              }),
            ),

            // Floating Bottom Nav
            Positioned(
              child: CustomBottomNavBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  if (index == _currentIndex) {
                    _navigatorKeys[index].currentState!.popUntil(
                      (route) => route.isFirst,
                    );
                  } else {
                    _navigatorKeys[_currentIndex].currentState!.popUntil(
                      (route) => route.isFirst,
                    );
                    setState(() => _currentIndex = index);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
