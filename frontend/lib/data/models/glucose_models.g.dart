// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'glucose_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GlucoseMeasurement _$GlucoseMeasurementFromJson(Map<String, dynamic> json) =>
    GlucoseMeasurement(
      id: json['id'] as String,
      patientId: json['patient_id'] as String,
      glucoseValue: (json['glucose_value'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      measurementType:
          $enumDecodeNullable(_$GlucoseTypeEnumMap, json['measurement_type']) ??
              GlucoseType.finger,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$GlucoseMeasurementToJson(GlucoseMeasurement instance) =>
    <String, dynamic>{
      'id': instance.id,
      'patient_id': instance.patientId,
      'glucose_value': instance.glucoseValue,
      'timestamp': instance.timestamp.toIso8601String(),
      'measurement_type': _$GlucoseTypeEnumMap[instance.measurementType]!,
      'notes': instance.notes,
    };

const _$GlucoseTypeEnumMap = {
  GlucoseType.finger: 'FINGER',
  GlucoseType.cgm: 'CGM',
  GlucoseType.manual: 'MANUAL',
};

GlucoseCreateRequest _$GlucoseCreateRequestFromJson(
        Map<String, dynamic> json) =>
    GlucoseCreateRequest(
      value: (json['value'] as num).toInt(),
      timestamp: DateTime.parse(json['timestamp'] as String),
      measurementType:
          $enumDecodeNullable(_$GlucoseTypeEnumMap, json['measurement_type']) ??
              GlucoseType.finger,
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$GlucoseCreateRequestToJson(
        GlucoseCreateRequest instance) =>
    <String, dynamic>{
      'value': instance.value,
      'timestamp': instance.timestamp.toIso8601String(),
      'measurement_type': _$GlucoseTypeEnumMap[instance.measurementType]!,
      'notes': instance.notes,
    };
