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
  final PageController _pageController = PageController();

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
          setState(() {
            currentPageIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildBottomNavBar() {
    return NavigationBar(
      onDestinationSelected: (int index) {
        setState(() {
          currentPageIndex = index;
          _pageController.jumpToPage(index);
        });
      },
      backgroundColor: Colors.white,
      indicatorColor: Colors.deepPurple.withOpacity(0.2),
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      selectedIndex: currentPageIndex,
      animationDuration: const Duration(milliseconds: 800),
      destinations: const [
        NavigationDestination(
          selectedIcon: Icon(PhosphorIconsBold.house, color: Colors.deepPurple),
          icon: Icon(PhosphorIconsRegular.house, color: Colors.grey),
          label: 'Inicio',
        ),
        NavigationDestination(
          selectedIcon: Icon(PhosphorIconsBold.heart, color: Colors.deepPurple),
          icon: Badge(
            smallSize: 8,
            child: Icon(PhosphorIconsRegular.heart, color: Colors.grey),
          ),
          label: 'Favoritos',
        ),
        NavigationDestination(
          selectedIcon: Icon(PhosphorIconsBold.shoppingCartSimple, color: Colors.deepPurple),
          icon: Badge(
            label: Text('2'),
            child: Icon(PhosphorIconsRegular.shoppingCartSimple, color: Colors.grey),
          ),
          label: 'Carrito',
        ),
        NavigationDestination(
          selectedIcon: Icon(PhosphorIconsBold.user, color: Colors.deepPurple),
          icon: Icon(PhosphorIconsRegular.user, color: Colors.grey),
          label: 'Perfil',
        ),
      ],
    );
  }
}