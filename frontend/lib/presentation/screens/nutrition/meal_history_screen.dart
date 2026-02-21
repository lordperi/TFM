import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../data/models/nutrition_models.dart';

class MealHistoryScreen extends StatefulWidget {
  final String patientId;

  const MealHistoryScreen({super.key, required this.patientId});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NutritionBloc>().add(LoadMealHistory(widget.patientId));
  }

  @override
  Widget build(BuildContext context) {
    final isAdult = context.watch<ThemeBloc>().state.uiMode.isAdult;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdult ? 'Historial de Insulina' : 'Mis Dosis Heroicas'),
      ),
      body: BlocBuilder<NutritionBloc, NutritionState>(
        builder: (context, state) {
          if (state is NutritionLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is NutritionError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          if (state is MealHistoryLoaded) {
            if (state.meals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      isAdult ? Icons.history : Icons.sentiment_satisfied_alt,
                      size: 64,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isAdult
                          ? 'Sin registros de insulina todavía'
                          : '¡Aún no has administrado ninguna dosis!',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.meals.length,
              itemBuilder: (context, index) =>
                  _MealHistoryCard(meal: state.meals[index], isAdult: isAdult),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _MealHistoryCard extends StatelessWidget {
  final MealLogEntry meal;
  final bool isAdult;

  const _MealHistoryCard({required this.meal, required this.isAdult});

  Color _bolusColor(double? units) {
    if (units == null) return Colors.grey;
    if (units <= 2.0) return Colors.green;
    if (units <= 5.0) return Colors.orange;
    return Colors.red;
  }

  String _bolusLabel(double? units) {
    if (units == null) return 'Sin datos';
    return '${units.toStringAsFixed(1)} U';
  }

  @override
  Widget build(BuildContext context) {
    final ts = meal.parsedTimestamp;
    final timeStr = ts != null
        ? DateFormat('dd/MM/yyyy HH:mm').format(ts.toLocal())
        : '--';

    final bolusColor = _bolusColor(meal.bolusUnitsAdministered);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Bolus indicator circle
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: bolusColor.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: bolusColor, width: 2),
              ),
              child: Center(
                child: Text(
                  _bolusLabel(meal.bolusUnitsAdministered),
                  style: TextStyle(
                    color: bolusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAdult ? 'Registro de Comida' : '¡Misión completada!',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${meal.totalCarbsGrams.toStringAsFixed(1)} g carbohidratos  •  '
                    'CG ${meal.totalGlycemicLoad.toStringAsFixed(1)}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    timeStr,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),

            // Bolus chip
            if (meal.bolusUnitsAdministered != null)
              Chip(
                label: Text(
                  '${meal.bolusUnitsAdministered!.toStringAsFixed(1)} U',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                backgroundColor: bolusColor,
                padding: EdgeInsets.zero,
              ),
          ],
        ),
      ),
    );
  }
}
