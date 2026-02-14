
import 'package:json_annotation/json_annotation.dart';

part 'glucose_models.g.dart';

enum GlucoseType {
  @JsonValue('FINGER')
  finger,
  @JsonValue('CGM')
  cgm,
  @JsonValue('MANUAL')
  manual,
}

@JsonSerializable()
class GlucoseMeasurement {
  final String id;
  @JsonKey(name: 'patient_id')
  final String patientId;
  @JsonKey(name: 'glucose_value')
  final int glucoseValue;
  final DateTime timestamp;
  @JsonKey(name: 'measurement_type')
  final GlucoseType measurementType;
  final String? notes;

  GlucoseMeasurement({
    required this.id,
    required this.patientId,
    required this.glucoseValue,
    required this.timestamp,
    this.measurementType = GlucoseType.finger,
    this.notes,
  });

  factory GlucoseMeasurement.fromJson(Map<String, dynamic> json) =>
      _$GlucoseMeasurementFromJson(json);

  Map<String, dynamic> toJson() => _$GlucoseMeasurementToJson(this);
}

@JsonSerializable()
class GlucoseCreateRequest {
  final int value;
  final DateTime timestamp;
  @JsonKey(name: 'measurement_type')
  final GlucoseType measurementType;
  final String? notes;

  GlucoseCreateRequest({
    required this.value,
    required this.timestamp,
    this.measurementType = GlucoseType.finger,
    this.notes,
  });

  Map<String, dynamic> toJson() => _$GlucoseCreateRequestToJson(this);
}
