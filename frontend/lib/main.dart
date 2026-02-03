import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'core/theme/app_theme.dart';
import 'core/network/dio_client.dart';
import 'core/constants/app_constants.dart';
import 'data/datasources/auth_api_client.dart';
import 'presentation/bloc/auth/auth_bloc.dart';
import 'presentation/bloc/theme/theme_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';

// ==========================================
// MAIN APPLICATION
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final secureStorage = const FlutterSecureStorage();
  final sharedPreferences = await SharedPreferences.getInstance();
  final dioClient = DioClient(secureStorage);
  final authApiClient = AuthApiClient(
    dioClient.dio,
    baseUrl: ApiConstants.baseUrl,
  );

  runApp(
    DiaBetyApp(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
      authApiClient: authApiClient,
    ),
  );
}

class DiaBetyApp extends StatelessWidget {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;
  final AuthApiClient authApiClient;

  const DiaBetyApp({
    super.key,
    required this.secureStorage,
    required this.sharedPreferences,
    required this.authApiClient,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Theme BLoC
        BlocProvider(
          create: (context) => ThemeBloc(prefs: sharedPreferences)
            ..add(const LoadSavedTheme()),
        ),
        // Auth BLoC
        BlocProvider(
          create: (context) => AuthBloc(
            authApiClient: authApiClient,
            secureStorage: secureStorage,
          )..add(const CheckAuthStatus()),
        ),
      ],
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'DiaBeaty',
            debugShowCheckedModeBanner: false,
            theme: themeState.uiMode.isAdult
                ? AppTheme.adultTheme
                : AppTheme.childTheme,
            home: BlocBuilder<AuthBloc, AuthState>(
              builder: (context, authState) {
                if (authState is AuthAuthenticated) {
                  // TODO: Navigate to Home Screen
                  // Navegación basada en estado
                  if (authState is AuthAuthenticated) {
                    return const DashboardScreen();
                  }
                  // Si no está autenticado o hubo error, volver al login
                  return const LoginScreen();
                }
                return const LoginScreen();
              },
            ),
          );
        },
      ),
    );
  }
}
