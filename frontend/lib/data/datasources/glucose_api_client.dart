
import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:diabeaty_mobile/data/models/glucose_models.dart';

part 'glucose_api_client.g.dart';

@RestApi(baseUrl: '/glucose')
abstract class GlucoseApiClient {
  factory GlucoseApiClient(Dio dio, {String baseUrl}) = _GlucoseApiClient;

  @POST('/')
  Future<GlucoseMeasurement> createMeasurement(
    @Body() GlucoseCreateRequest request,
    @Query('patient_id') String patientId,
  );

  @GET('/history')
  Future<List<GlucoseMeasurement>> getHistory(
    @Query('patient_id') String patientId,
    @Query('limit') int limit,
    @Query('offset') int offset,
  );
}
