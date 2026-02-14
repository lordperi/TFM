import 'package:flutter_test/flutter_test.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';
import 'package:diabeaty_mobile/core/constants/diabetes_type.dart';
import 'dart:convert';

void main() {
  test('Verify UserCreateRequest JSON serialization', () {
    final healthProfile = HealthProfileCreate(
      diabetesType: DiabetesType.none.value, // Expecting "NONE"
      therapyType: null,
      insulinSensitivity: null,
      carbRatio: null,
      targetGlucose: null,
      basalInsulin: null,
    );

    final request = UserCreateRequest(
      email: 'test@test.com',
      password: 'password',
      fullName: 'Test',
      healthProfile: healthProfile,
    );

    final jsonMap = request.toJson();
    print('Generated JSON:');
    print(jsonEncode(jsonMap));
  });
}
