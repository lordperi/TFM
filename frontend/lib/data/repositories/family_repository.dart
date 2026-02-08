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

  Future<bool> verifyPin(String patientId, String pin) async {
    return await _apiClient.verifyPin(patientId, pin);
  }

  Future<void> updateProfile(String id, PatientUpdateRequest request) async {
    await _apiClient.updateProfile(id, request);
  }

  Future<PatientProfile> getProfileDetails(String id) async {
    return await _apiClient.getProfileDetails(id);
  }
}
