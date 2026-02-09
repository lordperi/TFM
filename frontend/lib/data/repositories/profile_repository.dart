import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diabeaty_mobile/data/models/profile_models.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';
import 'package:diabeaty_mobile/core/constants/app_constants.dart';

class ProfileRepository {
  final String baseUrl;
  final http.Client client;

  ProfileRepository({String? baseUrl, http.Client? client})
      : client = client ?? http.Client(),
        baseUrl = baseUrl ?? AppConstants.apiBaseUrl;

  /// Get current user profile
  Future<UserPublicResponse> getProfile(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/users/me'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserPublicResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load profile');
    }
  }

  /// Update health profile
  Future<HealthProfile> updateHealthProfile(
    String token,
    HealthProfileUpdate update,
  ) async {
    final response = await client.patch(
      Uri.parse('$baseUrl/api/v1/users/me/health-profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(update.toJson()),
    );

    if (response.statusCode == 200) {
      return HealthProfile.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else if (response.statusCode == 404) {
      throw Exception('Health profile not found');
    } else {
      throw Exception('Failed to update health profile');
    }
  }

  /// Change password
  Future<void> changePassword(
    String token,
    PasswordChangeRequest passwordChange,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/users/me/change-password'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(passwordChange.toJson()),
    );

    if (response.statusCode == 200) {
      return; // Success
    } else if (response.statusCode == 400) {
      final error = json.decode(response.body);
      throw Exception(error['detail'] ?? 'Bad request');
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to change password');
    }
  }

  /// Get XP history
  Future<List<XPTransaction>> getXPHistory(
    String token, {
    int limit = 50,
    int skip = 0,
  }) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/users/me/xp-history?limit=$limit&skip=$skip'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => XPTransaction.fromJson(json)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load XP history');
    }
  }

  /// Get XP summary
  Future<UserXPSummary> getXPSummary(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/users/me/xp-summary'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return UserXPSummary.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load XP summary');
    }
  }

  /// Get achievements
  Future<AchievementsResponse> getAchievements(String token) async {
    final response = await client.get(
      Uri.parse('$baseUrl/api/v1/users/me/achievements'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return AchievementsResponse.fromJson(json.decode(response.body));
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized');
    } else {
      throw Exception('Failed to load achievements');
    }
  }
}
