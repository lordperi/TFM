import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/presentation/widgets/change_password_dialog.dart';
import 'package:diabeaty_mobile/data/models/family_models.dart';
import 'package:diabeaty_mobile/data/repositories/family_repository.dart';
import 'package:diabeaty_mobile/presentation/bloc/profile/profile_bloc.dart';

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
  bool _initialized = false;
  bool _isSaving = false;

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

  /// Carga los datos del miembro activo en los campos del formulario.
  void _initFromProfile(PatientProfile profile) {
    if (_initialized) return;
    _initialized = true;
    _diabetesType = profile.diabetesType;
    _insulinSensitivityController.text =
        profile.insulinSensitivity?.toString() ?? '';
    _carbRatioController.text = profile.carbRatio?.toString() ?? '';
    _targetGlucoseController.text = profile.targetGlucose?.toString() ?? '';
  }

  Future<void> _save(PatientProfile profile, String token) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = context.read<FamilyRepository>();
      final request = PatientUpdateRequest(
        diabetesType: _diabetesType,
        insulinSensitivity: _insulinSensitivityController.text.isEmpty
            ? null
            : _insulinSensitivityController.text,
        carbRatio: _carbRatioController.text.isEmpty
            ? null
            : _carbRatioController.text,
        targetGlucose: _targetGlucoseController.text.isEmpty
            ? null
            : _targetGlucoseController.text,
      );
      await repo.updateProfile(profile.id, request);

      if (!mounted) return;
      // Sincroniza el perfil activo en AuthBloc para reflejar los nuevos rangos
      context.read<AuthBloc>().add(const RefreshSelectedProfile());

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado correctamente')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al guardar: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showChangePassword(String token) {
    showDialog(
      context: context,
      builder: (dialogContext) => ChangePasswordDialog(
        onSubmit: (request) {
          context
              .read<ProfileBloc>()
              .add(ChangePassword(token, request));
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        if (authState is! AuthAuthenticated ||
            authState.selectedProfile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final profile = authState.selectedProfile!;
        final token = authState.accessToken;

        // Inicializar controladores la primera vez que tenemos datos
        _initFromProfile(profile);

        return BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is PasswordChangeSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Contraseña cambiada correctamente')),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: ${state.message}')),
              );
            }
          },
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Tarjeta de identificación del miembro ──────────────
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          profile.displayName
                              .substring(0, 1)
                              .toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(profile.displayName),
                      subtitle: profile.isGuardian
                          ? Text(authState.user.email)
                          : Text(
                              profile.diabetesType != null
                                  ? _diabetesTypeLabel(profile.diabetesType!)
                                  : 'Perfil dependiente',
                            ),
                      trailing: profile.isGuardian
                          ? const Chip(
                              label: Text('Tutor'),
                              avatar: Icon(Icons.shield, size: 16),
                            )
                          : const Chip(
                              label: Text('Miembro'),
                              avatar: Icon(Icons.person, size: 16),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // ── Sección médica ─────────────────────────────────────
                  Text('Perfil Médico',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),

                  // Tipo de Diabetes
                  DropdownButtonFormField<String>(
                    value: _diabetesType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Diabetes',
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                          value: 'type_1', child: Text('Tipo 1')),
                      DropdownMenuItem(
                          value: 'type_2', child: Text('Tipo 2')),
                      DropdownMenuItem(
                          value: 'gestational',
                          child: Text('Gestacional')),
                      DropdownMenuItem(
                          value: 'lada', child: Text('LADA')),
                      DropdownMenuItem(
                          value: 'mody', child: Text('MODY')),
                    ],
                    onChanged: (value) =>
                        setState(() => _diabetesType = value),
                  ),
                  const SizedBox(height: 16),

                  // ISF
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

                  // ICR
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

                  // Objetivo glucosa
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

                  // ── Guardar ────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isSaving
                          ? null
                          : () => _save(profile, token),
                      icon: _isSaving
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Cambiar contraseña — solo para GUARDIAN ────────────
                  if (profile.isGuardian)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showChangePassword(token),
                        icon: const Icon(Icons.lock),
                        label: const Text('Cambiar Contraseña'),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  String _diabetesTypeLabel(String type) {
    const labels = {
      'type_1': 'Diabetes Tipo 1',
      'type_2': 'Diabetes Tipo 2',
      'gestational': 'Diabetes Gestacional',
      'lada': 'LADA',
      'mody': 'MODY',
      'none': 'Sin diagnóstico',
    };
    return labels[type] ?? type;
  }
}
