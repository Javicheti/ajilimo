import 'dart:async';

import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/orders_repository.dart';
import '../domain/order.dart';
import 'orders_providers.dart';

class OrdersPage extends ConsumerStatefulWidget {
  const OrdersPage({super.key});

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  late List<DeliveryOrder> _orders;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    final OrdersRepository repository = ref.read(ordersRepositoryProvider);
    _orders = repository.seed(DateTime.now());
    _loadRemote(repository);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadRemote(OrdersRepository repository) async {
    try {
      final List<DeliveryOrder> remote = await repository.fetchRemote();
      if (!mounted || remote.isEmpty) return;
      setState(() => _orders = remote);
    } catch (_) {
      // Sin BFF disponible: se mantienen los datos ficticios locales.
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _take(DeliveryOrder order) {
    final int index = _orders.indexWhere((o) => o.id == order.id);
    setState(() => _orders[index] = _orders[index].take(DateTime.now()));
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int preparing = _orders.where((o) => o.status == OrderStatus.preparing).length;
    final int overdue =
        _orders.where((o) => o.cookingState(now) == CookingState.overdue).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Órdenes · Cooking time'),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: Center(
              child: Text(
                'Objetivo 22 min',
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: <Widget>[
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: <Widget>[
                  SizedBox(
                    width: 190,
                    child: KpiCard(
                      label: 'En preparación',
                      value: '$preparing',
                      icon: Icons.outdoor_grill_outlined,
                      accent: context.colors.info,
                    ),
                  ),
                  SizedBox(
                    width: 190,
                    child: KpiCard(
                      label: 'Excedidas',
                      value: '$overdue',
                      icon: Icons.timer_off_outlined,
                      accent: context.colors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              ..._orders.map((order) => _OrderCard(order: order, now: now, onTake: () => _take(order))),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, required this.now, required this.onTake});

  final DeliveryOrder order;
  final DateTime now;
  final VoidCallback onTake;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final CookingState state = order.cookingState(now);
    final Color stateColor = switch (state) {
      CookingState.onTime => c.success,
      CookingState.atRisk => c.warning,
      CookingState.overdue => c.danger,
    };

    final int elapsed = order.elapsedSeconds(now);
    final double progress = order.status == OrderStatus.preparing
        ? (elapsed / (order.targetMinutes * 60)).clamp(0, 1)
        : 0;

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                ChannelBadge(channel: order.channel),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(order.id, style: Theme.of(context).textTheme.titleMedium),
                ),
                _StatusTag(order: order, state: state, stateColor: stateColor),
              ],
            ),
            const SizedBox(height: Spacing.xs),
            Text(
              order.storeName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textMid),
            ),
            const SizedBox(height: Spacing.sm),
            ...order.items.map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: Spacing.xxs),
                child: Text('• $item', style: Theme.of(context).textTheme.bodyMedium),
              ),
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: <Widget>[
                Text(
                  'S/ ${order.total.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (order.status == OrderStatus.pending)
                  FilledButton.icon(
                    onPressed: onTake,
                    icon: const Icon(Icons.play_arrow_outlined),
                    label: const Text('Tomar (22 min)'),
                  )
                else
                  Text(
                    '${_format(elapsed)} / ${order.targetMinutes}:00',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(color: stateColor),
                  ),
              ],
            ),
            if (order.status == OrderStatus.preparing) ...<Widget>[
              const SizedBox(height: Spacing.sm),
              ClipRRect(
                borderRadius: BorderRadius.circular(Radii.pill),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: c.border,
                  valueColor: AlwaysStoppedAnimation<Color>(stateColor),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  static String _format(int seconds) {
    final int m = seconds ~/ 60;
    final int s = seconds % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.order, required this.state, required this.stateColor});
  final DeliveryOrder order;
  final CookingState state;
  final Color stateColor;

  @override
  Widget build(BuildContext context) {
    final String text = order.status == OrderStatus.pending ? order.status.label : state.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
      decoration: BoxDecoration(
        color: stateColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.pill),
        border: Border.all(color: stateColor.withValues(alpha: 0.35)),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: stateColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}
