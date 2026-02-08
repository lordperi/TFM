import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../data/repositories/profile_repository.dart';
import 'adult_profile_screen.dart';
import 'child_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      context.read<ProfileBloc>().add(LoadProfile(authState.token));
      // Load XP and achievements for child mode
      context.read<ProfileBloc>().add(LoadXPSummary(authState.token));
      context.read<ProfileBloc>().add(LoadAchievements(authState.token));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc(repository: ProfileRepository()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Mi Perfil'),
          elevation: 0,
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            // Reload data when ProfileBloc is created
            if (state is ProfileInitial) {
              _loadProfile();
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
                      onPressed: _loadProfile,
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is! ProfileLoaded) {
              return const Center(child: Text('No se pudo cargar el perfil'));
            }

            // Determine if user has family members (child mode) or not (adult mode)
            // For now, we'll use a simple toggle. In production, check if user.patients.isNotEmpty
            return _ProfileModeSelector(
              user: state.user,
              onReload: _loadProfile,
            );
          },
        ),
      ),
    );
  }
}

class _ProfileModeSelector extends StatefulWidget {
  final dynamic user; // UserPublic
  final VoidCallback onReload;

  const _ProfileModeSelector({
    required this.user,
    required this.onReload,
  });

  @override
  State<_ProfileModeSelector> createState() => _ProfileModeSelectorState();
}

class _ProfileModeSelectorState extends State<_ProfileModeSelector> {
  bool _isChildMode = true; // Start with child mode to showcase gamification

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Mode Toggle
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          color: Theme.of(context).colorScheme.surfaceVariant,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 20),
              const SizedBox(width: 8),
              const Text('Modo Adulto'),
              const SizedBox(width: 12),
              Switch(
                value: _isChildMode,
                onChanged: (value) => setState(() => _isChildMode = value),
              ),
              const SizedBox(width: 12),
              const Text('Modo Niño'),
              const SizedBox(width: 8),
              const Icon(Icons.child_care, size: 20),
            ],
          ),
        ),
        
        // Content
        Expanded(
          child: _isChildMode
              ? const ChildProfileScreen()
              : const AdultProfileScreen(),
        ),
      ],
    );
  }
}
