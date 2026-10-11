import 'package:flutter/material.dart';

import '../design/semantic_colors.dart';
import '../design/tokens.dart';
import '../models/delivery.dart';

/// Distintivo de canal de delivery (Rappi / DiDi / PedidosYa).
class ChannelBadge extends StatelessWidget {
  const ChannelBadge({super.key, required this.channel, this.showLabel = true});

  final DeliveryChannel channel;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final Color color = switch (channel) {
      DeliveryChannel.rappi => c.channelRappi,
      DeliveryChannel.didi => c.channelDidi,
      DeliveryChannel.pedidosya => c.channelPedidosya,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.xs, vertical: Spacing.xxs),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(Radii.sm),
      ),
      child: Text(
        showLabel ? channel.label : channel.short,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
