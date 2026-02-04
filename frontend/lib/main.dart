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
import 'data/datasources/nutrition_api_client.dart';
import 'presentation/bloc/nutrition/nutrition_bloc.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'data/datasources/family_api_client.dart';
import 'data/repositories/family_repository.dart';
import 'presentation/screens/profile/profile_selection_screen.dart';

// ==========================================
// MAIN APPLICATION
// ==========================================

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependencies
  final secureStorage = const FlutterSecureStorage();
  final sharedPreferences = await SharedPreferences.getInstance();
  // Dependencies
  final dioClient = DioClient(secureStorage);
  final authApiClient = AuthApiClient(
    dioClient.dio,
    baseUrl: ApiConstants.baseUrl,
  );
  final nutritionApiClient = NutritionApiClient(
    dioClient.dio,
    baseUrl: ApiConstants.baseUrl,
  );
  final familyApiClient = FamilyApiClient(
    dioClient.dio,
    baseUrl: ApiConstants.baseUrl,
  );
  final familyRepository = FamilyRepository(familyApiClient);

  runApp(
    DiaBetyApp(
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
      authApiClient: authApiClient,
      nutritionApiClient: nutritionApiClient,
      familyRepository: familyRepository,
    ),
  );
}

class DiaBetyApp extends StatelessWidget {
  final FlutterSecureStorage secureStorage;
  final SharedPreferences sharedPreferences;
  final AuthApiClient authApiClient;
  final NutritionApiClient nutritionApiClient;
  final FamilyRepository familyRepository;

  const DiaBetyApp({
    super.key,
    required this.secureStorage,
    required this.sharedPreferences,
    required this.authApiClient,
    required this.nutritionApiClient,
    required this.familyRepository,
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
            familyRepository: familyRepository,
          )..add(const CheckAuthStatus()),
        ),
        // Nutrition BLoC (Global access for now)
        BlocProvider(
          create: (context) => NutritionBloc(
            apiClient: nutritionApiClient,
          ),
        ),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, authState) {
          if (authState is AuthAuthenticated && authState.selectedProfile != null) {
             final isChild = authState.selectedProfile!.isChild;
             context.read<ThemeBloc>().add(SetUiMode(
                 isChild ? UiMode.child : UiMode.adult
             ));
          }
        },
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
                    if (authState.selectedProfile != null) {
                      return const DashboardScreen();
                    }
                    return const ProfileSelectionScreen();
                  }
                  return const LoginScreen();
                },
              ),
            );
          },
        ),
      ),
    );
  }
}
