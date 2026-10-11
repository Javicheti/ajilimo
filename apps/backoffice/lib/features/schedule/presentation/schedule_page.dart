import 'package:ajilimo_shared/ajilimo_shared.dart';
import 'package:flutter/material.dart';

class _DaySchedule {
  _DaySchedule(this.label, this.start, this.end);
  final String label;
  TimeOfDay start;
  TimeOfDay end;

  double get hours {
    final double s = start.hour + start.minute / 60;
    final double e = end.hour + end.minute / 60;
    return (e - s + 24) % 24;
  }
}

class SchedulePage extends StatefulWidget {
  const SchedulePage({super.key});

  @override
  State<SchedulePage> createState() => _SchedulePageState();
}

class _SchedulePageState extends State<SchedulePage> {
  late final List<_DaySchedule> _days = <_DaySchedule>[
    _DaySchedule('Lunes', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 22, minute: 0)),
    _DaySchedule('Martes', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 22, minute: 0)),
    _DaySchedule('Miércoles', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 22, minute: 0)),
    _DaySchedule('Jueves', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 22, minute: 0)),
    _DaySchedule('Viernes', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 22, minute: 0)),
    _DaySchedule('Sábado', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 22, minute: 0)),
    _DaySchedule('Domingo', const TimeOfDay(hour: 12, minute: 0), const TimeOfDay(hour: 22, minute: 0)),
  ];

  double get _totalHours => _days.fold(0, (sum, d) => sum + d.hours);

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(Spacing.lg),
      children: <Widget>[
        const PageHeader(
          icon: Icons.schedule_outlined,
          eyebrow: 'Operación',
          title: 'Horarios',
          subtitle: 'Abre al menos 30 h/semana para mejor posicionamiento',
        ),
        FilterBar(
          items: const <FilterItem>[
            FilterItem(label: 'Sucursal', value: 'Alenka´s Bakery - Benavides'),
            FilterItem(label: 'Zona horaria', value: 'America/Lima', icon: Icons.public),
          ],
          actions: <Widget>[
            FilledButton.icon(onPressed: _save, icon: const Icon(Icons.save_outlined, size: 16), label: const Text('Guardar')),
          ],
        ),
        const SizedBox(height: Spacing.lg),
        AppCard(
          child: Row(
            children: <Widget>[
              Icon(Icons.timer_outlined, color: context.colors.brandPrimary),
              const SizedBox(width: Spacing.sm),
              Text('Horas registradas', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text('${_totalHours.toStringAsFixed(0)} horas', style: Theme.of(context).textTheme.titleLarge),
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        AppCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: <Widget>[
              for (int i = 0; i < _days.length; i++) ...<Widget>[
                _DayRow(day: _days[i], onChange: () => setState(() {})),
                if (i < _days.length - 1) Divider(height: 1, color: context.colors.border),
              ],
            ],
          ),
        ),
        const SizedBox(height: Spacing.lg),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text('Días festivos y especiales', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: Spacing.xs),
              Text(
                'Configura horarios distintos para feriados y fechas especiales.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: Spacing.sm),
              OutlinedButton.icon(
                onPressed: () => _save(),
                icon: const Icon(Icons.event_outlined, size: 16),
                label: const Text('Agregar día festivo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _save() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Horario guardado')),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({required this.day, required this.onChange});
  final _DaySchedule day;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.colors;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 100,
            child: Text(day.label, style: Theme.of(context).textTheme.titleSmall),
          ),
          _TimeField(label: 'Hora inicio', value: day.start, onPick: (t) { day.start = t; onChange(); }),
          const SizedBox(width: Spacing.md),
          _TimeField(label: 'Hora fin', value: day.end, onPick: (t) { day.end = t; onChange(); }),
          const Spacer(),
          Text('${day.hours.toStringAsFixed(0)} h', style: Theme.of(context).textTheme.labelMedium?.copyWith(color: c.textMid)),
        ],
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  const _TimeField({required this.label, required this.value, required this.onPick});
  final String label;
  final TimeOfDay value;
  final ValueChanged<TimeOfDay> onPick;

  @override
  Widget build(BuildContext context) {
    final String text = '${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
    return OutlinedButton(
      onPressed: () async {
        final TimeOfDay? picked = await showTimePicker(context: context, initialTime: value);
        if (picked != null) onPick(picked);
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(label, style: Theme.of(context).textTheme.labelSmall),
          const SizedBox(width: Spacing.xs),
          Text(text, style: Theme.of(context).textTheme.titleSmall),
        ],
      ),
    );
  }
}
