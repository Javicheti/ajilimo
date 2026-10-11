import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/connectivity_repository.dart';
import '../domain/connectivity.dart';

class ConnectivityPage extends ConsumerStatefulWidget {
  const ConnectivityPage({super.key});

  @override
  ConsumerState<ConnectivityPage> createState() => _ConnectivityPageState();
}

class _ConnectivityPageState extends ConsumerState<ConnectivityPage> {
  late List<ConnectivityRow> _rows;

  @override
  void initState() {
    super.initState();
    final ConnectivityRepository repository = ref.read(connectivityRepositoryProvider);
    _rows = repository.seed();
    _load(repository);
  }

  Future<void> _load(ConnectivityRepository repository) async {
    try {
      final List<ConnectivityRow> remote = await repository.fetchRemote();
      if (!mounted || remote.isEmpty) return;
      setState(() => _rows = remote);
    } catch (_) {
      // Sin BFF: se mantienen datos locales.
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        const PageHeader(
          icon: Icons.wifi_tethering,
          eyebrow: 'Operación',
          title: 'Conectividad',
          subtitle: 'Estado en tiempo real de tus tiendas · abrir / cerrar de forma masiva',
        ),
        FilterBar(
          items: const <FilterItem>[
            FilterItem(label: 'Marca', value: 'Todas'),
            FilterItem(label: 'Sucursales', value: '14 tiendas'),
            FilterItem(label: 'País', value: 'Perú', icon: Icons.public),
          ],
          actions: <Widget>[
            OutlinedButton.icon(
              onPressed: () => _bulk(false),
              icon: const Icon(Icons.power_settings_new, size: 16),
              label: const Text('Cerrar tiendas'),
            ),
            FilledButton.icon(
              onPressed: () => _bulk(true),
              icon: const Icon(Icons.bolt_outlined, size: 16),
              label: const Text('Abrir tiendas'),
            ),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        DataTableCard(
          title: 'Conectividad en tiempo real',
          subtitle: 'Promedio en 15 días',
          columns: const <TableColumn>[
            TableColumn('Tienda'),
            TableColumn('Canal'),
            TableColumn('Estado'),
            TableColumn('Más información'),
            TableColumn(''),
          ],
          rows: <List<Widget>>[
            for (final ConnectivityRow row in _rows)
              <Widget>[
                Text(row.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                ChannelBadge(channel: row.channel),
                StatusChip(status: row.status, compact: true),
                Text(row.detail),
                TextButton(onPressed: () => _detail(row), child: const Text('Ver por día y hora')),
              ],
          ],
        ),
      ],
    );
  }

  void _bulk(bool open) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(open ? 'Abriendo tiendas…' : 'Cerrando tiendas…')),
    );
  }

  void _detail(ConnectivityRow row) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(row.name),
        content: Text('${row.channel.label} · ${row.status.label}\n${row.detail}'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cerrar')),
        ],
      ),
    );
  }
}
