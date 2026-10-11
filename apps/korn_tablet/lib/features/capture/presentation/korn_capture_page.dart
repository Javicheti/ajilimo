import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';

import '../domain/evidence.dart';

/// Flujo KORN de evidencia (Checklist → Foto → Validar → Entregar).
/// La captura con cámara real se integra en una iteración posterior; aquí la
/// foto se simula y la validación bloquea la entrega sin evidencia completa.
class KornCapturePage extends StatefulWidget {
  const KornCapturePage({super.key});

  @override
  State<KornCapturePage> createState() => _KornCapturePageState();
}

class _KornCapturePageState extends State<KornCapturePage> {
  int _step = 0;
  final Set<String> _checked = <String>{};
  final TextEditingController _orderId = TextEditingController();
  bool _photoTaken = false;

  static const List<String> _items = <String>[
    'Makis / alas según pedido',
    'Gaseosa (si aplica)',
    'Extras y salsas',
    'Ticket en el encuadre',
  ];

  bool get _allChecked => _checked.length == _items.length;

  @override
  void dispose() {
    _orderId.dispose();
    super.dispose();
  }

  EvidenceValidation get _validation => validateEvidence(
        orderId: _orderId.text,
        checklistComplete: _allChecked,
        hasPhoto: _photoTaken,
      );

  void _next() => setState(() => _step = (_step + 1).clamp(0, 3));
  void _prev() => setState(() => _step = (_step - 1).clamp(0, 3));

  void _reset() => setState(() {
        _step = 0;
        _checked.clear();
        _photoTaken = false;
        _orderId.clear();
      });

  void _deliver() {
    final EvidenceValidation validation = _validation;
    if (!validation.valid) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(validation.issues.join(' · '))),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evidencia registrada y pedido entregado')),
    );
    _reset();
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: <Widget>[
            const AppLogo(size: 28, wordmarkColor: Colors.white),
            const SizedBox(width: Spacing.sm),
            const Text('KORN · Evidencia del pedido'),
          ],
        ),
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: Spacing.md),
            child: Center(child: ChannelBadge(channel: DeliveryChannel.rappi)),
          ),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(Spacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _Stepper(current: _step),
                const SizedBox(height: Spacing.lg),
                Expanded(child: SingleChildScrollView(child: _buildStep(context))),
                const SizedBox(height: Spacing.md),
                Row(
                  children: <Widget>[
                    if (_step > 0) OutlinedButton(onPressed: _prev, child: const Text('Atrás')),
                    const Spacer(),
                    if (_step < 3)
                      FilledButton(
                        onPressed: (_step == 0 && (!_allChecked || _orderId.text.trim().isEmpty))
                            ? null
                            : (_step == 1 && !_photoTaken)
                                ? null
                                : _next,
                        child: const Text('Continuar'),
                      )
                    else
                      FilledButton.icon(
                        onPressed: _deliver,
                        icon: const Icon(Icons.check_circle_outline),
                        label: const Text('Entregar al rider'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: c.background,
    );
  }

  Widget _buildStep(BuildContext context) {
    switch (_step) {
      case 0:
        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Paso 1 · Checklist', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Spacing.sm),
              TextField(
                controller: _orderId,
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(labelText: 'Número de pedido', hintText: 'R-4821'),
              ),
              const SizedBox(height: Spacing.md),
              ..._items.map(
                (item) => CheckboxListTile(
                  value: _checked.contains(item),
                  onChanged: (value) => setState(() {
                    if (value == true) {
                      _checked.add(item);
                    } else {
                      _checked.remove(item);
                    }
                  }),
                  title: Text(item),
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        );
      case 1:
        return AppCard(
          child: Column(
            children: <Widget>[
              _Placeholder(
                icon: _photoTaken ? Icons.check_circle : Icons.photo_camera_outlined,
                title: 'Paso 2 · Foto',
                message: _photoTaken
                    ? 'Foto capturada. Contenido + ticket en el encuadre.'
                    : 'Haz la foto antes de cerrar la bolsa: contenido + ticket.',
              ),
              const SizedBox(height: Spacing.md),
              FilledButton.icon(
                onPressed: () => setState(() => _photoTaken = true),
                icon: const Icon(Icons.photo_camera),
                label: Text(_photoTaken ? 'Repetir foto' : 'Capturar foto'),
              ),
            ],
          ),
        );
      case 2:
        return AppCard(
          child: _Checklist(
            title: 'Paso 3 · Validación (10 s)',
            items: const <String>[
              '¿Se ve el pedido completo?',
              '¿El ticket se lee en la foto?',
              '¿Bebidas, salsas y extras visibles?',
              '¿Pedido grande? Añade otra toma.',
            ],
          ),
        );
      default:
        return AppCard(
          child: _Placeholder(
            icon: Icons.delivery_dining_outlined,
            title: 'Paso 4 · Entregar',
            message: 'Solo entonces pasa al rider. La foto queda ligada al número de pedido.',
          ),
        );
    }
  }
}

class _Stepper extends StatelessWidget {
  const _Stepper({required this.current});
  final int current;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    const List<String> labels = <String>['Checklist', 'Foto', 'Validar', 'Entregar'];
    return Row(
      children: List<Widget>.generate(labels.length, (i) {
        final bool done = i <= current;
        return Expanded(
          child: Column(
            children: <Widget>[
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: done ? c.brandPrimary : c.border,
                  borderRadius: BorderRadius.circular(Radii.pill),
                ),
              ),
              const SizedBox(height: Spacing.xs),
              Text(labels[i], style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        );
      }),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.icon, required this.title, required this.message});
  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(Spacing.lg),
          decoration: BoxDecoration(color: c.brandSoft, shape: BoxShape.circle),
          child: Icon(icon, size: 48, color: c.brandPrimary),
        ),
        const SizedBox(height: Spacing.md),
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: Spacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: c.textMid),
        ),
      ],
    );
  }
}

class _Checklist extends StatelessWidget {
  const _Checklist({required this.title, required this.items});
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: Spacing.md),
        ...items.map(
          (text) => Padding(
            padding: const EdgeInsets.only(bottom: Spacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(Icons.check_circle, color: c.success, size: 20),
                const SizedBox(width: Spacing.sm),
                Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
