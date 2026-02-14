
part of 'glucose_bloc.dart';

abstract class GlucoseEvent extends Equatable {
  const GlucoseEvent();

  @override
  List<Object> get props => [];
}

class LoadGlucoseHistory extends GlucoseEvent {
  final String patientId;

  const LoadGlucoseHistory(this.patientId);

  @override
  List<Object> get props => [patientId];
}

class AddGlucoseMeasurement extends GlucoseEvent {
  final String patientId;
  final int value;
  final DateTime timestamp;
  final GlucoseType type;
  final String? notes;

  const AddGlucoseMeasurement({
    required this.patientId,
    required this.value,
    required this.timestamp,
    required this.type,
    this.notes,
  });

  @override
  List<Object> get props => [patientId, value, timestamp, type, notes ?? ''];
}
