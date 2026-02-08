import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';
import '../models/family_models.dart';

class FamilyApiClient {
  final Dio _dio;
  final String baseUrl;

  FamilyApiClient(this._dio, {required this.baseUrl});

  Future<List<PatientProfile>> getProfiles() async {
    try {
      final response = await _dio.get('$baseUrl${ApiConstants.apiVersion}/family/members');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data;
        return data.map((json) => PatientProfile.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load profiles');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<PatientProfile> createProfile(CreatePatientRequest request) async {
    final response = await _dio.post(
      '$baseUrl${ApiConstants.apiVersion}/family/members',
      data: request.toJson(),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
        return PatientProfile(
            id: response.data['id'],
            displayName: request.displayName,
            themePreference: request.themePreference,
            role: request.role,
            isProtected: request.pin != null && request.pin!.isNotEmpty,
        ); 
    } else {
      throw Exception('Failed to create profile');
    }
  }

  Future<bool> verifyPin(String patientId, String pin) async {
    try {
      final response = await _dio.post(
        '$baseUrl${ApiConstants.apiVersion}/family/members/$patientId/verify-pin',
        data: {'pin': pin},
      );
      return response.statusCode == 200;
    } catch (e) {
      if (e is DioException && e.response?.statusCode == 401) {
        return false;
      }
      throw Exception('Failed to verify PIN: $e');
    }
  }

  Future<void> updateProfile(String id, PatientUpdateRequest request) async {
    final response = await _dio.patch(
      '$baseUrl${ApiConstants.apiVersion}/family/members/$id',
      data: request.toJson(),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update profile');
    }
  }

  Future<PatientProfile> getProfileDetails(String id) async {
    final response = await _dio.get('$baseUrl${ApiConstants.apiVersion}/family/members/$id');
    if (response.statusCode == 200) {
      return PatientProfile.fromJson(response.data);
    } else {
      throw Exception('Failed to load profile details');
    }
  }
}
