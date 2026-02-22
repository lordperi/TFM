import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../bloc/glucose/glucose_bloc.dart';
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../data/models/nutrition_models.dart';

/// Pantalla para registrar una comida con múltiples ingredientes.
///
/// Flujo:
///  1. Usuario busca ingredientes → los añade a la bandeja
///  2. Cuando la bandeja tiene ítems → FAB "Calcular Bolus"
///  3. Resultado → usuario ajusta dosis → "Registrar"
class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});

  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _searchController = TextEditingController();
  final _bolusDoseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Limpiar estado previo y comenzar con bandeja vacía
    context.read<NutritionBloc>().add(ClearTray());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bolusDoseController.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  ({int glucose, double icr, double isf, double target}) _getProfileParams() {
    final authState = context.read<AuthBloc>().state;
    final profile =
        authState is AuthAuthenticated ? authState.selectedProfile : null;

    final glucoseState = context.read<GlucoseBloc>().state;
    int glucose = 120;
    if (glucoseState is GlucoseLoaded && glucoseState.history.isNotEmpty) {
      glucose = glucoseState.history
          .reduce((a, b) => a.timestamp.isAfter(b.timestamp) ? a : b)
          .glucoseValue;
    }

    return (
      glucose: glucose,
      icr: profile?.carbRatio ?? 10.0,
      isf: profile?.insulinSensitivity ?? 50.0,
      target: profile?.targetGlucose ?? 100.0,
    );
  }

  void _showAddGramsDialog(Ingredient ingredient) {
    final gramsCtrl = TextEditingController();
    final isAdult =
        context.read<ThemeBloc>().state.uiMode.isAdult;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(ingredient.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${ingredient.carbs.toStringAsFixed(1)} g CHO / 100 g',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: gramsCtrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: isAdult ? 'Cantidad (g)' : '¿Cuántos gramos?',
                suffixText: 'g',
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final grams = double.tryParse(gramsCtrl.text) ?? 0;
              if (grams > 0) {
                context
                    .read<NutritionBloc>()
                    .add(AddIngredientToTray(ingredient, grams));
                _searchController.clear();
                Navigator.pop(ctx);
              }
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  void _onCalculateBolus() {
    final params = _getProfileParams();
    context.read<NutritionBloc>().add(CalculateBolusForTray(
          currentGlucose: params.glucose,
          icr: params.icr,
          isf: params.isf,
          targetGlucose: params.target,
        ));
  }

  void _onCommit(List<TrayItem> tray, double bolusUnits) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated ||
        authState.selectedProfile == null) return;

    context.read<NutritionBloc>().add(
          CommitMealFromTray(authState.selectedProfile!.id, bolusUnits),
        );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isAdult = context.select(
        (ThemeBloc bloc) => bloc.state.uiMode.isAdult);

    return BlocConsumer<NutritionBloc, NutritionState>(
      listener: (context, state) {
        if (state is NutritionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
        if (state is MealHistoryLoaded) {
          // Comida registrada con éxito → volver al hub
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Comida registrada!')),
          );
          Navigator.pop(context, true);
        }
      },
      builder: (context, state) {
        if (state is NutritionLoading) {
          return Scaffold(
            appBar: _buildAppBar(context, isAdult, null),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (state is TrayBolusCalculated) {
          return _BolusTrayResultScreen(
            state: state,
            isAdult: isAdult,
            onCommit: _onCommit,
            onBack: () {
              context.read<NutritionBloc>().add(
                    AddIngredientToTray(
                      // Rebobinar: restauramos la bandeja pre-resultado
                      state.tray.first.ingredient,
                      0,
                    ),
                  );
              // Volver a MealTrayUpdated restaurando la bandeja
              context.read<NutritionBloc>()
                ..add(ClearTray())
                ..add(
                  // Reañadir todos los ítems uno por uno
                  // Simplificación: solo limpiamos y recargamos
                  ClearTray(),
                );
              // Navegamos back directamente — el usuario puede volver a añadir
              Navigator.pop(context);
            },
          );
        }

        // Estado de bandeja (con o sin resultados de búsqueda)
        final tray =
            state is MealTrayUpdated ? state.tray : <TrayItem>[];
        final searchResults = state is MealTrayUpdated
            ? state.searchResults
            : state is IngredientsLoaded
                ? state.ingredients
                : <Ingredient>[];

        return Scaffold(
          appBar: _buildAppBar(context, isAdult, tray),
          body: Column(
            children: [
              // ── Barra de búsqueda ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isAdult
                        ? 'Buscar alimento (ej. Arroz, Pollo...)'
                        : '¿Qué vas a comer hoy?',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              context
                                  .read<NutritionBloc>()
                                  .add(const SearchIngredients(''));
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12)),
                    filled: true,
                  ),
                  onChanged: (v) => context
                      .read<NutritionBloc>()
                      .add(SearchIngredients(v)),
                ),
              ),

              // ── Bandeja activa ──────────────────────────────────────
              if (tray.isNotEmpty) _TraySection(tray: tray, isAdult: isAdult),

              // ── Resultados de búsqueda ──────────────────────────────
              if (searchResults.isNotEmpty)
                Expanded(
                  child: ListView.separated(
                    itemCount: searchResults.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, indent: 56),
                    itemBuilder: (context, i) {
                      final item = searchResults[i];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          child: Text(
                            item.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          'IG ${item.glycemicIndex} · ${item.carbs.toStringAsFixed(1)} g CHO/100g',
                        ),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () => _showAddGramsDialog(item),
                      );
                    },
                  ),
                ),

              if (searchResults.isEmpty && tray.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.set_meal,
                            size: 72,
                            color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Busca un alimento para empezar',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),

              if (searchResults.isEmpty && tray.isNotEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      'Busca otro alimento o calcula el bolus',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ),
                ),
            ],
          ),

          // ── FAB Calcular bolus ─────────────────────────────────────
          floatingActionButton: tray.isNotEmpty
              ? FloatingActionButton.extended(
                  onPressed: _onCalculateBolus,
                  icon: const Icon(Icons.calculate),
                  label: Text('Calcular bolus (${tray.length})'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                )
              : null,
        );
      },
    );
  }

  AppBar _buildAppBar(
      BuildContext context, bool isAdult, List<TrayItem>? tray) {
    return AppBar(
      title: Text(isAdult ? 'Registrar Comida' : '¡Hora de comer!'),
      actions: [
        if (tray != null && tray.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Vaciar bandeja',
            onPressed: () =>
                context.read<NutritionBloc>().add(ClearTray()),
          ),
      ],
    );
  }
}

