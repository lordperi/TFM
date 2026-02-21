import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:rxdart/rxdart.dart';
import '../../../data/datasources/nutrition_api_client.dart';
import '../../../data/models/nutrition_models.dart';

// ==========================================
// EVENTS
// ==========================================

abstract class NutritionEvent extends Equatable {
  const NutritionEvent();

  @override
  List<Object?> get props => [];
}

class SearchIngredients extends NutritionEvent {
  final String query;

  const SearchIngredients(this.query);

  @override
  List<Object?> get props => [query];
}

class SelectIngredient extends NutritionEvent {
  final Ingredient ingredient;

  const SelectIngredient(this.ingredient);

  @override
  List<Object?> get props => [ingredient];
}

class CalculateBolus extends NutritionEvent {
  final int grams;
  final int currentGlucose; // Mocked or input for now

  const CalculateBolus({required this.grams, required this.currentGlucose});

  @override
  List<Object?> get props => [grams, currentGlucose];
}

class ResetNutrition extends NutritionEvent {}

// ==========================================
// STATE
// ==========================================

abstract class NutritionState extends Equatable {
  const NutritionState();

  @override
  List<Object?> get props => [];
}

class NutritionInitial extends NutritionState {}

class NutritionLoading extends NutritionState {}

class IngredientsLoaded extends NutritionState {
  final List<Ingredient> ingredients;

  const IngredientsLoaded(this.ingredients);

  @override
  List<Object?> get props => [ingredients];
}

class BolusCalculated extends NutritionState {
  final BolusCalculationResponse result;
  final Ingredient food;
  final int grams;

  const BolusCalculated({
    required this.result,
    required this.food,
    required this.grams,
  });

  @override
  List<Object?> get props => [result, food, grams];
}

class NutritionError extends NutritionState {
  final String message;

  const NutritionError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==========================================
// BLOC LOGIC
// ==========================================

class NutritionBloc extends Bloc<NutritionEvent, NutritionState> {
  final NutritionApiClient _apiClient;
  NutritionApiClient get apiClient => _apiClient;
  Ingredient? _selectedIngredient;

  NutritionBloc({required NutritionApiClient apiClient})
      : _apiClient = apiClient,
        super(NutritionInitial()) {
    
    // Search with Debounce
    on<SearchIngredients>(
      _onSearchIngredients,
      transformer: (events, mapper) => events
          .debounceTime(const Duration(milliseconds: 500))
          .switchMap(mapper),
    );

    on<SelectIngredient>(_onSelectIngredient);
    on<CalculateBolus>(_onCalculateBolus);
    on<ResetNutrition>((event, emit) {
      _selectedIngredient = null;
      emit(NutritionInitial());
    });
  }

  Future<void> _onSearchIngredients(
    SearchIngredients event,
    Emitter<NutritionState> emit,
  ) async {
    if (event.query.length < 2) return;
    
    emit(NutritionLoading());
    try {
      final results = await _apiClient.searchIngredients(event.query);
      emit(IngredientsLoaded(results));
    } catch (e) {
      emit(NutritionError("Error buscando: $e")); // Simplify error for now
    }
  }

  void _onSelectIngredient(
    SelectIngredient event,
    Emitter<NutritionState> emit,
  ) {
    _selectedIngredient = event.ingredient;
    // We stay in loaded state or move to a "ready to calculate" transient state
    // For simplicity, UI handles the selection modal, bloc just stores it implicitly if needed
    // or we can emit a specific state. Let's keep it simple: UI asks for calculation directly.
  }

  Future<void> _onCalculateBolus(
    CalculateBolus event,
    Emitter<NutritionState> emit,
  ) async {
    if (_selectedIngredient == null) {
      emit(const NutritionError("No has seleccionado un alimento"));
      return;
    }

    emit(NutritionLoading());
    try {
      // Logic: Calculate total carbs based on grams
      // Carbs per 100g -> (carbs * grams) / 100
      final totalCarbs = (_selectedIngredient!.carbs * event.grams) / 100;

      final request = BolusCalculationRequest(
        glucoseValue: event.currentGlucose,
        carbsGrams: totalCarbs.round(),
      );

      final response = await _apiClient.calculateBolus(request);
      
      emit(BolusCalculated(
        result: response,
        food: _selectedIngredient!,
        grams: event.grams,
      ));
    } catch (e) {
      emit(NutritionError("Error calculando: $e"));
    }
  }
}
