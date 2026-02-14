import 'package:flutter/material.dart';
import '../../core/constants/diabetes_type.dart';
import '../../core/constants/therapy_type.dart';

/// Widget that conditionally renders medical fields based on diabetes and therapy type
class ConditionalMedicalFields extends StatefulWidget {
  final DiabetesType diabetesType;
  final TherapyType? therapyType;
  final Function(TherapyType?) onTherapyTypeChanged;
  final TextEditingController? isfController;
  final TextEditingController? icrController;
  final TextEditingController? targetController;
  final TextEditingController? targetRangeLowController;
  final TextEditingController? targetRangeHighController;

  const ConditionalMedicalFields({
    super.key,
    required this.diabetesType,
    required this.therapyType,
    required this.onTherapyTypeChanged,
    this.isfController,
    this.icrController,
    this.targetController,
    this.targetRangeLowController,
    this.targetRangeHighController,
  });

  @override
  State<ConditionalMedicalFields> createState() =>
      _ConditionalMedicalFieldsState();
}

class _ConditionalMedicalFieldsState extends State<ConditionalMedicalFields> {
  @override
  Widget build(BuildContext context) {
    // Si diabetes = NONE, no mostrar nada
    if (widget.diabetesType == DiabetesType.none) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de tipo de tratamiento
        _buildTherapyTypeSelector(),

        const SizedBox(height: 16),

        // Campos de insulina (solo si therapy requiere insulina)
        if (widget.therapyType?.requiresInsulinFields() == true) ...[
          _buildInsulinFields(),
        ],
        
        const SizedBox(height: 16),
        _buildGlucoseRanges(),
      ],
    );
  }

  Widget _buildTherapyTypeSelector() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tipo de Tratamiento',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            ...TherapyType.values.where((type) {
              // Filtrar opciones según tipo de diabetes
              if (widget.diabetesType == DiabetesType.type1) {
                // Tipo 1: Normalmente usa insulina
                return type == TherapyType.insulin || type == TherapyType.none;
              } else if (widget.diabetesType == DiabetesType.type2) {
                // Tipo 2: Puede usar oral, insulina o mixto
                return type != TherapyType.none;
              }
              return true;
            }).map((type) {
              return RadioListTile<TherapyType>(
                contentPadding: EdgeInsets.zero,
                title: Text(type.displayName),
                value: type,
                groupValue: widget.therapyType,
                onChanged: widget.onTherapyTypeChanged,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildInsulinFields() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Parámetros de Insulina Rápida',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            
            // ISF (Insulin Sensitivity Factor)
            TextFormField(
              controller: widget.isfController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Factor de Sensibilidad a la Insulina (ISF)',
                helperText: '¿Cuánto baja 1 unidad de insulina tu glucosa? (mg/dL)',
                suffixText: 'mg/dL',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido para terapia con insulina';
                }
                final isf = double.tryParse(value);
                if (isf == null || isf <= 0 || isf > 500) {
                  return 'Debe estar entre 1 y 500';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // ICR (Insulin-to-Carb Ratio)
            TextFormField(
              controller: widget.icrController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: 'Ratio Insulina:Carbohidratos (ICR)',
                helperText: '¿Cuántos gramos cubre 1 unidad de insulina?',
                suffixText: 'g/U',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido para terapia con insulina';
                }
                final icr = double.tryParse(value);
                if (icr == null || icr <= 0 || icr > 150) {
                  return 'Debe estar entre 1 y 150';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Target Glucose
            TextFormField(
              controller: widget.targetController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Glucosa Objetivo',
                helperText: 'Valor objetivo de glucosa en sangre',
                suffixText: 'mg/dL',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Campo requerido para terapia con insulina';
                }
                final target = int.tryParse(value);
                if (target == null || target < 70 || target > 180) {
                  return 'Debe estar entre 70 y 180';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlucoseRanges() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Rangos Objetivo (Alarmas)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
             Row(
               children: [
                 Expanded(
                   child: TextFormField(
                      controller: widget.targetRangeLowController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min',
                        suffixText: 'mg/dL',
                        border: OutlineInputBorder(),
                      ),
                   ),
                 ),
                 const SizedBox(width: 16),
                 Expanded(
                   child: TextFormField(
                      controller: widget.targetRangeHighController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max',
                        suffixText: 'mg/dL',
                        border: OutlineInputBorder(),
                      ),
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 8),
             Text(
               'Define los límites para considerar la glucosa en rango óptimo.',
               style: Theme.of(context).textTheme.bodySmall,
             ),
          ],
        ),
      ),
    );
  }
}
