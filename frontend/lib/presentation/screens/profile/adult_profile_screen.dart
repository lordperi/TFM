import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:diabeaty_mobile/presentation/bloc/auth/auth_bloc.dart';
import 'package:diabeaty_mobile/presentation/widgets/change_password_dialog.dart';
import 'package:diabeaty_mobile/presentation/widgets/conditional_medical_fields.dart';
import 'package:diabeaty_mobile/presentation/widgets/basal_insulin_fields.dart';
import 'package:diabeaty_mobile/data/models/family_models.dart';
import 'package:diabeaty_mobile/data/repositories/family_repository.dart';
import 'package:diabeaty_mobile/presentation/bloc/profile/profile_bloc.dart';
import 'package:diabeaty_mobile/core/constants/diabetes_type.dart';
import 'package:diabeaty_mobile/core/constants/therapy_type.dart';

class AdultProfileScreen extends StatefulWidget {
  const AdultProfileScreen({super.key});

  @override
  State<AdultProfileScreen> createState() => _AdultProfileScreenState();
}

class _AdultProfileScreenState extends State<AdultProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controladores — mismos que EditPatientScreen
  final _isfController = TextEditingController();
  final _icrController = TextEditingController();
  final _targetController = TextEditingController();
  final _targetLowController = TextEditingController();
  final _targetHighController = TextEditingController();
  final _basalTypeController = TextEditingController();
  final _basalUnitsController = TextEditingController();
  final _basalTimeController = TextEditingController();

  DiabetesType _diabetesType = DiabetesType.none;
  TherapyType? _therapyType;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Carga los detalles completos desde la API al abrir la pantalla
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadDetails());
  }

  @override
  void dispose() {
    _isfController.dispose();
    _icrController.dispose();
    _targetController.dispose();
    _targetLowController.dispose();
    _targetHighController.dispose();
    _basalTypeController.dispose();
    _basalUnitsController.dispose();
    _basalTimeController.dispose();
    super.dispose();
  }

  /// Llama a getProfileDetails() — igual que EditPatientScreen — para
  /// obtener todos los campos médicos completos.
  Future<void> _loadDetails() async {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated || authState.selectedProfile == null) {
      setState(() => _isLoading = false);
      return;
    }

    try {
      final repo = context.read<FamilyRepository>();
      final details =
          await repo.getProfileDetails(authState.selectedProfile!.id);

      if (!mounted) return;
      setState(() {
        _isLoading = false;

        if (details.diabetesType != null) {
          _diabetesType = DiabetesType.fromString(details.diabetesType!);
        }

        if (details.therapyType != null) {
          _therapyType = TherapyType.fromString(details.therapyType!);
        }

        if (details.insulinSensitivity != null) {
          _isfController.text = details.insulinSensitivity.toString();
        }
        if (details.carbRatio != null) {
          _icrController.text = details.carbRatio.toString();
        }
        if (details.targetGlucose != null) {
          _targetController.text = details.targetGlucose.toString();
        }
        if (details.targetRangeLow != null) {
          _targetLowController.text = details.targetRangeLow.toString();
        }
        if (details.targetRangeHigh != null) {
          _targetHighController.text = details.targetRangeHigh.toString();
        }
        if (details.basalInsulinType != null) {
          _basalTypeController.text = details.basalInsulinType!;
        }
        if (details.basalInsulinUnits != null) {
          _basalUnitsController.text = details.basalInsulinUnits.toString();
        }
        if (details.basalInsulinTime != null) {
          _basalTimeController.text = details.basalInsulinTime!;
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error cargando datos: $e')),
      );
    }
  }

  Future<void> _save(PatientProfile profile, String token) async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final repo = context.read<FamilyRepository>();

      final isNone = _diabetesType == DiabetesType.none;
      final dbTypeStr = _diabetesType.value;
      final therapyStr = isNone ? null : _therapyType?.value;

      final isfStr =
          isNone || _isfController.text.isEmpty ? '0.0' : _isfController.text;
      final icrStr =
          isNone || _icrController.text.isEmpty ? '0.0' : _icrController.text;
      final targetStr = isNone || _targetController.text.isEmpty
          ? '0.0'
          : _targetController.text;
      final targetLowInt = isNone || _targetLowController.text.isEmpty
          ? null
          : int.tryParse(_targetLowController.text);
      final targetHighInt = isNone || _targetHighController.text.isEmpty
          ? null
          : int.tryParse(_targetHighController.text);
      final basalTypeStr = isNone || _basalTypeController.text.isEmpty
          ? null
          : _basalTypeController.text;
      final basalUnitsStr = isNone || _basalUnitsController.text.isEmpty
          ? null
          : _basalUnitsController.text;
      final basalTimeStr = isNone || _basalTimeController.text.isEmpty
          ? null
          : _basalTimeController.text;

      final request = PatientUpdateRequest(
        diabetesType: dbTypeStr,
        therapyType: therapyStr,
        insulinSensitivity: isfStr,
        carbRatio: icrStr,
        targetGlucose: targetStr,
        targetRangeLow: targetLowInt,
        targetRangeHigh: targetHighInt,
        basalInsulinType: basalTypeStr,
        basalInsulinUnits: basalUnitsStr,
        basalInsulinTime: basalTimeStr,
      );

      await repo.updateProfile(profile.id, request);

      if (!mounted) return;
      // Sincroniza el perfil activo en AuthBloc (rangos de glucosa, etc.)
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
          context.read<ProfileBloc>().add(ChangePassword(token, request));
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

        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

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
                  // ── Tarjeta de identidad del miembro ─────────────────
                  Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          profile.displayName.substring(0, 1).toUpperCase(),
                          style:
                              const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Text(profile.displayName),
                      subtitle: profile.isGuardian
                          ? Text(authState.user.email)
                          : const Text('Perfil dependiente'),
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

                  // ── Sección médica (réplica de EditPatientScreen) ─────
                  const Text(
                    'Configuración Médica',
                    style: TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Tipo de Diabetes
                  DropdownButtonFormField<DiabetesType>(
                    value: _diabetesType,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de Diabetes',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.water_drop),
                    ),
                    items: DiabetesType.values.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type.displayName),
                      );
                    }).toList(),
                    onChanged: (DiabetesType? newValue) {
                      if (newValue == null) return;
                      setState(() {
                        _diabetesType = newValue;
                        if (_diabetesType == DiabetesType.none) {
                          _therapyType = null;
                          _isfController.clear();
                          _icrController.clear();
                          _targetController.clear();
                          _targetLowController.clear();
                          _targetHighController.clear();
                          _basalTypeController.clear();
                          _basalUnitsController.clear();
                          _basalTimeController.clear();
                        } else {
                          _therapyType = null;
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Campos condicionales según tipo de diabetes y terapia
                  ConditionalMedicalFields(
                    diabetesType: _diabetesType,
                    therapyType: _therapyType,
                    isfController: _isfController,
                    icrController: _icrController,
                    targetController: _targetController,
                    targetRangeLowController: _targetLowController,
                    targetRangeHighController: _targetHighController,
                    onTherapyTypeChanged: (TherapyType? newValue) {
                      setState(() => _therapyType = newValue);
                    },
                  ),

                  // Campos de insulina basal (si aplica)
                  if (_therapyType != null &&
                      (_therapyType == TherapyType.insulin ||
                          _therapyType == TherapyType.mixed)) ...[
                    const SizedBox(height: 10),
                    BasalInsulinFields(
                      typeController: _basalTypeController,
                      unitsController: _basalUnitsController,
                      timeController: _basalTimeController,
                    ),
                  ],

                  const SizedBox(height: 30),

                  // ── Guardar ───────────────────────────────────────────
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
                              child: CircularProgressIndicator(
                                  strokeWidth: 2),
                            )
                          : const Icon(Icons.save),
                      label: const Text('Guardar Cambios'),
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.blueAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Cambiar contraseña — solo GUARDIAN ────────────────
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
}
