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

    if (response.statusCode == 201) {
        // Ideally returns full object, MVP might return just ID. 
        // For now determining simplistic return or fetch again.
        // Assuming we need to refetch or construct locally.
        return PatientProfile(
            id: response.data['id'],
            displayName: request.displayName,
            themePreference: request.themePreference
        ); 
    } else {
      throw Exception('Failed to create profile');
    }
  }
}
