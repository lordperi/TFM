import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/family_models.dart';
import '../../../data/models/auth_models.dart'; // For BasalInsulinInfo if needed helper
import '../../../data/repositories/family_repository.dart';
import '../auth/pin_verify_screen.dart';
import '../../widgets/conditional_medical_fields.dart';
import '../../widgets/basal_insulin_fields.dart';
import '../../../core/constants/diabetes_type.dart';
import '../../../core/constants/therapy_type.dart';

class EditPatientScreen extends StatefulWidget {
  final PatientProfile? profile; // Null for Create mode
  final bool isInitiallyUnlocked;
  final String? authPin;

  const EditPatientScreen({super.key, this.profile, this.isInitiallyUnlocked = true, this.authPin});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _pinController;
  late TextEditingController _isfController; // Insulin Sensitivity
  late TextEditingController _icrController; // Carb Ratio
  late TextEditingController _targetController;
  
  // Basal Insulin Controllers
  final _basalTypeController = TextEditingController();
  final _basalUnitsController = TextEditingController();
  final _basalTimeController = TextEditingController();

  // State values
  String _role = 'DEPENDENT';
  String _theme = 'child';
  DiabetesType _diabetesType = DiabetesType.type1;
  TherapyType? _therapyType = TherapyType.insulin;
  DateTime? _birthDate;
  bool _isLoading = false;
  late bool _isUnlocked;
  String? _authPin;

  @override
  void initState() {
    super.initState();
    _isUnlocked = widget.isInitiallyUnlocked;
    _authPin = widget.authPin;
    _nameController = TextEditingController(text: widget.profile?.displayName ?? '');
    _pinController = TextEditingController(); 
    
    _isfController = TextEditingController(text: "");
    _icrController = TextEditingController(text: "");
    _targetController = TextEditingController(text: "");

    if (widget.profile != null) {
      _role = widget.profile!.role;
      _theme = widget.profile!.themePreference;
      _loadProfileDetails();
    } else {
      // Defaults for new profile
      _diabetesType = DiabetesType.none;
      _therapyType = null;
    }
  }

  Future<void> _loadProfileDetails() async {
      setState(() => _isLoading = true);
      try {
          final repo = context.read<FamilyRepository>();
          final details = await repo.getProfileDetails(widget.profile!.id);
          
          if (mounted) {
              setState(() {
                  _theme = details.themePreference;
                  _role = details.role;
                  if (details.birthDate != null) {
                      _birthDate = DateTime.parse(details.birthDate!);
                  }
                  
                  if (details.diabetesType != null) {
                    _diabetesType = DiabetesType.fromString(details.diabetesType!);
                  }
                  
                  if (details.therapyType != null) {
                     _therapyType = TherapyType.fromString(details.therapyType!);
                  } else {
                     _therapyType = null;
                  }

                  if (details.insulinSensitivity != null) _isfController.text = details.insulinSensitivity.toString();
                  if (details.carbRatio != null) _icrController.text = details.carbRatio.toString();
                  if (details.targetGlucose != null) _targetController.text = details.targetGlucose.toString();
                  
                  if (details.basalInsulinType != null) _basalTypeController.text = details.basalInsulinType!;
                  if (details.basalInsulinUnits != null) _basalUnitsController.text = details.basalInsulinUnits.toString();
                  if (details.basalInsulinTime != null) _basalTimeController.text = details.basalInsulinTime!;
              });
          }
      } catch (e) {
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error cargando detalles: $e")));
      } finally {
          if (mounted) setState(() => _isLoading = false);
      }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _isfController.dispose();
    _icrController.dispose();
    _targetController.dispose();
    _basalTypeController.dispose();
    _basalUnitsController.dispose();
    _basalTimeController.dispose();
    super.dispose();
  }

