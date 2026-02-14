
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/glucose_models.dart';
import '../../bloc/glucose/glucose_bloc.dart';
import '../../../core/theme/app_theme.dart';
import 'package:intl/intl.dart';

class AddGlucoseScreen extends StatefulWidget {
  final String patientId;

  const AddGlucoseScreen({super.key, required this.patientId});

  @override
  State<AddGlucoseScreen> createState() => _AddGlucoseScreenState();
}

class _AddGlucoseScreenState extends State<AddGlucoseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _valueController = TextEditingController();
  final _notesController = TextEditingController();
  
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  GlucoseType _selectedType = GlucoseType.finger;

  @override
  void dispose() {
    _valueController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final value = int.parse(_valueController.text);
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      context.read<GlucoseBloc>().add(AddGlucoseMeasurement(
        patientId: widget.patientId,
        value: value,
        timestamp: dateTime,
        type: _selectedType,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GlucoseBloc, GlucoseState>(
      listener: (context, state) {
        if (state is GlucoseAdded) {
          Navigator.of(context).pop(true); // Return true to indicate success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Medición guardada correctamente')),
          );
        } else if (state is GlucoseError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Añadir Glucosa'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                // Value Input
                TextFormField(
                  controller: _valueController,
                  decoration: const InputDecoration(
                    labelText: 'Valor de Glucosa (mg/dL)',
                    border: OutlineInputBorder(),
                    suffixText: 'mg/dL',
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un valor';
                    }
                    if (int.tryParse(value) == null) {
                      return 'Debe ser un número entero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Date & Time
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectDate(context),
                        icon: const Icon(Icons.calendar_today),
                        label: Text(DateFormat('dd/MM/yyyy').format(_selectedDate)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _selectTime(context),
                        icon: const Icon(Icons.access_time),
                        label: Text(_selectedTime.format(context)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Type Dropdown
                DropdownButtonFormField<GlucoseType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Medición',
                    border: OutlineInputBorder(),
                  ),
                  items: GlucoseType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Notes
                TextFormField(
                  controller: _notesController,
                  decoration: const InputDecoration(
                    labelText: 'Notas (Opcional)',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Submit Button
                BlocBuilder<GlucoseBloc, GlucoseState>(
                  builder: (context, state) {
                    return FilledButton(
                      onPressed: state is GlucoseAdding ? null : _submit,
                      child: state is GlucoseAdding
                          ? const CircularProgressIndicator()
                          : const Text('Guardar'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
