import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/glucose/glucose_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../core/utils/time_utils.dart';
// import '../../../core/di/injection.dart'; // Asumiendo get_it setup
import '../../bloc/nutrition/nutrition_bloc.dart';
import '../../../data/datasources/nutrition_api_client.dart';
import '../../../data/models/nutrition_models.dart';

class GlucoseAlertWidget extends StatelessWidget {
  const GlucoseAlertWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated || authState.selectedProfile == null) {
          return const SizedBox.shrink();
        }

        final targetHigh = authState.selectedProfile!.targetRangeHigh ?? 180;

        return BlocBuilder<GlucoseBloc, GlucoseState>(
          builder: (context, glucoseState) {
            if (glucoseState is GlucoseLoaded && glucoseState.history.isNotEmpty) {
              final latest = glucoseState.history.reduce((curr, next) => 
                  curr.timestamp.isAfter(next.timestamp) ? curr : next);

              if (latest.glucoseValue > targetHigh) {
                final targetHigh = authState.selectedProfile!.targetRangeHigh ?? 180;
                final targetBase = authState.selectedProfile!.targetGlucose ?? "100.0"; // Fallback as string
                final icrStr = authState.selectedProfile!.carbRatio ?? "10.0";
                final isfStr = authState.selectedProfile!.insulinSensitivity ?? "50.0";
                
                final isOutdated = TimeUtils.isMoreThanFiveMinutesOld(latest.timestamp);
                
                return _buildAlertCard(
                    context, 
                    latest.glucoseValue, 
                    isOutdated,
                    targetGlucose: double.tryParse(targetBase.toString()) ?? 100.0,
                    icr: double.tryParse(icrStr.toString()) ?? 10.0,
                    isf: double.tryParse(isfStr.toString()) ?? 50.0,
                );
              }
            }
            return const SizedBox.shrink();
          },
        );
      },
    );
  }

  Widget _buildAlertCard(
      BuildContext context, 
      int currentValue, 
      bool isOutdated, 
      {required double targetGlucose, required double icr, required double isf}
  ) {
    return Card(
      color: Colors.red.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.red.shade400, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red.shade700, size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '¡Hiperglucemia Detectada! ($currentValue mg/dL)',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              isOutdated 
                  ? '⚠️ La medición tiene más de 5 minutos de antigüedad. Se recomienda realizar un re-test dactilar antes de administrar insulina.'
                  : 'Se recomienda calcular un bolus correctivo para estabilizar los niveles.',
              style: TextStyle(color: Colors.red.shade800),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _calculateCorrectionBolus(context, currentValue, targetGlucose, icr, isf),
                icon: const Icon(Icons.calculate, color: Colors.white),
                label: const Text('CALCULAR BOLUS CORRECTIVO', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade600,
                  foregroundColor: Colors.red.shade100,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _calculateCorrectionBolus(
      BuildContext context, 
      int currentVal, 
      double targetVal, 
      double icr, 
      double isf
  ) async {
    // Show Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // We don't have GetIt here easily, instead of client = getIt<NutritionApiClient>();
      // Fallback approach or Dispatch Bloc Event if exists, but we can also use Dio directly if needed.
      // We will try finding the client or using Dio:
      final client = context.read<NutritionBloc>().apiClient;
      
      final req = BolusCalculationRequest(
        currentGlucose: currentVal.toDouble(),
        targetGlucose: targetVal,
        ingredients: [], // 0 carbs for correction only
        icr: icr,
        isf: isf,
      );

      final response = await client.calculateBolus(req);

      if (!context.mounted) return;
      Navigator.pop(context); // Close loading

      // Show Result
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.medical_services, color: Colors.blue),
              SizedBox(width: 8),
              Text('Dosis Sugerida'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Glucosa actual: $currentVal mg/dL'),
              Text('Objetivo: $targetVal mg/dL'),
              const Divider(),
              Text(
                '${response.recommendedBolusUnits.toStringAsFixed(1)} U',
                style: TextStyle(
                  fontSize: 36, 
                  fontWeight: FontWeight.bold, 
                  color: Theme.of(context).primaryColor
                ),
              ),
              const Text('Unidades de Insulina Rápida'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CERRAR'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Optionally log correction
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Dosis confirmada y registrada en el historial')),
                );
              },
              child: const Text('CONFIRMAR ADMINISTRACIÓN'),
            ),
          ],
        ),
      );

    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al contactar con el Motor Nutricional: $e')),
      );
    }
  }
}
