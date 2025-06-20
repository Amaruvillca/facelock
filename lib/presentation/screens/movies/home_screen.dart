import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:facelock/presentation/views/home/home_screens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentPageIndex = 0;
 final PageController _pageController = PageController(initialPage: 0);

  final List<Widget> _pages = const [
    HomeView(),
    FavoritesView(),
    CartView(),
    ProfileView(),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const ScrollPhysics(),
        onPageChanged: (int index) {
          setState(() => currentPageIndex = index);
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(context),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return NavigationBar(
      height: 65,
      backgroundColor: colors.surface.withOpacity(0.95),
      indicatorColor: colors.primary.withOpacity(0.1),
      selectedIndex: currentPageIndex,
      animationDuration: const Duration(milliseconds: 300),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
          _pageController.jumpToPage(index);
        });
      },
      destinations: [
        _buildNavDestination(
          icon: PhosphorIconsBold.house,
          selectedIcon: PhosphorIconsFill.house,
          label: 'Inicio',
          colors: colors,
        ),
        _buildNavDestination(
          icon: PhosphorIconsBold.heart,
          selectedIcon: PhosphorIconsFill.heart,
          label: 'Favoritos',
          colors: colors,
          badge: true,
        ),
        _buildNavDestination(
          icon: PhosphorIconsBold.shoppingCartSimple,
          selectedIcon: PhosphorIconsFill.shoppingCartSimple,
          label: 'Carrito',
          colors: colors,
          badgeCount: 2,
        ),
        _buildNavDestination(
          icon: PhosphorIconsBold.user,
          selectedIcon: PhosphorIconsFill.user,
          label: 'Perfil',
          colors: colors,
        ),
      ],
    );
  }

  NavigationDestination _buildNavDestination({
    required IconData icon,
    required IconData selectedIcon,
    required String label,
    required ColorScheme colors,
    bool badge = false,
    int? badgeCount,
  }) {
    final inactiveColor = colors.onSurface.withOpacity(0.5);
    final activeColor = colors.primary;

    return NavigationDestination(
      selectedIcon: Icon(selectedIcon, color: activeColor, size: 24),
      icon: badgeCount != null
          ? Badge(
              label: Text(badgeCount.toString()),
              backgroundColor: colors.error,
              textColor: colors.onError,
              child: Icon(icon, color: inactiveColor, size: 24),
            )
          : badge
              ? Badge(
                  smallSize: 0,
                  backgroundColor: activeColor,
                  child: Icon(icon, color: inactiveColor, size: 24),
                )
              : Icon(icon, color: inactiveColor, size: 24),
      label: label,
    );
  }
}
