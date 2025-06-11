import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class HomeView extends ConsumerWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),

      slivers: [
        // 🔝 AppBar con búsqueda
        SliverAppBar(
          pinned: false,
          floating: true,
          snap: true,

          elevation: 1,
          title: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Buscar productos...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: IconButton(
                        icon: const Icon(
                          PhosphorIconsRegular.camera,
                        ), // Puedes usar cualquier ícono
                        onPressed: () {
                          // Aquí puedes abrir un modal de filtros, por ejemplo
                        },
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 15,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(
                          color: const Color.fromARGB(255, 104, 103, 103),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {
                    // Acción cuando se presiona el ícono
                  },
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(2), // Área tocable
                        child: Icon(PhosphorIconsRegular.bell, size: 24),
                      ),
                      // Badge con número
                      Positioned(
                        right: 0,
                        top: -2,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(255, 199, 57, 47),
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: const Center(
                            child: Text(
                              '3', // Aquí pones el número que quieras mostrar
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: 10),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(100),
                  onTap: () {},
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Icon(PhosphorIconsRegular.mapPin, size: 24),
                  ),
                ),
              ),
            ],
          ),
        ),

        // 🧩 SliverList
        SliverList(
          delegate: SliverChildListDelegate.fixed([
            const SizedBox(height: 20),

            // 🎯 Banner principal
            _horizontalBanner(context),

            const SizedBox(height: 20),

            // 📂 Categorías
            _buildSectionTitle('Categorías'),
            _categoryList(),

            const SizedBox(height: 20),

            // 🆕 Nuevos productos
            _buildSectionTitle('Nuevas llegadas'),
            _productList(),

            const SizedBox(height: 20),

            // 📈 Tendencias
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tendencias',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Ver todo',
                    style: TextStyle(
                      color: colors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _trendingLooks(),
            const SizedBox(height: 10),
            _trendingLooks(),
            const SizedBox(height: 10),
            _trendingLooks(),
            const SizedBox(height: 10),
            _trendingLooks(),

            const SizedBox(height: 40),
          ]),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _horizontalBanner(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _bannerCard(
            context,
            title: 'Ofertas de la semana',
            color: colors.primary.withOpacity(0.8),
          ),
          const SizedBox(width: 10),
          _bannerCard(
            context,
            title: 'Colección destacada',
            color: Colors.pinkAccent.withOpacity(0.8),
          ),
        ],
      ),
    );
  }

  Widget _bannerCard(
    BuildContext context, {
    required String title,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _categoryList() {
    final categories = [
      {'icon': PhosphorIconsRegular.tShirt, 'label': 'Ropa'},
      {'icon': PhosphorIconsRegular.sneaker, 'label': 'Zapatillas'},
      {'icon': PhosphorIconsRegular.bag, 'label': 'Bolsos'},
      {'icon': PhosphorIconsRegular.coatHanger, 'label': 'Abrigos'},
      {'icon': PhosphorIconsRegular.island, 'label': 'Accesorios'},
    ];

    return SizedBox(
      height: 90,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          final item = categories[index];
          return Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                child: Icon(
                  item['icon'] as IconData,
                  size: 24,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['label'] as String,
                style: const TextStyle(fontSize: 12),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _productList() {
    final products = [
      {'title': 'Blusa negra', 'price': '\$29'},
      {'title': 'Chaqueta denim', 'price': '\$39'},
    ];

    return SizedBox(
      height: 210,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: products.length,
        separatorBuilder: (_, __) => const SizedBox(width: 15),
        itemBuilder: (_, index) {
          final item = products[index];
          return Container(
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  item['title']!,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item['price']!,
                  style: const TextStyle(
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _trendingLooks() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, index) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 130,
              color: Colors.grey.shade300,
              child: const Center(
                child: Icon(Icons.image, size: 50, color: Colors.grey),
              ),
            ),
          );
        },
      ),
    );
  }
}
