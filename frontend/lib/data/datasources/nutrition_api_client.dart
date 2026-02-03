import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../models/nutrition_models.dart';

part 'nutrition_api_client.g.dart';

@RestApi()
abstract class NutritionApiClient {
  factory NutritionApiClient(Dio dio, {String baseUrl}) = _NutritionApiClient;

  @GET('/nutrition/ingredients')
  Future<List<Ingredient>> searchIngredients(@Query('q') String query);

  @POST('/nutrition/calculate-bolus')
  Future<BolusCalculationResponse> calculateBolus(@Body() BolusCalculationRequest request);
}
