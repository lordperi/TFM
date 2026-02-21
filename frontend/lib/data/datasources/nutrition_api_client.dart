import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/nutrition_models.dart';

part 'nutrition_api_client.g.dart';

@RestApi()
abstract class NutritionApiClient {
  factory NutritionApiClient(Dio dio, {String baseUrl}) = _NutritionApiClient;

  @GET('/api/v1/nutrition/ingredients')
  Future<List<Ingredient>> searchIngredients(@Query('q') String query);

  @POST('/api/v1/nutrition/bolus/calculate')
  Future<BolusCalculationResponse> calculateBolus(@Body() BolusCalculationRequest request);

  @POST('/api/v1/nutrition/meals')
  Future<dynamic> logMeal(@Body() Map<String, dynamic> request);

  @GET('/api/v1/nutrition/meals/history')
  Future<List<MealLogEntry>> getMealHistory(
    @Query('patient_id') String patientId, {
    @Query('limit') int limit = 20,
    @Query('offset') int offset = 0,
    @Query('start_date') String? startDate,
    @Query('end_date') String? endDate,
  });
}
