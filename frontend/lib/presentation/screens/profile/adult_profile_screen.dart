import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/presentation/widgets/change_password_dialog.dart';
import 'package:diabeaty_mobile/data/models/profile_models.dart';
import 'package:diabeaty_mobile/data/models/auth_models.dart';

class AdultProfileScreen extends StatefulWidget {
  const AdultProfileScreen({super.key});

  @override
  State<AdultProfileScreen> createState() => _AdultProfileScreenState();
}

class _AdultProfileScreenState extends State<AdultProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _insulinSensitivityController;
  late TextEditingController _carbRatioController;
  late TextEditingController _targetGlucoseController;
  String? _diabetesType;

  @override
  void initState() {
    super.initState();
    _insulinSensitivityController = TextEditingController();
    _carbRatioController = TextEditingController();
    _targetGlucoseController = TextEditingController();
  }

  @override
  void dispose() {
    _insulinSensitivityController.dispose();
    _carbRatioController.dispose();
    _targetGlucoseController.dispose();
    super.dispose();
  }

  void _loadProfileData(HealthProfile? profile) {
    if (profile != null) {
      _diabetesType = profile.diabetesType;
      _insulinSensitivityController.text = profile.insulinSensitivity?.toString() ?? '';
      _carbRatioController.text = profile.carbRatio?.toString() ?? '';
      _targetGlucoseController.text = profile.targetGlucose?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is HealthProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Perfil actualizado correctamente')),
          );
        } else if (state is PasswordChangeSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Contraseña cambiada correctamente')),
          );
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${state.message}')),
          );
        }
      },
      builder: (context, state) {
        if (state is ProfileLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is! ProfileLoaded) {
          return const Center(child: Text('No se pudo cargar el perfil'));
        }

        // Load data into controllers
        if (_insulinSensitivityController.text.isEmpty && state.user.healthProfile != null) {
          _loadProfileData(state.user.healthProfile);
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Info Card
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.person),
                    ),
                    title: Text(state.user.fullName ?? 'Usuario'),
                    subtitle: Text(state.user.email),
                  ),
                ),
                const SizedBox(height: 24),
                
                // Health Profile Section
                Text('Perfil Médico', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 16),
                
                // Diabetes Type
                DropdownButtonFormField<String>(
                  value: _diabetesType,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de Diabetes',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'type_1', child: Text('Tipo 1')),
                    DropdownMenuItem(value: 'type_2', child: Text('Tipo 2')),
                    DropdownMenuItem(value: 'gestational', child: Text('Gestacional')),
                    DropdownMenuItem(value: 'lada', child: Text('LADA')),
                    DropdownMenuItem(value: 'mody', child: Text('MODY')),
                  ],
                  onChanged: (value) => setState(() => _diabetesType = value),
                ),
                const SizedBox(height: 16),
                
                // Insulin Sensitivity
                TextFormField(
                  controller: _insulinSensitivityController,
                  decoration: const InputDecoration(
                    labelText: 'Sensibilidad a Insulina (ISF)',
                    hintText: 'mg/dL por unidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = double.tryParse(value);
                      if (num == null || num <= 0 || num > 500) {
                        return 'Debe estar entre 0 y 500';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Carb Ratio
                TextFormField(
                  controller: _carbRatioController,
                  decoration: const InputDecoration(
                    labelText: 'Ratio de Carbohidratos (ICR)',
                    hintText: 'gramos por unidad',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = double.tryParse(value);
                      if (num == null || num <= 0 || num > 150) {
                        return 'Debe estar entre 0 y 150';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                
                // Target Glucose
                TextFormField(
                  controller: _targetGlucoseController,
                  decoration: const InputDecoration(
                    labelText: 'Objetivo de Glucosa',
                    hintText: 'mg/dL',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final num = int.tryParse(value);
                      if (num == null || num < 70 || num > 180) {
                        return 'Debe estar entre 70 y 180';
                      }
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                
                // Save Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final authState = context.read<AuthBloc>().state;
                        if (authState is Authenticated) {
                          final update = HealthProfileUpdate(
                            diabetesType: _diabetesType,
                            insulinSensitivity: _insulinSensitivityController.text.isEmpty
                                ? null
                                : double.parse(_insulinSensitivityController.text),
                            carbRatio: _carbRatioController.text.isEmpty
                                ? null
                                : double.parse(_carbRatioController.text),
                            targetGlucose: _targetGlucoseController.text.isEmpty
                                ? null
                                : int.parse(_targetGlucoseController.text),
                          );
                          context.read<ProfileBloc>().add(UpdateHealthProfile(authState.token, update));
                        }
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar Cambios'),
                  ),
                ),
                const SizedBox(height: 16),
                
                // Change Password Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (dialogContext) => ChangePasswordDialog(
                          onSubmit: (request) {
                            final authState = context.read<AuthBloc>().state;
                            if (authState is Authenticated) {
                              context.read<ProfileBloc>().add(ChangePassword(authState.token, request));
                            }
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.lock),
                    label: const Text('Cambiar Contraseña'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
