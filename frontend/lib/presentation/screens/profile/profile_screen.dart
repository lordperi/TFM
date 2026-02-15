import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/data/repositories/profile_repository.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/adult_profile_screen.dart';
import 'package:diabeaty_mobile/presentation/screens/profile/child_profile_screen.dart';
import 'package:diabeaty_mobile/presentation/bloc/theme/theme_bloc.dart';
import '../../../core/constants/app_constants.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Removed initState to prevent context access error
  
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
    return BlocProvider(
      create: (context) {
        final bloc = ProfileBloc(repository: ProfileRepository());
        // Initial Load
        final authState = context.read<AuthBloc>().state;
        if (authState is AuthAuthenticated) {
          bloc.add(LoadProfile(authState.accessToken));
          bloc.add(LoadXPSummary(authState.accessToken));
          bloc.add(LoadAchievements(authState.accessToken));
        }
        return bloc;
      },
      child: const ProfileView(),
    );
  }
}

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
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        elevation: 0,
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileLoading) {
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

          // Enforce UI Mode based on Global Theme
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
