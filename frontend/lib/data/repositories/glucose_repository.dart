
import 'package:diabeaty_mobile/data/datasources/glucose_api_client.dart';
import 'package:diabeaty_mobile/data/models/glucose_models.dart';

class GlucoseRepository {
  final GlucoseApiClient _apiClient;

  GlucoseRepository(this._apiClient);

  Future<GlucoseMeasurement> addMeasurement(
      String patientId, int value, DateTime timestamp, GlucoseType type,
      {String? notes}) async {
    final request = GlucoseCreateRequest(
      value: value,
      timestamp: timestamp,
      measurementType: type,
      notes: notes,
    );
    return await _apiClient.createMeasurement(request, patientId);
  }

  Future<List<GlucoseMeasurement>> getHistory(String patientId,
      {int limit = 20, int offset = 0}) async {
    return await _apiClient.getHistory(patientId, limit, offset);
  }
}
