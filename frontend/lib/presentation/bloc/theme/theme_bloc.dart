import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_constants.dart';

// ==========================================
// THEME BLOC - EVENTS
// ==========================================

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ToggleUiMode extends ThemeEvent {
  const ToggleUiMode();
}

class SetUiMode extends ThemeEvent {
  final UiMode mode;

  const SetUiMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class LoadSavedTheme extends ThemeEvent {
  const LoadSavedTheme();
}

// ==========================================
// THEME BLOC - STATES
// ==========================================

class ThemeState extends Equatable {
  final UiMode uiMode;

  const ThemeState({
    this.uiMode = UiMode.adult,
  });

  ThemeState copyWith({UiMode? uiMode}) {
    return ThemeState(
      uiMode: uiMode ?? this.uiMode,
    );
  }

  @override
  List<Object?> get props => [uiMode];
}

// ==========================================
// THEME BLOC - LOGIC
// ==========================================

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final SharedPreferences _prefs;

  ThemeBloc({required SharedPreferences prefs})
      : _prefs = prefs,
        super(const ThemeState()) {
    on<ToggleUiMode>(_onToggleUiMode);
    on<SetUiMode>(_onSetUiMode);
    on<LoadSavedTheme>(_onLoadSavedTheme);
  }

  Future<void> _onToggleUiMode(
    ToggleUiMode event,
    Emitter<ThemeState> emit,
  ) async {
    final newMode = state.uiMode == UiMode.adult ? UiMode.child : UiMode.adult;
    await _saveUiMode(newMode);
    emit(state.copyWith(uiMode: newMode));
  }

  Future<void> _onSetUiMode(
    SetUiMode event,
    Emitter<ThemeState> emit,
  ) async {
    await _saveUiMode(event.mode);
    emit(state.copyWith(uiMode: event.mode));
  }

  Future<void> _onLoadSavedTheme(
    LoadSavedTheme event,
    Emitter<ThemeState> emit,
  ) async {
    final savedMode = _prefs.getString(StorageKeys.uiMode);
    final uiMode = savedMode == 'child' ? UiMode.child : UiMode.adult;
    emit(state.copyWith(uiMode: uiMode));
  }

  Future<void> _saveUiMode(UiMode mode) async {
    await _prefs.setString(
      StorageKeys.uiMode,
      mode == UiMode.adult ? 'adult' : 'child',
    );
  }
}
