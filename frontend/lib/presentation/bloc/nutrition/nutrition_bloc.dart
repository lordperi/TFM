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

/// Añade un ingrediente con su cantidad a la bandeja activa.
class AddIngredientToTray extends NutritionEvent {
  final Ingredient ingredient;
  final double grams;
  const AddIngredientToTray(this.ingredient, this.grams);

  @override
  List<Object?> get props => [ingredient, grams];
}

/// Elimina el ítem en la posición [index] de la bandeja.
class RemoveIngredientFromTray extends NutritionEvent {
  final int index;
  const RemoveIngredientFromTray(this.index);

  @override
  List<Object?> get props => [index];
}

/// Calcula el bolus para todos los ingredientes en la bandeja.
class CalculateBolusForTray extends NutritionEvent {
  final int currentGlucose;
  final double icr;
  final double isf;
  final double targetGlucose;

  const CalculateBolusForTray({
    required this.currentGlucose,
    this.icr = 10.0,
    this.isf = 50.0,
    this.targetGlucose = 100.0,
  });

  @override
  List<Object?> get props => [currentGlucose, icr, isf, targetGlucose];
}

/// Registra la comida de la bandeja con la dosis real administrada.
class CommitMealFromTray extends NutritionEvent {
  final String patientId;
  final double bolusUnitsAdministered;
  const CommitMealFromTray(this.patientId, this.bolusUnitsAdministered);

  @override
  List<Object?> get props => [patientId, bolusUnitsAdministered];
}

/// Limpia la bandeja y vuelve al estado inicial.
class ClearTray extends NutritionEvent {}

// ── Eventos heredados ──────────────────────────────────────────────────────

class CalculateBolus extends NutritionEvent {
  final int grams;
  final int currentGlucose;
  final double icr;
  final double isf;
  final double targetGlucose;

  const CalculateBolus({
    required this.grams,
    required this.currentGlucose,
    this.icr = 10.0,
    this.isf = 50.0,
    this.targetGlucose = 100.0,
  });

  @override
  List<Object?> get props => [grams, currentGlucose, icr, isf, targetGlucose];
}

class ResetNutrition extends NutritionEvent {}

class LoadMealHistory extends NutritionEvent {
  final String patientId;
  final int limit;
  final int offset;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadMealHistory(
    this.patientId, {
    this.limit = 20,
    this.offset = 0,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object?> get props => [patientId, limit, offset, startDate, endDate];
}

class LogInsulinDose extends NutritionEvent {
  final String patientId;
  final double units;
  const LogInsulinDose(this.patientId, this.units);

  @override
  List<Object?> get props => [patientId, units];
}

// ==========================================
// STATES
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

/// Estado de la bandeja multi-ingrediente.
/// Contiene los ítems añadidos y, opcionalmente, los resultados de búsqueda
/// más recientes para mostrar ambas secciones a la vez en LogMealScreen.
class MealTrayUpdated extends NutritionState {
  final List<TrayItem> tray;
  final List<Ingredient> searchResults;

  const MealTrayUpdated({
    required this.tray,
    this.searchResults = const [],
  });

  double get totalCarbs =>
      tray.fold(0.0, (sum, item) => sum + item.carbs);

  double get totalGlycemicLoad =>
      tray.fold(0.0, (sum, item) => sum + item.glycemicLoad);

  MealTrayUpdated copyWith({
    List<TrayItem>? tray,
    List<Ingredient>? searchResults,
  }) {
    return MealTrayUpdated(
      tray: tray ?? this.tray,
      searchResults: searchResults ?? this.searchResults,
    );
  }

  @override
  List<Object?> get props => [tray, searchResults];
}

/// Resultado del cálculo de bolus para la bandeja completa.
class TrayBolusCalculated extends NutritionState {
  final BolusCalculationResponse result;
  final List<TrayItem> tray;

  const TrayBolusCalculated({required this.result, required this.tray});

  @override
  List<Object?> get props => [result, tray];
}

class NutritionError extends NutritionState {
  final String message;
  const NutritionError(this.message);

  @override
  List<Object?> get props => [message];
}

class MealHistoryLoaded extends NutritionState {
  final List<MealLogEntry> meals;
  const MealHistoryLoaded(this.meals);

  @override
  List<Object?> get props => [meals];
}

class MealCommitted extends NutritionState {}

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
    on<LoadMealHistory>(_onLoadMealHistory);
    on<LogInsulinDose>(_onLogInsulinDose);

    // ── Bandeja multi-ingrediente ─────────────────────────────────────────
    on<AddIngredientToTray>(_onAddIngredientToTray);
    on<RemoveIngredientFromTray>(_onRemoveIngredientFromTray);
    on<CalculateBolusForTray>(_onCalculateBolusForTray);
    on<CommitMealFromTray>(_onCommitMealFromTray);
    on<ClearTray>((event, emit) => emit(NutritionInitial()));
  }

  // ── Búsqueda ─────────────────────────────────────────────────────────────

  Future<void> _onSearchIngredients(
    SearchIngredients event,
    Emitter<NutritionState> emit,
  ) async {
    if (event.query.length < 2) {
      // Si tenemos una bandeja activa, mantenemos su estado sin results
      if (state is MealTrayUpdated) {
        emit((state as MealTrayUpdated).copyWith(searchResults: []));
      }
      return;
    }

    // Si la bandeja está activa, no emitimos NutritionLoading global
    if (state is! MealTrayUpdated) emit(NutritionLoading());

    try {
      final results = await _apiClient.searchIngredients(event.query);
      if (state is MealTrayUpdated) {
        emit((state as MealTrayUpdated).copyWith(searchResults: results));
      } else {
        emit(IngredientsLoaded(results));
      }
    } catch (e) {
      emit(NutritionError('Error buscando: $e'));
    }
  }