// ── Widget: Sección bandeja ────────────────────────────────────────────────

class _TraySection extends StatelessWidget {
  final List<TrayItem> tray;
  final bool isAdult;

  const _TraySection({required this.tray, required this.isAdult});

  @override
  Widget build(BuildContext context) {
    final totalCarbs = tray.fold(0.0, (s, i) => s + i.carbs);
    final totalCG = tray.fold(0.0, (s, i) => s + i.glycemicLoad);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Row(
              children: [
                const Icon(Icons.restaurant_menu, size: 18),
                const SizedBox(width: 8),
                Text('Mi bandeja',
                    style: Theme.of(context).textTheme.titleSmall),
                const Spacer(),
                Text(
                  '${totalCarbs.toStringAsFixed(1)} g CHO  ·  CG ${totalCG.toStringAsFixed(1)}',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
          ...tray.asMap().entries.map((e) {
            final idx = e.key;
            final item = e.value;
            return ListTile(
              dense: true,
              leading: Text(
                '${item.grams.toStringAsFixed(0)}g',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              title: Text(item.ingredient.name),
              subtitle:
                  Text('${item.carbs.toStringAsFixed(1)} g CHO'),
              trailing: IconButton(
                icon: const Icon(Icons.remove_circle_outline,
                    color: Colors.red, size: 20),
                onPressed: () => context
                    .read<NutritionBloc>()
                    .add(RemoveIngredientFromTray(idx)),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Widget: Resultado del cálculo de bolus ────────────────────────────────

class _BolusTrayResultScreen extends StatefulWidget {
  final TrayBolusCalculated state;
  final bool isAdult;
  final void Function(List<TrayItem> tray, double bolus) onCommit;
  final VoidCallback onBack;

  const _BolusTrayResultScreen({
    required this.state,
    required this.isAdult,
    required this.onCommit,
    required this.onBack,
  });

  @override
  State<_BolusTrayResultScreen> createState() =>
      _BolusTrayResultScreenState();
}

class _BolusTrayResultScreenState extends State<_BolusTrayResultScreen> {
  late TextEditingController _doseController;

  @override
  void initState() {
    super.initState();
    _doseController = TextEditingController(
      text: widget.state.result.recommendedBolusUnits.toStringAsFixed(1),
    );
  }

  @override
  void dispose() {
    _doseController.dispose();
    super.dispose();
  }

  Color _bolusColor(double units) {
    if (units <= 2) return Colors.green;
    if (units <= 5) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final rec = widget.state.result;
    final tray = widget.state.tray;
    final totalCarbs = tray.fold(0.0, (s, i) => s + i.carbs);
    final totalCG = tray.fold(0.0, (s, i) => s + i.glycemicLoad);

    if (!widget.isAdult) {
      return _buildChildResult(context, rec, tray);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultado del Bolus'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Desglose de la bandeja ────────────────────────────
            Text('Comida registrada',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...tray.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      const Icon(Icons.circle, size: 6),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.ingredient.name)),
                      Text('${item.grams.toStringAsFixed(0)} g'),
                      const SizedBox(width: 8),
                      Text(
                        '${item.carbs.toStringAsFixed(1)} g CHO',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                )),
            const Divider(height: 24),

            // ── Totales ────────────────────────────────────────────
            _StatRow('Total carbohidratos', '${totalCarbs.toStringAsFixed(1)} g'),
            _StatRow('Carga glucémica', totalCG.toStringAsFixed(1)),
            const SizedBox(height: 24),

            // ── Bolus recomendado ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: _bolusColor(rec.recommendedBolusUnits).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: _bolusColor(rec.recommendedBolusUnits), width: 1.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bolus Sugerido',
                          style: Theme.of(context).textTheme.titleMedium),
                      Text('Comida + corrección',
                          style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                  Text(
                    '${rec.recommendedBolusUnits.toStringAsFixed(2)} U',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _bolusColor(rec.recommendedBolusUnits),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // ── Dosis real administrada ────────────────────────────
            Text('Dosis que vas a administrar',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _doseController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                suffixText: 'U',
                border: OutlineInputBorder(),
                helperText: 'Puedes ajustar la dosis real',
              ),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  final dose =
                      double.tryParse(_doseController.text) ?? 0;
                  widget.onCommit(tray, dose);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Registrar Comida'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildResult(
      BuildContext context, BolusCalculationResponse rec, List<TrayItem> tray) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.stars, size: 90, color: Colors.amber),
              const SizedBox(height: 16),
              const Text(
                '¡Lista tu poción!',
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.green),
              ),
              const SizedBox(height: 24),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${rec.recommendedBolusUnits.toStringAsFixed(1)} Unidades',
                  style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: () {
                  widget.onCommit(
                      tray, rec.recommendedBolusUnits);
                },
                icon: const Icon(Icons.check),
                label: const Text('¡Me la pongo!'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Volver a la bandeja'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;
  const _StatRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
