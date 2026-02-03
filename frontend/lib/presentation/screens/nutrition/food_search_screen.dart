import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../bloc/theme/theme_bloc.dart';
import '../../../core/constants/app_constants.dart';

class FoodSearchScreen extends StatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  State<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends State<FoodSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Detectamos modo para UI
    final isAdult = context.select((ThemeBloc bloc) => bloc.state.uiMode.isAdult);

    return Scaffold(
      appBar: AppBar(
        title: Text(isAdult ? 'Buscar Alimento' : '¿Qué vas a comer?'),
      ),
      body: BlocConsumer<NutritionBloc, NutritionState>(
        listener: (context, state) {
          if (state is NutritionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BolusCalculated) {
            return _ResultView(state: state, isAdult: isAdult);
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: isAdult ? 'Ej. Arroz, Manzana...' : 'Busca tu comida...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: isAdult ? Colors.white : Colors.yellow.shade50,
                  ),
                  onChanged: (value) {
                    context.read<NutritionBloc>().add(SearchIngredients(value));
                  },
                ),
              ),
              if (state is NutritionLoading)
                const LinearProgressIndicator(),
              
              if (state is IngredientsLoaded)
                Expanded(
                  child: ListView.builder(
                    itemCount: state.ingredients.length,
                    itemBuilder: (context, index) {
                      final item = state.ingredients[index];
                      return ListTile(
                        leading: const Icon(Icons.fastfood), // Placeholder icon
                        title: Text(item.name),
                        subtitle: isAdult ? Text('${item.carbs}g CHO / 100g') : null,
                        onTap: () => _showGramsDialog(context, item, isAdult),
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  void _showGramsDialog(BuildContext context, dynamic ingredient, bool isAdult) {
    final gramsController = TextEditingController();
    
    // Select ingredient logic in bloc if needed, currently direct calculate
    context.read<NutritionBloc>().add(SelectIngredient(ingredient));

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAdult ? 'Cantidad' : '¿Cuánto vas a comer?'),
        content: TextField(
          controller: gramsController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Gramos (g)',
            suffixText: 'g',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final grams = int.tryParse(gramsController.text) ?? 0;
              if (grams > 0) {
                // Trigger calculation
                context.read<NutritionBloc>().add(CalculateBolus(
                  grams: grams,
                  currentGlucose: 120, // MOCKED: Get from real glucose stream later
                ));
                Navigator.pop(ctx);
              }
            },
            child: const Text('Calcular'),
          ),
        ],
      ),
    );
  }
}

class _ResultView extends StatelessWidget {
  final BolusCalculated state;
  final bool isAdult;

  const _ResultView({required this.state, required this.isAdult});

  @override
  Widget build(BuildContext context) {
    // Child Mode Result (Gamified)
    if (!isAdult) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.stars, size: 100, color: Colors.amber),
            const SizedBox(height: 20),
            const Text(
              '¡Energía Lista!',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.green),
            ),
            const SizedBox(height: 10),
            Text(
              'Necesitas tu poción mágica:',
               style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                '${state.result.totalBolus.toStringAsFixed(1)} Unidades',
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blue),
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                context.read<NutritionBloc>().add(ResetNutrition());
              },
              child: const Text('¡A Comer!'),
            ),
          ],
        ),
      );
    }

    // Adult Mode Result (Data Driven)
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              'Resultado del Cálculo',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 40),
          _buildItem(context, 'Alimento:', state.food.name),
          _buildItem(context, 'Cantidad:', '${state.grams} g'),
          const Divider(height: 40),
          _buildItem(context, 'Total Carbohidratos:', '${((state.food.carbs * state.grams) / 100).toStringAsFixed(1)} g'),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Insulina Sugerida', style: Theme.of(context).textTheme.titleMedium),
                    Text('(Ratio + Corrección)', style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
                Text(
                  '${state.result.totalBolus.toStringAsFixed(2)} U',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context.read<NutritionBloc>().add(ResetNutrition());
                 // Optionally navigate back
              },
              child: const Text('Registrar Dosis'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 18)),
        ],
      ),
    );
  }
}