  void _onSelectIngredient(SelectIngredient event, Emitter<NutritionState> emit) {
    _selectedIngredient = event.ingredient;
  }

  // ── Bandeja ───────────────────────────────────────────────────────────────

  void _onAddIngredientToTray(
    AddIngredientToTray event,
    Emitter<NutritionState> emit,
  ) {
    final currentTray =
        state is MealTrayUpdated ? (state as MealTrayUpdated).tray : <TrayItem>[];
    final currentResults =
        state is MealTrayUpdated ? (state as MealTrayUpdated).searchResults : <Ingredient>[];

    emit(MealTrayUpdated(
      tray: [...currentTray, TrayItem(event.ingredient, event.grams)],
      searchResults: currentResults,
    ));
  }

  void _onRemoveIngredientFromTray(
    RemoveIngredientFromTray event,
    Emitter<NutritionState> emit,
  ) {
    if (state is! MealTrayUpdated) return;
    final current = state as MealTrayUpdated;
    final newTray = List<TrayItem>.from(current.tray)..removeAt(event.index);
    emit(current.copyWith(tray: newTray));
  }

  Future<void> _onCalculateBolusForTray(
    CalculateBolusForTray event,
    Emitter<NutritionState> emit,
  ) async {
    if (state is! MealTrayUpdated) return;
    final tray = (state as MealTrayUpdated).tray;
    if (tray.isEmpty) return;

    emit(NutritionLoading());
    try {
      final request = BolusCalculationRequest(
        currentGlucose: event.currentGlucose.toDouble(),
        targetGlucose: event.targetGlucose,
        ingredients: tray
            .map((item) => IngredientInput(
                  ingredientId: item.ingredient.id.toString(),
                  weightGrams: item.grams,
                ))
            .toList(),
        icr: event.icr,
        isf: event.isf,
      );

      final response = await _apiClient.calculateBolus(request);
      emit(TrayBolusCalculated(result: response, tray: tray));
    } catch (e) {
      emit(NutritionError('Error calculando bolus: $e'));
    }
  }

  Future<void> _onCommitMealFromTray(
    CommitMealFromTray event,
    Emitter<NutritionState> emit,
  ) async {
    List<TrayItem> tray = [];
    if (state is TrayBolusCalculated) {
      tray = (state as TrayBolusCalculated).tray;
    } else if (state is MealTrayUpdated) {
      tray = (state as MealTrayUpdated).tray;
    }

    emit(NutritionLoading());
    try {
      await _apiClient.logMeal({
        'patient_id': event.patientId,
        'ingredients': tray
            .map((item) => {
                  'ingredient_id': item.ingredient.id.toString(),
                  'weight_grams': item.grams,
                })
            .toList(),
        'bolus_units_administered': event.bolusUnitsAdministered,
      });

      final meals = await _apiClient.getMealHistory(event.patientId);
      emit(MealHistoryLoaded(meals));
    } catch (e) {
      emit(NutritionError('Error registrando comida: $e'));
    }
  }

  // ── Historial y dosis heredados ───────────────────────────────────────────

  Future<void> _onLoadMealHistory(
    LoadMealHistory event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionLoading());
    try {
      final meals = await _apiClient.getMealHistory(
        event.patientId,
        limit: event.limit,
        offset: event.offset,
        startDate: event.startDate?.toUtc().toIso8601String(),
        endDate: event.endDate?.toUtc().toIso8601String(),
      );
      emit(MealHistoryLoaded(meals));
    } catch (e) {
      emit(NutritionError('Error cargando historial: $e'));
    }
  }

  Future<void> _onLogInsulinDose(
    LogInsulinDose event,
    Emitter<NutritionState> emit,
  ) async {
    emit(NutritionLoading());
    try {
      await _apiClient.logMeal({
        'patient_id': event.patientId,
        'ingredients': [],
        'bolus_units_administered': event.units,
      });
      final meals = await _apiClient.getMealHistory(event.patientId);
      emit(MealHistoryLoaded(meals));
    } catch (e) {
      emit(NutritionError('Error registrando dosis: $e'));
    }
  }

  Future<void> _onCalculateBolus(
    CalculateBolus event,
    Emitter<NutritionState> emit,
  ) async {
    if (_selectedIngredient == null) {
      emit(const NutritionError('No has seleccionado un alimento'));
      return;
    }
    emit(NutritionLoading());
    try {
      final request = BolusCalculationRequest(
        currentGlucose: event.currentGlucose.toDouble(),
        targetGlucose: event.targetGlucose,
        ingredients: [
          IngredientInput(
            ingredientId: _selectedIngredient!.id.toString(),
            weightGrams: event.grams.toDouble(),
          )
        ],
        icr: event.icr,
        isf: event.isf,
      );
      final response = await _apiClient.calculateBolus(request);
      emit(BolusCalculated(
        result: response,
        food: _selectedIngredient!,
        grams: event.grams,
      ));
    } catch (e) {
      emit(NutritionError('Error calculando: $e'));
    }
  }
}
