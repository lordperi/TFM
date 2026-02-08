import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/auth_models.dart';

part 'auth_api_client.g.dart';

// ==========================================
// AUTH API CLIENT (Retrofit)
// ==========================================

@RestApi()
abstract class AuthApiClient {
  factory AuthApiClient(Dio dio, {String baseUrl}) = _AuthApiClient;

  /// POST /api/v1/auth/login
  /// Content-Type: application/x-www-form-urlencoded
  @POST('/api/v1/auth/login')
  @FormUrlEncoded()
  Future<LoginResponse> login(
    @Field('username') String username,
    @Field('password') String password,
  );

  /// POST /api/v1/users/register
  /// Content-Type: application/json
  @POST('/api/v1/users/register')
  Future<UserPublicResponse> register(
    @Body() UserCreateRequest request,
  );
  @GET('/api/v1/users/me')
  Future<UserPublicResponse> getMe();
}
