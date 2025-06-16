import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    final categories = [
      {
        'icon': PhosphorIconsRegular.dress,
        'label': 'Lencería',
        'color': Colors.pinkAccent
      },
      {
        'icon': PhosphorIconsRegular.tShirt,
        'label': 'Verano',
        'color': Colors.orangeAccent
      },
      {
        'icon': PhosphorIconsRegular.coatHanger,
        'label': 'Invierno',
        'color': Colors.lightBlueAccent
      },
      {
        'icon': PhosphorIconsRegular.suitcaseSimple,
        'label': 'Formal',
        'color': Colors.grey
      },
      {
        'icon': PhosphorIconsRegular.heartbeat,
        'label': 'Deportiva',
        'color': Colors.lightGreen
      },
      {
        'icon': PhosphorIconsRegular.shirtFolded,
        'label': 'Casual',
        'color': Colors.deepPurpleAccent
      },
      {
        'icon': PhosphorIconsRegular.baby,
        'label': 'Infantil',
        'color': Colors.cyan
      },
      {
        'icon': PhosphorIconsRegular.swimmingPool,
        'label': 'Baño',
        'color': Colors.teal
      },
    ];

    return SizedBox(
      height: 120,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (_, index) {
          final item = categories[index];
          return GestureDetector(
            onTap: () {
              // Acción al seleccionar categoría
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeInOut,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  colors: [
                    (item['color'] as Color).withOpacity(0.2),
                    (item['color'] as Color).withOpacity(0.05),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (item['color'] as Color).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(2, 4),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    backgroundColor: (item['color'] as Color).withOpacity(0.9),
                    radius: 22,
                    child: Icon(
                      item['icon'] as IconData,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    item['label'] as String,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
