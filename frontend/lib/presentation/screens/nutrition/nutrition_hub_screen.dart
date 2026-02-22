import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../data/models/nutrition_models.dart';
import 'log_meal_screen.dart';
import 'meal_history_screen.dart';

/// Pantalla principal del módulo nutricional.
///
/// Secciones:
///  1. Resumen del día (carbs, CG, insulina)
///  2. Botón hero "Registrar Comida"
///  3. Botón secundario "Dosis Rápida"
///  4. Últimas comidas + "Ver todo"
class NutritionHubScreen extends StatefulWidget {
  const NutritionHubScreen({super.key});

  @override
  State<NutritionHubScreen> createState() => _NutritionHubScreenState();
}

class _NutritionHubScreenState extends State<NutritionHubScreen> {
  @override
  void initState() {
    super.initState();
    _loadTodayHistory();
  }

  void _loadTodayHistory() {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.selectedProfile == null) {
      return;
    }
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    context.read<NutritionBloc>().add(LoadMealHistory(
          authState.selectedProfile!.id,
          startDate: startOfDay,
          endDate: now,
          limit: 50,
        ));
  }

  void _navigateToLogMeal(BuildContext context) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NutritionBloc>(),
          child: const LogMealScreen(),
        ),
      ),
    );
    if (result == true && mounted) _loadTodayHistory();
  }

  void _navigateToHistory(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.selectedProfile == null) {
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<NutritionBloc>(),
          child: MealHistoryScreen(
              patientId: authState.selectedProfile!.id),
        ),
      ),
    );
  }

  void _showQuickDoseDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final authState = context.read<AuthBloc>().state;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Dosis Rápida de Insulina'),
        content: TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Unidades',
            suffixText: 'U',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final units = double.tryParse(ctrl.text) ?? 0;
              if (units > 0 &&
                  authState is AuthAuthenticated &&
                  authState.selectedProfile != null) {
                context.read<NutritionBloc>().add(
                      LogInsulinDose(
                          authState.selectedProfile!.id, units),
                    );
                Navigator.pop(ctx);
              }
            },
            child: const Text('Registrar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isAdult =
        context.select((ThemeBloc b) => b.state.uiMode.isAdult);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdult ? 'Comidas' : 'Mi Menú'),
        elevation: 0,
      ),
      body: BlocConsumer<NutritionBloc, NutritionState>(
        listener: (context, state) {
          if (state is NutritionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
          if (state is MealHistoryLoaded) {
            // Tras una dosis rápida exitosa, recargar historial del día
          }
        },
        builder: (context, state) {
          final meals = state is MealHistoryLoaded ? state.meals : null;
          final isLoading = state is NutritionLoading;

          return RefreshIndicator(
            onRefresh: () async => _loadTodayHistory(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sección 1: Resumen del día ────────────────────
                  _DaySummaryCard(meals: meals, isLoading: isLoading),
                  const SizedBox(height: 20),

                  // ── Sección 2: Registrar Comida (hero) ────────────
                  _HeroRegisterButton(
                    isAdult: isAdult,
                    onTap: () => _navigateToLogMeal(context),
                  ),
                  const SizedBox(height: 12),

                  // ── Sección 3: Dosis Rápida ───────────────────────
                  _QuickDoseButton(
                    isAdult: isAdult,
                    onTap: () => _showQuickDoseDialog(context),
                  ),
                  const SizedBox(height: 24),

                  // ── Sección 4: Índice glucémico de referencia ─────
                  _GlycemicIndexInfo(),
                  const SizedBox(height: 24),

                  // ── Sección 5: Últimas comidas ────────────────────
                  _RecentMealsSection(
                    meals: meals,
                    isLoading: isLoading,
                    isAdult: isAdult,
                    onViewAll: () => _navigateToHistory(context),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Sección 1: Resumen del día ─────────────────────────────────────────────

class _DaySummaryCard extends StatelessWidget {
  final List<MealLogEntry>? meals;
  final bool isLoading;

  const _DaySummaryCard({this.meals, required this.isLoading});

  @override
  Widget build(BuildContext context) {
    final totalCarbs =
        meals?.fold(0.0, (s, m) => s + m.totalCarbsGrams) ?? 0.0;
    final totalCG =
        meals?.fold(0.0, (s, m) => s + m.totalGlycemicLoad) ?? 0.0;
    final totalInsulin = meals?.fold(
            0.0, (s, m) => s + (m.bolusUnitsAdministered ?? 0)) ??
        0.0;
    final count = meals?.length ?? 0;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.today, size: 18),
                const SizedBox(width: 8),
                Text('Hoy', style: Theme.of(context).textTheme.titleMedium),
                const Spacer(),
                if (isLoading)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _SummaryChip(
                  icon: Icons.grain,
                  label: 'Carbs',
                  value: '${totalCarbs.toStringAsFixed(0)} g',
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  icon: Icons.show_chart,
                  label: 'C. Glucém.',
                  value: totalCG.toStringAsFixed(1),
                  color: Colors.blue,
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  icon: Icons.water_drop,
                  label: 'Insulina',
                  value: '${totalInsulin.toStringAsFixed(1)} U',
                  color: Colors.teal,
                ),
              ],
            ),
            if (count > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$count comida${count != 1 ? 's' : ''} registrada${count != 1 ? 's' : ''}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 14)),
            Text(label,
                style:
                    const TextStyle(fontSize: 10, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── Sección 2: Botón hero ──────────────────────────────────────────────────

class _HeroRegisterButton extends StatelessWidget {
  final bool isAdult;
  final VoidCallback onTap;

  const _HeroRegisterButton(
      {required this.isAdult, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Colors.white,
        ),
        icon: const Icon(Icons.add_circle, size: 28),
        label: Text(
          isAdult ? 'Registrar Comida' : '¡Hora de comer! 🍽️',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        onPressed: onTap,
      ),
    );
  }
}

// ── Sección 3: Dosis rápida ────────────────────────────────────────────────

class _QuickDoseButton extends StatelessWidget {
  final bool isAdult;
  final VoidCallback onTap;

  const _QuickDoseButton(
      {required this.isAdult, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        style: OutlinedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        icon: const Icon(Icons.water_drop_outlined),
        label: Text(isAdult ? 'Registrar Dosis Manual' : 'Poner mi dosis 💉'),
        onPressed: onTap,
      ),
    );
  }
}

// ── Sección 4: Info IG de referencia ──────────────────────────────────────

class _GlycemicIndexInfo extends StatelessWidget {
  const _GlycemicIndexInfo();

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: const Icon(Icons.info_outline),
      title: const Text('Guía de Índice Glucémico'),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade300)),
      childrenPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        _IGRow('IG bajo (< 55)', 'Lentejas, manzana, yogur', Colors.green),
        _IGRow('IG medio (55–70)', 'Arroz integral, plátano', Colors.orange),
        _IGRow('IG alto (> 70)', 'Pan blanco, patata, sandía', Colors.red),
        const SizedBox(height: 8),
        Text(
          'La Carga Glucémica (CG) es más precisa: combina IG × cantidad de CHO.',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _IGRow extends StatelessWidget {
  final String label;
  final String examples;
  final Color color;

  const _IGRow(this.label, this.examples, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration:
                BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(examples,
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sección 5: Últimas comidas ─────────────────────────────────────────────

class _RecentMealsSection extends StatelessWidget {
  final List<MealLogEntry>? meals;
  final bool isLoading;
  final bool isAdult;
  final VoidCallback onViewAll;

  const _RecentMealsSection({
    this.meals,
    required this.isLoading,
    required this.isAdult,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Últimas comidas',
                style: Theme.of(context).textTheme.titleMedium),
            TextButton(
              onPressed: onViewAll,
              child: const Text('Ver todo →'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (isLoading)
          const Center(child: CircularProgressIndicator()),
        if (!isLoading && (meals == null || meals!.isEmpty))
          Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Sin comidas registradas hoy',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey),
            ),
          ),
        if (!isLoading && meals != null && meals!.isNotEmpty)
          ...meals!.take(3).map((m) => _MealEntryCard(meal: m)),
      ],
    );
  }
}

class _MealEntryCard extends StatelessWidget {
  final MealLogEntry meal;

  const _MealEntryCard({required this.meal});

  Color _bolusColor(double? units) {
    if (units == null) return Colors.grey;
    if (units <= 2) return Colors.green;
    if (units <= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final time = meal.parsedTimestamp;
    final timeStr = time != null
        ? '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}'
        : '--:--';
    final bolus = meal.bolusUnitsAdministered;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _bolusColor(bolus).withOpacity(0.15),
          child:
              Icon(Icons.restaurant, color: _bolusColor(bolus), size: 20),
        ),
        title: Text(
          '${meal.totalCarbsGrams.toStringAsFixed(1)} g CHO',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'CG ${meal.totalGlycemicLoad.toStringAsFixed(1)}  ·  $timeStr',
        ),
        trailing: bolus != null
            ? Chip(
                label: Text(
                  '${bolus.toStringAsFixed(1)} U',
                  style: TextStyle(
                      color: _bolusColor(bolus),
                      fontWeight: FontWeight.bold),
                ),
                backgroundColor: _bolusColor(bolus).withOpacity(0.1),
                side:
                    BorderSide(color: _bolusColor(bolus), width: 1),
              )
            : null,
      ),
    );
  }
}
