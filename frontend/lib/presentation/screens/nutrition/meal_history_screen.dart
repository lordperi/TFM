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
  DateTime? _startDate;
  DateTime? _endDate;
  int _currentPage = 0;
  final int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    context.read<NutritionBloc>().add(LoadMealHistory(
      widget.patientId,
      limit: _pageSize,
      offset: _currentPage * _pageSize,
      startDate: _startDate,
      endDate: _endDate,
    ));
  }

  void _onDateSelected(bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked.add(const Duration(hours: 23, minutes: 59));
        }
      });
    }
  }

  void _search() {
    setState(() => _currentPage = 0);
    _loadData();
  }

  void _nextPage() {
    setState(() => _currentPage++);
    _loadData();
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _loadData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAdult = context.watch<ThemeBloc>().state.uiMode.isAdult;

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdult ? 'Historial de Insulina' : 'Mis Dosis Heroicas'),
      ),
      body: Column(
        children: [
          // Filter section
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _DateSelector(
                          label: 'Desde',
                          date: _startDate,
                          onTap: () => _onDateSelected(true),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _DateSelector(
                          label: 'Hasta',
                          date: _endDate != null
                              ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
                              : null,
                          onTap: () => _onDateSelected(false),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _search,
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar'),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: BlocBuilder<NutritionBloc, NutritionState>(
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

                  return Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.meals.length,
                          itemBuilder: (context, index) =>
                              _MealHistoryCard(meal: state.meals[index], isAdult: isAdult),
                        ),
                      ),
                      // Pagination
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton(
                              onPressed: _currentPage > 0 ? _prevPage : null,
                              child: const Text('Anterior'),
                            ),
                            Text('Página ${_currentPage + 1}'),
                            ElevatedButton(
                              onPressed: state.meals.length == _pageSize ? _nextPage : null,
                              child: const Text('Siguiente'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Date selector widget (shared pattern with glucose history)
// ---------------------------------------------------------------------------
class _DateSelector extends StatelessWidget {
  final String label;
  final DateTime? date;
  final VoidCallback onTap;

  const _DateSelector({required this.label, required this.date, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(date != null ? DateFormat('dd/MM/yyyy').format(date!) : 'Seleccionar'),
            const Icon(Icons.calendar_today, size: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// List row card
// ---------------------------------------------------------------------------
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
    final timeStr = ts != null ? DateFormat('dd/MM/yyyy HH:mm').format(ts.toLocal()) : '--';
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
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            ),
            // Bolus chip
            if (meal.bolusUnitsAdministered != null)
              Chip(
                label: Text(
                  '${meal.bolusUnitsAdministered!.toStringAsFixed(1)} U',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
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
