import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';
import 'package:diabeaty_mobile/data/models/profile_models.dart';
import 'package:diabeaty_mobile/data/repositories/profile_repository.dart';

// Events
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  final String token;

  const LoadProfile(this.token);

  @override
  List<Object?> get props => [token];
}

class UpdateHealthProfile extends ProfileEvent {
  final String token;
  final HealthProfileUpdate update;

  const UpdateHealthProfile(this.token, this.update);

  @override
  List<Object?> get props => [token, update];
}

class ChangePassword extends ProfileEvent {
  final String token;
  final PasswordChangeRequest passwordChange;

  const ChangePassword(this.token, this.passwordChange);

  @override
  List<Object?> get props => [token, passwordChange];
}

class LoadXPSummary extends ProfileEvent {
  final String token;

  const LoadXPSummary(this.token);

  @override
  List<Object?> get props => [token];
}

class LoadAchievements extends ProfileEvent {
  final String token;

  const LoadAchievements(this.token);

  @override
  List<Object?> get props => [token];
}

// States
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final UserPublic user;
  final UserXPSummary? xpSummary;
  final AchievementsResponse? achievements;

  const ProfileLoaded({
    required this.user,
    this.xpSummary,
    this.achievements,
  });

  @override
  List<Object?> get props => [user, xpSummary, achievements];

  ProfileLoaded copyWith({
    UserPublic? user,
    UserXPSummary? xpSummary,
    AchievementsResponse? achievements,
  }) {
    return ProfileLoaded(
      user: user ?? this.user,
      xpSummary: xpSummary ?? this.xpSummary,
      achievements: achievements ?? this.achievements,
    );
  }
}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}

class PasswordChangeSuccess extends ProfileState {}

class HealthProfileUpdateSuccess extends ProfileState {
  final HealthProfile healthProfile;

  const HealthProfileUpdateSuccess(this.healthProfile);

  @override
  List<Object?> get props => [healthProfile];
}

// BLoC
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final ProfileRepository repository;

  ProfileBloc({ProfileRepository? repository})
      : repository = repository ?? ProfileRepository(),
        super(ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<UpdateHealthProfile>(_onUpdateHealthProfile);
    on<ChangePassword>(_onChangePassword);
    on<LoadXPSummary>(_onLoadXPSummary);
    on<LoadAchievements>(_onLoadAchievements);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = await repository.getProfile(event.token);
      emit(ProfileLoaded(user: user));
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateHealthProfile(
    UpdateHealthProfile event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    emit(ProfileLoading());
    
    try {
      final updatedProfile = await repository.updateHealthProfile(
        event.token,
        event.update,
      );
      
      // Reload full profile to get updated data
      final user = await repository.getProfile(event.token);
      emit(ProfileLoaded(
        user: user,
        xpSummary: currentState.xpSummary,
        achievements: currentState.achievements,
      ));
      emit(HealthProfileUpdateSuccess(updatedProfile));
    } catch (e) {
      emit(ProfileError(e.toString()));
      emit(currentState); // Restore previous state
    }
  }

  Future<void> _onChangePassword(
    ChangePassword event,
    Emitter<ProfileState> emit,
  ) async {
    final currentState = state;
    emit(ProfileLoading());
    
    try {
      await repository.changePassword(event.token, event.passwordChange);
      emit(PasswordChangeSuccess());
      
      // Restore previous state after success
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
      if (currentState is ProfileLoaded) {
        emit(currentState);
      }
    }
  }

  Future<void> _onLoadXPSummary(
    LoadXPSummary event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    
    try {
      final xpSummary = await repository.getXPSummary(event.token);
      emit(currentState.copyWith(xpSummary: xpSummary));
    } catch (e) {
      // Keep current state, just log error
      print('Error loading XP summary: $e');
    }
  }

  Future<void> _onLoadAchievements(
    LoadAchievements event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoaded) return;

    final currentState = state as ProfileLoaded;
    
    try {
      final achievements = await repository.getAchievements(event.token);
      emit(currentState.copyWith(achievements: achievements));
    } catch (e) {
      // Keep current state, just log error
      print('Error loading achievements: $e');
    }
  }
}
