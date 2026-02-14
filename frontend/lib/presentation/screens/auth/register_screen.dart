import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants/diabetes_type.dart';
import '../../core/constants/therapy_type.dart';
import '../../data/models/auth_models.dart';
import '../../data/datasources/auth_api_client.dart';
import '../widgets/conditional_medical_fields.dart';
import '../widgets/basal_insulin_fields.dart';

class RegisterScreen extends StatefulWidget {
  final AuthApiClient authApiClient;
  
  const RegisterScreen({
    super.key,
    required this.authApiClient,
  });

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _fullNameController = TextEditingController();
  
  // Medical fields
  final _isfController = TextEditingController();
  final _icrController = TextEditingController();
  final _targetController = TextEditingController(text: '120');
  
  // Basal insulin fields
  final _basalTypeController = TextEditingController();
  final _basalUnitsController = TextEditingController();
  final _basalTimeController = TextEditingController();
  
  DiabetesType _selectedDiabetesType = DiabetesType.none;
  TherapyType? _selectedTherapyType;
  
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fullNameController.dispose();
    _isfController.dispose();
    _icrController.dispose();
    _targetController.dispose();
    _basalTypeController.dispose();
    _basalUnitsController.dispose();
    _basalTimeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Cuenta'),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Bienvenido a DiaBeaty',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Crea tu cuenta para comenzar',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Email es requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Full Name (optional)
                TextFormField(
                  controller: _fullNameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Nombre Completo (Opcional)',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                    helperText: 'Mínimo 8 caracteres',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Contraseña es requerida';
                    }
                    if (value.length < 8) {
                      return 'Mínimo 8 caracteres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmar Contraseña',
                    prefixIcon: const Icon(Icons.lock_outline),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Confirma tu contraseña';
                    }
                    if (value != _passwordController.text) {
                      return 'Las contraseñas no coinciden';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Diabetes Type Selector
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '¿Tienes diabetes?',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 12),
                        ...DiabetesType.values.map((type) {
                          return RadioListTile<DiabetesType>(
                            contentPadding: EdgeInsets.zero,
                            title: Text(type.displayName),
                            value: type,
                            groupValue: _selectedDiabetesType,
                            onChanged: (value) {
                              setState(() {
                                _selectedDiabetesType = value!;
                                // Reset therapy type when diabetes type changes
                                _selectedTherapyType = null;
                                // Clear medical fields
                                _isfController.clear();
                                _icrController.clear();
                                _targetController.text = '120';
                              });
                            },
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Conditional Medical Fields
                ConditionalMedicalFields(
                  diabetesType: _selectedDiabetesType,
                  therapyType: _selectedTherapyType,
                  onTherapyTypeChanged: (value) {
                    setState(() {
                      _selectedTherapyType = value;
                    });
                  },
                  isfController: _isfController,
                  icrController: _icrController,
                  targetController: _targetController,
                ),

                // Basal Insulin Fields (only if therapy requires insulin)
                if (_selectedTherapyType?.requiresInsulinFields() == true) ...[
                  const SizedBox(height: 16),
                  BasalInsulinFields(
                    typeController: _basalTypeController,
                    unitsController: _basalUnitsController,
                    timeController: _basalTimeController,
                  ),
                ],

                const SizedBox(height: 32),

                // Register Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Crear Cuenta',
                          style: TextStyle(fontSize: 16),
                        ),
                ),

                const SizedBox(height: 16),

                // Login Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿Ya tienes cuenta? '),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Inicia sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Build basal insulin info if present
      BasalInsulinInfo? basalInsulin;
      if (_basalTypeController.text.isNotEmpty ||
          _basalUnitsController.text.isNotEmpty ||
          _basalTimeController.text.isNotEmpty) {
        basalInsulin = BasalInsulinInfo(
          type: _basalTypeController.text.isEmpty
              ? null
              : _basalTypeController.text,
          units: _basalUnitsController.text.isEmpty
              ? null
              : double.tryParse(_basalUnitsController.text),
          administrationTime: _basalTimeController.text.isEmpty
              ? null
              : _basalTimeController.text,
        );
      }

      // Build health profile
      final healthProfile = HealthProfileCreate(
        diabetesType: _selectedDiabetesType.value,
        therapyType: _selectedTherapyType?.value,
        insulinSensitivity: _isfController.text.isEmpty
            ? null
            : double.tryParse(_isfController.text),
        carbRatio: _icrController.text.isEmpty
            ? null
            : double.tryParse(_icrController.text),
        targetGlucose: _targetController.text.isEmpty
            ? null
            : int.tryParse(_targetController.text),
        basalInsulin: basalInsulin,
      );

      // Build request
      final request = UserCreateRequest(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        fullName: _fullNameController.text.isEmpty
            ? null
            : _fullNameController.text.trim(),
        healthProfile: healthProfile,
      );

      // Call API
      final response = await widget.authApiClient.register(request);
      
      if (mounted) {
        // Success!
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '✅ Cuenta creada exitosamente\n¡Bienvenido a DiaBeaty!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
        
        // Navigate back to login with pre-filled email
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pop(context, _emailController.text);
        }
      }
    } on DioException catch (e) {
      if (mounted) {
        String errorMessage = 'Error al crear cuenta';
        
        // Parse HTTP errors
        if (e.response != null) {
          switch (e.response!.statusCode) {
            case 409:
              errorMessage = '❌ Este email ya está registrado';
              break;
            case 400:
              final detail = e.response!.data?['detail'] ?? 'Datos inválidos';
              errorMessage = '❌ $detail';
              break;
            case 422:
              errorMessage = '❌ Error de validación: revisa los campos';
              break;
            case 500:
              errorMessage = '❌ Error del servidor, intenta más tarde';
              break;
            default:
              errorMessage = '❌ Error: ${e.response!.statusCode}';
          }
        } else if (e.type == DioExceptionType.connectionTimeout ||
                   e.type == DioExceptionType.receiveTimeout) {
          errorMessage = '❌ Tiempo de espera agotado, verifica tu conexión';
        } else if (e.type == DioExceptionType.connectionError) {
          errorMessage = '❌ Sin conexión al servidor';
        } else {
          errorMessage = '❌ Error de red: ${e.message}';
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text(errorMessage)),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } on Exception catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error inesperado: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
