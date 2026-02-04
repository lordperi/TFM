import '../datasources/family_api_client.dart';
import '../models/family_models.dart';

class FamilyRepository {
  final FamilyApiClient _apiClient;

  FamilyRepository(this._apiClient);

  Future<List<PatientProfile>> getProfiles() async {
    return await _apiClient.getProfiles();
  }

  Future<PatientProfile> createProfile(CreatePatientRequest request) async {
    return await _apiClient.createProfile(request);
  }
}
