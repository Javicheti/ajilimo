import 'dart:async';

import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/claims_repository.dart';
import '../domain/claim.dart';
import 'claims_providers.dart';

class ClaimsPage extends ConsumerStatefulWidget {
  const ClaimsPage({super.key});

  @override
  ConsumerState<ClaimsPage> createState() => _ClaimsPageState();
}

class _ClaimsPageState extends ConsumerState<ClaimsPage> {
  late List<Claim> _claims;
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    final ClaimsRepository repository = ref.read(claimsRepositoryProvider);
    _claims = repository.seed(DateTime.now());
    _loadRemote(repository);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _loadRemote(ClaimsRepository repository) async {
    try {
      final List<Claim> remote = await repository.fetchRemote();
      if (!mounted || remote.isEmpty) return;
      setState(() => _claims = remote);
    } catch (_) {
      // Sin BFF disponible: se mantienen los datos ficticios locales.
    }
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _respond(Claim claim, bool accept) {
    setState(() => _claims.removeWhere((c) => c.id == claim.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(accept ? 'Reclamo aceptado' : 'Reclamo rechazado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final int critical = _claims.where((c) => c.urgencyAt(now) == ClaimUrgency.critical).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 980),
          child: ListView(
            padding: const EdgeInsets.all(Spacing.lg),
            children: <Widget>[
              const PageHeader(
                icon: Icons.gavel_outlined,
                eyebrow: 'Defensa',
                title: 'Reclamos',
                subtitle: 'Bandeja DiDi · responde antes de 24 h para evitar devoluciones',
              ),
              Wrap(
                spacing: Spacing.md,
                runSpacing: Spacing.md,
                children: <Widget>[
                  SizedBox(
                    width: 200,
                    child: KpiCard(
                      label: 'Pendientes',
                      value: '${_claims.length}',
                      icon: Icons.gavel_outlined,
                      accent: context.colors.info,
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    child: KpiCard(
                      label: 'Críticos (<4 h)',
                      value: '$critical',
                      icon: Icons.timer_outlined,
                      accent: context.colors.danger,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: Spacing.lg),
              SectionHeader(title: 'Bandeja', subtitle: 'Responde antes de 24 h'),
              if (_claims.isEmpty)
                AppCard(
                  child: Text('Sin reclamos pendientes.', style: Theme.of(context).textTheme.bodyMedium),
                )
              else
                ..._claims.map((claim) => _ClaimCard(claim: claim, now: now, onRespond: _respond)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimCard extends StatelessWidget {
  const _ClaimCard({required this.claim, required this.now, required this.onRespond});
  final Claim claim;
  final DateTime now;
  final void Function(Claim claim, bool accept) onRespond;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    final ClaimUrgency urgency = claim.urgencyAt(now);
    final Color color = switch (urgency) {
      ClaimUrgency.ok => c.success,
      ClaimUrgency.warning => c.warning,
      ClaimUrgency.critical => c.danger,
      ClaimUrgency.expired => c.textFaint,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: Spacing.md),
      child: AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                ChannelBadge(channel: claim.channel),
                const SizedBox(width: Spacing.sm),
                Expanded(
                  child: Text(claim.orderId, style: Theme.of(context).textTheme.titleMedium),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: Spacing.sm, vertical: Spacing.xxs),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(Radii.pill),
                    border: Border.all(color: color.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.timer_outlined, size: 14, color: color),
                      const SizedBox(width: Spacing.xxs),
                      Text(
                        claim.countdown(now),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: color,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: Spacing.sm),
            Text(claim.reason.label, style: Theme.of(context).textTheme.bodyMedium),
            Text(
              'Monto: S/ ${claim.amount.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: Spacing.sm),
            Row(
              children: <Widget>[
                const Spacer(),
                OutlinedButton(
                  onPressed: () => onRespond(claim, false),
                  child: const Text('Rechazar'),
                ),
                const SizedBox(width: Spacing.sm),
                FilledButton(
                  onPressed: () => onRespond(claim, true),
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
