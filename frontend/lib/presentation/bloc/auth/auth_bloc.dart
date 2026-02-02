import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../data/datasources/auth_api_client.dart';
import '../../../data/models/auth_models.dart';
import '../../../core/constants/app_constants.dart';

// ==========================================
// AUTH BLOC - EVENTS
// ==========================================

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String email;
  final String password;
  final String? fullName;
  final HealthProfileCreate healthProfile;

  const RegisterRequested({
    required this.email,
    required this.password,
    this.fullName,
    required this.healthProfile,
  });

  @override
  List<Object?> get props => [email, password, fullName, healthProfile];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}

class CheckAuthStatus extends AuthEvent {
  const CheckAuthStatus();
}

// ==========================================
// AUTH BLOC - STATES
// ==========================================

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final String accessToken;
  final UserPublicResponse? user;

  const AuthAuthenticated({
    required this.accessToken,
    this.user,
  });

  @override
  List<Object?> get props => [accessToken, user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==========================================
// AUTH BLOC - LOGIC
// ==========================================

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthApiClient _authApiClient;
  final FlutterSecureStorage _secureStorage;

  AuthBloc({
    required AuthApiClient authApiClient,
    required FlutterSecureStorage secureStorage,
  })  : _authApiClient = authApiClient,
        _secureStorage = secureStorage,
        super(const AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<RegisterRequested>(_onRegisterRequested);
    on<LogoutRequested>(_onLogoutRequested);
    on<CheckAuthStatus>(_onCheckAuthStatus);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final response = await _authApiClient.login(
        event.email,
        event.password,
      );

      // Store token securely
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: response.accessToken,
      );

      emit(AuthAuthenticated(
        accessToken: response.accessToken,
      ));
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final request = UserCreateRequest(
        email: event.email,
        password: event.password,
        fullName: event.fullName,
        healthProfile: event.healthProfile,
      );

      final user = await _authApiClient.register(request);

      // After registration, auto-login
      final loginResponse = await _authApiClient.login(
        event.email,
        event.password,
      );

      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: loginResponse.accessToken,
      );

      emit(AuthAuthenticated(
        accessToken: loginResponse.accessToken,
        user: user,
      ));
    } catch (e) {
      emit(AuthError(message: _getErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.userEmail);
    emit(const AuthUnauthenticated());
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);

    if (token != null && token.isNotEmpty) {
      emit(AuthAuthenticated(accessToken: token));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  String _getErrorMessage(dynamic error) {
    if (error.toString().contains('401')) {
      return 'Credenciales incorrectas';
    } else if (error.toString().contains('409')) {
      return 'El email ya está registrado';
    } else if (error.toString().contains('network')) {
      return 'Error de conexión. Verifica tu internet.';
    }
    return 'Error inesperado. Inténtalo de nuevo.';
  }
}
