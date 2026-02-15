
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:diabeaty_mobile/data/models/glucose_models.dart';
import 'package:diabeaty_mobile/data/repositories/glucose_repository.dart';

part 'glucose_event.dart';
part 'glucose_state.dart';

class GlucoseBloc extends Bloc<GlucoseEvent, GlucoseState> {
  final GlucoseRepository glucoseRepository;

  GlucoseBloc({required this.glucoseRepository}) : super(GlucoseInitial()) {
    on<LoadGlucoseHistory>(_onLoadHistory);
    on<AddGlucoseMeasurement>(_onAddMeasurement);
  }

  Future<void> _onLoadHistory(
      LoadGlucoseHistory event, Emitter<GlucoseState> emit) async {
    emit(GlucoseLoading());
    try {
      final history = await glucoseRepository.getHistory(
        event.patientId,
        limit: event.limit,
        offset: event.offset,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(GlucoseLoaded(history));
    } catch (e) {
      emit(GlucoseError(e.toString()));
    }
  }

  Future<void> _onAddMeasurement(
      AddGlucoseMeasurement event, Emitter<GlucoseState> emit) async {
    emit(GlucoseAdding());
    try {
      await glucoseRepository.addMeasurement(
        event.patientId,
        event.value,
        event.timestamp,
        event.type,
        notes: event.notes,
      );
      emit(GlucoseAdded());
      // Refresh history
      add(LoadGlucoseHistory(event.patientId));
    } catch (e) {
      emit(GlucoseError(e.toString()));
    }
  }
}
