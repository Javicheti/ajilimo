import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/menu_repository.dart';
import '../domain/menu_item.dart';

class MenuPage extends ConsumerStatefulWidget {
  const MenuPage({super.key});

  @override
  ConsumerState<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends ConsumerState<MenuPage> {
  late List<MenuCategory> _categories;
  int _tab = 0;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _categories = ref.read(menuRepositoryProvider).seed();
    _loadRemote();
  }

  Future<void> _loadRemote() async {
    try {
      final List<Map<String, dynamic>> menus = await ref.read(apiClientProvider).getMenu();
      if (!mounted || menus.isEmpty) return;
      final List<Map<String, dynamic>> items =
          (menus.first['items'] as List<dynamic>).cast<Map<String, dynamic>>();
      final List<MenuProduct> products = items
          .map(
            (it) => MenuProduct(
              id: (it['id'] ?? '').toString(),
              name: (it['title'] ?? '').toString(),
              description: '',
              price: ((it['price'] as num?) ?? 0).toDouble(),
              available: it['isAvailable'] == true,
            ),
          )
          .where((p) => p.name.isNotEmpty)
          .toList();
      if (products.isEmpty) return;
      setState(() => _categories = <MenuCategory>[MenuCategory(name: 'Carta (Rappi)', products: products)]);
    } catch (_) {
      // Sin bridge: se mantienen datos locales.
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        Row(
          children: <Widget>[
            Text('Tu Menú', style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(width: Spacing.sm),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
              decoration: BoxDecoration(color: c.textStrong, borderRadius: BorderRadius.circular(Radii.pill)),
              child: const Text('Maestro', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
            ),
            const SizedBox(width: Spacing.lg),
            Expanded(
              child: TextField(
                onChanged: (v) => setState(() => _query = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search, size: 20),
                  hintText: 'Buscar producto…',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: Spacing.sm),
            OutlinedButton.icon(
              onPressed: () => _toast('Actualizando menú con IA…'),
              icon: const Icon(Icons.auto_awesome_outlined, size: 16),
              label: const Text('Actualizar menú con IA'),
            ),
            const SizedBox(width: Spacing.sm),
            FilledButton.icon(
              onPressed: () => _toast('Agregar producto'),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Agregar'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        _Tabs(index: _tab, onChanged: (i) => setState(() => _tab = i)),
        const SizedBox(height: Spacing.lg),
        if (_tab == 0) ...<Widget>[
          Text('Optimiza tu menú para aumentar tus ventas.', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: Spacing.sm),
          Wrap(
            spacing: Spacing.sm,
            runSpacing: Spacing.sm,
            children: const <Widget>[
              _Chip(icon: Icons.check_circle, label: 'Fotos completadas', tone: _ChipTone.ok),
              _Chip(icon: Icons.check_circle, label: 'Descripciones completadas', tone: _ChipTone.ok),
              _Chip(label: '(7) Sin toppings', tone: _ChipTone.warn),
              _Chip(icon: Icons.check_circle, label: 'Sin apagados', tone: _ChipTone.ok),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Text(
            'Los cambios en tus productos pueden tardar un par de minutos en verse reflejados en los filtros.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: Spacing.lg),
          for (final MenuCategory category in _filtered())
            Padding(
              padding: const EdgeInsets.only(bottom: Spacing.md),
              child: _CategoryCard(
                category: category,
                onToggle: (product, value) => setState(() => product.available = value),
                onEdit: (product) => _toast('Editar ${product.name}'),
              ),
            ),
        ] else
          AppCard(child: const EmptyState(icon: Icons.tune, title: 'Personalizaciones', message: 'Toppings y modificadores de tu menú.')),
      ],
    );
  }

  List<MenuCategory> _filtered() {
    if (_query.trim().isEmpty) return _categories;
    final String q = _query.toLowerCase();
    return <MenuCategory>[
      for (final MenuCategory c in _categories)
        if (c.products.any((p) => p.name.toLowerCase().contains(q)))
          MenuCategory(name: c.name, incomplete: c.incomplete, products: c.products.where((p) => p.name.toLowerCase().contains(q)).toList()),
    ];
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }
}

class _Tabs extends StatelessWidget {
  const _Tabs({required this.index, required this.onChanged});
  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    const List<String> labels = <String>['Productos', 'Personalizaciones'];
    return Container(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: c.border))),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < labels.length; i++)
            GestureDetector(
              onTap: () => onChanged(i),
              child: Padding(
                padding: const EdgeInsets.only(right: Spacing.lg),
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: Spacing.sm),
                      child: Text(
                        labels[i],
                        style: TextStyle(
                          color: i == index ? c.brandPrimary : c.textMid,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      height: 3,
                      width: i == index ? 84 : 0,
                      decoration: BoxDecoration(color: c.brandPrimary, borderRadius: BorderRadius.circular(Radii.pill)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _ChipTone { ok, warn }

class _Chip extends StatelessWidget {
  const _Chip({required this.label, this.icon, required this.tone});
  final String label;
  final IconData? icon;
  final _ChipTone tone;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = tone == _ChipTone.ok ? c.success : c.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xs),
      decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: c.border)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: 16, color: color),
            const SizedBox(width: Spacing.xs),
          ],
          Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textStrong)),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.onToggle, required this.onEdit});
  final MenuCategory category;
  final void Function(MenuProduct product, bool value) onToggle;
  final ValueChanged<MenuProduct> onEdit;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(Spacing.md),
            child: Row(
              children: <Widget>[
                const Icon(Icons.expand_more),
                const SizedBox(width: Spacing.xs),
                Text(category.name, style: Theme.of(context).textTheme.titleMedium),
                if (category.incomplete) ...<Widget>[
                  const SizedBox(width: Spacing.sm),
                  _Badge(label: 'Con productos incompletos'),
                ],
                const Spacer(),
                Text('Activa', style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(width: Spacing.xs),
                Switch(value: true, onChanged: (_) {}),
                IconButton(onPressed: () {}, icon: const Icon(Icons.calendar_today_outlined, size: 18)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz)),
              ],
            ),
          ),
          Divider(height: 1, color: c.border),
          for (int i = 0; i < category.products.length; i++) ...<Widget>[
            _ProductRow(product: category.products[i], onToggle: onToggle, onEdit: onEdit),
            if (i < category.products.length - 1) Divider(height: 1, color: c.border),
          ],
        ],
      ),
    );
  }
}

class _ProductRow extends StatelessWidget {
  const _ProductRow({required this.product, required this.onToggle, required this.onEdit});
  final MenuProduct product;
  final void Function(MenuProduct product, bool value) onToggle;
  final ValueChanged<MenuProduct> onEdit;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.all(Spacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(Radii.md), border: Border.all(color: c.border)),
            child: Text(product.emoji, style: const TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: Spacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(child: Text(product.name, style: Theme.of(context).textTheme.titleSmall)),
                    if (!product.hasToppings) ...<Widget>[
                      const SizedBox(width: Spacing.sm),
                      _Badge(label: 'Sin toppings'),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(product.description, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: Spacing.sm),
                Text('Precio:', style: Theme.of(context).textTheme.labelSmall),
                Text('S/ ${product.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
          Column(
            children: <Widget>[
              Switch(value: product.available, onChanged: (v) => onToggle(product, v)),
              IconButton(
                onPressed: () => onEdit(product),
                icon: Icon(Icons.edit_outlined, size: 18, color: c.brandPrimary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: 2),
      decoration: BoxDecoration(color: c.warning.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(Radii.sm)),
      child: Text(label, style: TextStyle(color: c.warning, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}
