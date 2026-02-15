
part of 'glucose_bloc.dart';

abstract class GlucoseEvent extends Equatable {
  const GlucoseEvent();

  @override
  List<Object> get props => [];
}

class LoadGlucoseHistory extends GlucoseEvent {
  final String patientId;
  final int limit;
  final int offset;
  final DateTime? startDate;
  final DateTime? endDate;

  const LoadGlucoseHistory(
    this.patientId, {
    this.limit = 20,
    this.offset = 0,
    this.startDate,
    this.endDate,
  });

  @override
  List<Object> get props => [patientId, limit, offset, startDate ?? '', endDate ?? ''];
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
