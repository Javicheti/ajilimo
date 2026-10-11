import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/evidence_record.dart';
import 'evidence_providers.dart';

class EvidencePage extends ConsumerWidget {
  const EvidencePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppColors c = context.colors;
    final List<EvidenceRecord> records = ref.read(evidenceRepositoryProvider).seed();
    final int complete = records.where((r) => r.complete).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: <Widget>[
              const PageHeader(
                icon: Icons.photo_camera_outlined,
                eyebrow: 'Defensa',
                title: 'Evidencia',
                subtitle: 'KORN · foto del pedido ligada a cada orden',
              ),
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: <Widget>[
                  SizedBox(
                    width: 200,
                    child: KpiCard(
                      label: 'Con evidencia',
                      value: '$complete',
                      icon: Icons.photo_camera_outlined,
                      accent: c.success,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: KpiCard(
                      label: 'Sin evidencia',
                      value: '${records.length - complete}',
                      icon: Icons.error_outline,
                      accent: c.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              SectionHeader(title: 'Pedidos', subtitle: '${records.length} registros'),
              LayoutBuilder(
                builder: (context, constraints) {
                  const double gap = Spacing.md;
                  final int columns =
                      constraints.maxWidth > 1000 ? 4 : constraints.maxWidth > 700 ? 3 : 2;
                  final double itemWidth = (constraints.maxWidth - gap * (columns - 1)) / columns;
                  return Wrap(
                    spacing: gap,
                    runSpacing: gap,
                    children: records
                        .map((record) => SizedBox(width: itemWidth, child: _EvidenceCard(record: record)))
                        .toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidenceCard extends StatelessWidget {
  const _EvidenceCard({required this.record});
  final EvidenceRecord record;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 4 / 3,
            child: Container(
              decoration: BoxDecoration(
                color: record.complete ? c.brandSoft : c.surfaceAlt,
                borderRadius: BorderRadius.circular(Radii.md),
                border: Border.all(color: c.border),
              ),
              child: Icon(
                record.complete ? Icons.image_outlined : Icons.image_not_supported_outlined,
                size: 40,
                color: record.complete ? c.brandPrimary : c.textFaint,
              ),
            ),
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: <Widget>[
              ChannelBadge(channel: record.channel, showLabel: false),
              const SizedBox(width: Spacing.xs),
              Expanded(
                child: Text(record.orderId, style: Theme.of(context).textTheme.titleSmall),
              ),
            ],
          ),
          const SizedBox(height: Spacing.xxs),
          Text(
            record.storeName,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: c.textMid),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: Spacing.xs),
          Text(
            record.complete ? 'Evidencia completa' : 'Evidencia incompleta',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: record.complete ? c.success : c.danger,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
