import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snaprent/screens/main_navigation.dart';
import 'package:snaprent/screens/user_screens/privacy_policy_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _iconAnimController;
  late AnimationController _textAnimController;
  late Animation<Offset> _iconSlideAnimation;
  late Animation<double> _textFadeAnimation;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Welcome',
      'desc': 'Find properties in your area easily!',
      'illustration': "assets/swipe.png",
    },
    {
      'title': 'Search',
      'desc': 'Powerful search to find what you want.',
      'illustration': "assets/search-engine.png",
    },
    {
      'title': 'Start Now',
      'desc': 'Begin your journey today!',
      'illustration': "assets/maker-launch.png",
    },
    {'title': 'Terms and Conditions'},
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
  }

  void _initAnimations() {
    _iconAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _textAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _iconSlideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _iconAnimController, curve: Curves.easeOut),
        );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textAnimController, curve: Curves.easeIn),
    );

    _startAnimations();
  }

  void _startAnimations() {
    _iconAnimController.forward(from: 0.0);
    _textAnimController.forward(from: 0.0);
  }

  @override
  void dispose() {
    _iconAnimController.dispose();
    _textAnimController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
    _startAnimations();
  }

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seenOnboarding', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (index) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 10,
          width: _currentPage == index ? 24 : 10,
          decoration: BoxDecoration(
            color: _currentPage == index ? Colors.indigo : Colors.grey,
            borderRadius: BorderRadius.circular(10),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLast = _currentPage == _pages.length - 1;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: [
          if (!isLast)
            TextButton(
              onPressed: _completeOnboarding,
              child: const Text('Skip'),
            )
          else
            Container(), // or SizedBox.shrink() if you want an empty placeholder
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: _onPageChanged,
              itemBuilder: (context, index) {
                final page = _pages[index];

                // If last page is Terms and Conditions
                if (page['title'] == 'Terms and Conditions') {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Terms and Conditions",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: SingleChildScrollView(
                            child: TermsAndPrivacyScreen(),
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // For normal onboarding pages
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SlideTransition(
                        position: _iconSlideAnimation,
                        child: Image.asset(page['illustration']),
                      ),
                      const SizedBox(height: 30),
                      AnimatedBuilder(
                        animation: _textFadeAnimation,
                        builder: (context, child) => Opacity(
                          opacity: _textFadeAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                page['title'],
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                page['desc'],
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildDots(),
          const SizedBox(height: 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: ElevatedButton(
              onPressed: isLast
                  ? _completeOnboarding
                  : () => _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.ease,
                    ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: Text(isLast ? 'Get Started' : 'Next'),
            ),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }
}