  Future<void> _unlockSettings() async {
      if (widget.profile == null) return;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => PinVerifyScreen(profile: widget.profile!, verifyOnly: true)),
      );
      
      if (result != null && result is String) {
          setState(() {
              _isUnlocked = true;
              _authPin = result;
          });
      }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    final repo = context.read<FamilyRepository>();

    try {
      // Sanitización
      final isNone = _diabetesType == DiabetesType.none;
      
      final dbTypeStr = _diabetesType.value;
      final therapyStr = isNone ? null : _therapyType?.value;
      
      final isfStr = isNone || _isfController.text.isEmpty ? "0.0" : _isfController.text;
      final icrStr = isNone || _icrController.text.isEmpty ? "0.0" : _icrController.text;
      final targetStr = isNone || _targetController.text.isEmpty ? "0.0" : _targetController.text;
      
      final basalTypeStr = isNone || _basalTypeController.text.isEmpty ? null : _basalTypeController.text;
      final basalUnitsStr = isNone || _basalUnitsController.text.isEmpty ? null : _basalUnitsController.text;
      final basalTimeStr = isNone || _basalTimeController.text.isEmpty ? null : _basalTimeController.text;

      if (widget.profile == null) {
        // CREATE
        final request = CreatePatientRequest(
          displayName: _nameController.text,
          role: _role,
          themePreference: _theme,
           birthDate: _birthDate?.toIso8601String().split('T')[0],
          pin: (_role == 'GUARDIAN' ? _pinController.text : null),
          diabetesType: dbTypeStr,
          therapyType: therapyStr ?? 'NONE', // Default safe
          insulinSensitivity: isfStr,
          carbRatio: icrStr,
          targetGlucose: targetStr,
          basalInsulinType: basalTypeStr,
          basalInsulinUnits: basalUnitsStr,
          basalInsulinTime: basalTimeStr,
        );
        await repo.createProfile(request);
      } else {
        // UPDATE
        String? pinToSend = _authPin;
        if (_role == 'GUARDIAN' && _pinController.text.isNotEmpty) {
            pinToSend = _pinController.text;
        }

        final request = PatientUpdateRequest(
          displayName: _nameController.text,
          role: _role,
          themePreference: _theme,
           birthDate: _birthDate?.toIso8601String().split('T')[0],
          pin: pinToSend,
          diabetesType: dbTypeStr,
          therapyType: therapyStr,
          insulinSensitivity: isfStr,
          carbRatio: icrStr,
          targetGlucose: targetStr,
          basalInsulinType: basalTypeStr,
          basalInsulinUnits: basalUnitsStr,
          basalInsulinTime: basalTimeStr
        );
        await repo.updateProfile(widget.profile!.id, request);
      }
      
      if (mounted) Navigator.pop(context, true); 
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.profile != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? "Editar Perfil" : "Nuevo Perfil")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isUnlocked)
                 Container(
                     padding: const EdgeInsets.all(12),
                     margin: const EdgeInsets.only(bottom: 16),
                     decoration: BoxDecoration(
                         color: Colors.amber[100],
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.amber)
                     ),
                     child: Row(
                         children: [
                             const Icon(Icons.lock, color: Colors.orange),
                             const SizedBox(width: 10),
                             Expanded(child: const Text("Configuración sensible bloqueada. Desbloquea para editar datos médicos.", style: TextStyle(color: Colors.black87))),
                             TextButton(onPressed: _unlockSettings, child: const Text("DESBLOQUEAR"))
                         ],
                     ),
                 ),
                 
              const Text("Información Personal", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              
              // NAME - Locked if !Unlocked
              TextFormField(
                controller: _nameController,
                enabled: _isUnlocked,
                decoration: const InputDecoration(labelText: "Nombre"),
                validator: (v) => v!.isEmpty ? "Requerido" : null,
              ),
              const SizedBox(height: 10),
              
              // ROLE - Locked if !Unlocked
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: "Rol"),
                onChanged: _isUnlocked ? (val) => setState(() {
                  _role = val!;
                  if (_role == 'GUARDIAN') _theme = 'adult';
                  if (_role == 'DEPENDENT') _theme = 'child';
                }) : null, // Disable logic
                items: const [
                  DropdownMenuItem(value: 'GUARDIAN', child: Text("Tutor (Adulto)")),
                  DropdownMenuItem(value: 'DEPENDENT', child: Text("Dependiente (Niño)")),
                ],
              ),
              
              // THEME - ALWAYS UNLOCKED (Requested Feature)
              const SizedBox(height: 10),
              const Text("Tema visual (Avatar)", style: TextStyle(fontSize: 14, color: Colors.grey)),
              DropdownButtonFormField<String>(
                  value: _theme,
                  decoration: const InputDecoration(labelText: "Tema"),
                  items: const [
                       DropdownMenuItem(value: 'child', child: Text("Niño (Divertido)")),
                       DropdownMenuItem(value: 'adult', child: Text("Adulto (Limpio)")),
                       DropdownMenuItem(value: 'teen', child: Text("Adolescente (Minimalista)")),
                  ],
                  onChanged: (v) => setState(() => _theme = v!),
              ),


              if (_role == 'GUARDIAN')
                TextFormField(
                  controller: _pinController,
                  enabled: _isUnlocked, 
                  decoration: const InputDecoration(labelText: "PIN (4 Dígitos)"),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (v) {
                    if (isEditing && (v == null || v.isEmpty)) return null; 
                    if (v == null || v.length != 4) return "Debe tener 4 dígitos";
                    return null;
                  },
                ),
               const SizedBox(height: 10),

               // DOB - Locked
               ListTile(
                 title: Text(_birthDate == null ? "Seleccionar F. Nacimiento" : "F. Nacimiento: ${_birthDate.toString().split(' ')[0]}"),
                 trailing: const Icon(Icons.calendar_today),
                 enabled: _isUnlocked,
                 onTap: () async {
                   if (!_isUnlocked) return;
                   final date = await showDatePicker(
                     context: context, 
                     initialDate: _birthDate ?? DateTime.now(), 
                     firstDate: DateTime(1900), 
                     lastDate: DateTime.now()
                   );
                   if (date != null) setState(() => _birthDate = date);
                 },
               ),
               
               const SizedBox(height: 20),
               
               // MEDICAL SETTINGS - Fully Locked Visual
               Opacity(
                 opacity: _isUnlocked ? 1.0 : 0.5,
                 child: IgnorePointer(
                   ignoring: !_isUnlocked,
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       const Text("Configuración Médica", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       const Divider(),
                       
                       // DYNAMIC WIDGETS
                       // Diabetes Type Selector
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
                         onChanged: _isUnlocked ? (DiabetesType? newValue) {
                            if (newValue == null) return;
                            setState(() {
                              _diabetesType = newValue;
                              
                              // Reset logic
                              if (_diabetesType == DiabetesType.none) {
                                _therapyType = null;
                                _isfController.clear();
                                _icrController.clear();
                                _targetController.clear();
                                _basalTypeController.clear();
                                _basalUnitsController.clear();
                                _basalTimeController.clear();
                              } else {
                                // Default therapy? No, let user choose.
                                _therapyType = null;
                              }
                            });
                         } : null,
                       ),
                       const SizedBox(height: 16),

                       // DYNAMIC WIDGETS
                       ConditionalMedicalFields(
                          diabetesType: _diabetesType,
                          therapyType: _therapyType,
                          isfController: _isfController,
                          icrController: _icrController,
                          targetController: _targetController,
                          onTherapyTypeChanged: (TherapyType? newValue) {
                            setState(() {
                              _therapyType = newValue;
                            });
                          },
                       ),
                       
                       const SizedBox(height: 10),
                       
                       if (_therapyType != null && (_therapyType == TherapyType.insulin || _therapyType == TherapyType.mixed)) ...[
                         const SizedBox(height: 10),
                         BasalInsulinFields(
                           typeController: _basalTypeController, 
                           unitsController: _basalUnitsController, 
                           timeController: _basalTimeController
                         ),
                       ],
                     ],
                   ),
                 ),
               ),

               const SizedBox(height: 30),
               SizedBox(
                 width: double.infinity,
                 child: ElevatedButton(
                   onPressed: _isLoading ? null : _save,
                   style: ElevatedButton.styleFrom(
                     padding: const EdgeInsets.symmetric(vertical: 16),
                     backgroundColor: Colors.blueAccent
                   ),
                   child: _isLoading ? const CircularProgressIndicator() : Text(isEditing ? "Guardar Cambios" : "Crear Perfil"),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}
