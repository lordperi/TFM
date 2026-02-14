import 'package:flutter/material.dart';

/// Widget for basal insulin configuration (long-acting insulin)
/// Examples: Lantus, Levemir, Tresiba, Toujeo
class BasalInsulinFields extends StatefulWidget {
  final TextEditingController typeController;
  final TextEditingController unitsController;
  final TextEditingController timeController;

  const BasalInsulinFields({
    super.key,
    required this.typeController,
    required this.unitsController,
    required this.timeController,
  });

  @override
  State<BasalInsulinFields> createState() => _BasalInsulinFieldsState();
}

class _BasalInsulinFieldsState extends State<BasalInsulinFields> {
  final List<String> basalInsulinTypes = [
    'Lantus',
    'Levemir',
    'Tresiba',
    'Toujeo',
    'NPH',
    'Degludec',
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: const Text('Insulina Basal (Opcional)'),
        subtitle: const Text('Insulina de acción prolongada'),
        initiallyExpanded: widget.typeController.text.isNotEmpty,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Dropdown para tipo de insulina basal
                DropdownButtonFormField<String>(
                  value: widget.typeController.text.isEmpty
                      ? null
                      : widget.typeController.text,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Insulina Basal',
                    helperText: 'Ej: Lantus, Levemir, Tresiba',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.medication),
                  ),
                  items: basalInsulinTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      widget.typeController.text = value ?? '';
                    });
                  },
                ),

                const SizedBox(height: 16),

                // TextField para unidades (0-100)
                TextFormField(
                  controller: widget.unitsController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Unidades',
                    helperText: 'Cantidad de unidades por dosis',
                    suffixText: 'U',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.healing),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      // Campo opcional, solo validar si tiene valor
                      return null;
                    }
                    final units = double.tryParse(value);
                    if (units == null || units < 0 || units > 100) {
                      return 'Las unidades deben estar entre 0 y 100';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 16),

                // TimePicker para hora de administración
                TextFormField(
                  controller: widget.timeController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Hora de Administración',
                    helperText: 'Hora en la que tomas la insulina basal',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.access_time),
                  ),
                  onTap: () async {
                    final TimeOfDay? time = await showTimePicker(
                      context: context,
                      initialTime: _parseTime(widget.timeController.text) ??
                          const TimeOfDay(hour: 22, minute: 0),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(alwaysUse24HourFormat: true),
                          child: child!,
                        );
                      },
                    );
                    if (time != null) {
                      final formattedTime =
                          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                      setState(() {
                        widget.timeController.text = formattedTime;
                      });
                    }
                  },
                ),

                const SizedBox(height: 8),

                // Info adicional
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'La insulina basal mantiene tu glucosa estable entre comidas y durante la noche.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Parse time from HH:MM string
  TimeOfDay? _parseTime(String time) {
    if (time.isEmpty) return null;
    try {
      final parts = time.split(':');
      if (parts.length == 2) {
        return TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }
}
