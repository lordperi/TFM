import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/data/repositories/profile_repository.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/adult_profile_screen.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/child_profile_screen.dart';
import 'package:diabeaty_mobile/presentation/bloc/theme/theme_bloc.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, themeState) {
        // Obtener el nombre del miembro activo para el AppBar
        final authState = context.read<AuthBloc>().state;
        final memberName = (authState is AuthAuthenticated &&
                authState.selectedProfile != null)
            ? authState.selectedProfile!.displayName
            : 'Mi Perfil';

        if (themeState.uiMode == UiMode.child) {
          // El perfil niño necesita XP y logros del ProfileBloc
          return BlocProvider(
            create: (context) {
              final bloc = ProfileBloc(repository: ProfileRepository());
              if (authState is AuthAuthenticated) {
                bloc.add(LoadProfile(authState.accessToken));
                bloc.add(LoadXPSummary(authState.accessToken));
                bloc.add(LoadAchievements(authState.accessToken));
              }
              return bloc;
            },
            child: Scaffold(
              appBar: AppBar(
                title: Text(memberName),
                elevation: 0,
              ),
              body: BlocBuilder<ProfileBloc, ProfileState>(
                builder: (context, profileState) {
                  if (profileState is ProfileInitial ||
                      profileState is ProfileLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (profileState is ProfileError) {
                    return Center(
                      child: Text('Error: ${profileState.message}'),
                    );
                  }
                  // Esperar a que xpSummary cargue (viene de LoadXPSummary,
                  // que puede completarse después de LoadProfile).
                  if (profileState is ProfileLoaded &&
                      profileState.xpSummary == null) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return const ChildProfileScreen();
                },
              ),
            ),
          );
        }

        // Perfil adulto — los datos vienen directamente del AuthBloc (selectedProfile)
        // No necesita esperar al ProfileBloc para renderizarse.
        // Proveer ProfileBloc igualmente para el listener de ChangePassword.
        return BlocProvider(
          create: (context) {
            final bloc = ProfileBloc(repository: ProfileRepository());
            if (authState is AuthAuthenticated) {
              bloc.add(LoadProfile(authState.accessToken));
            }
            return bloc;
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(memberName),
              elevation: 0,
            ),
            body: const AdultProfileScreen(),
          ),
        );
      },
    );
  }
}

/// Mantenida por compatibilidad con tests existentes.
class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _loadProfile(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ProfileBloc>().add(LoadProfile(authState.accessToken));
      context.read<ProfileBloc>().add(LoadXPSummary(authState.accessToken));
      context.read<ProfileBloc>().add(LoadAchievements(authState.accessToken));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Perfil'), elevation: 0),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial || state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ProfileError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _loadProfile(context),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          if (state is! ProfileLoaded) {
            return const Center(child: Text('No se pudo cargar el perfil'));
          }
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return themeState.uiMode == UiMode.child
                  ? const ChildProfileScreen()
                  : const AdultProfileScreen();
            },
          );
        },
      ),
    );
  }
}
