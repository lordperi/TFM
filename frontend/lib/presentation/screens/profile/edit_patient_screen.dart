import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/family_models.dart';
import '../../../data/repositories/family_repository.dart';
import '../auth/pin_verify_screen.dart';

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
  late TextEditingController _isController; // Insulin Sensitivity
  late TextEditingController _crController; // Carb Ratio
  late TextEditingController _targetController;

  // State values
  String _role = 'DEPENDENT';
  String _theme = 'child';
  String _diabetesType = 'T1';
  String _therapyMode = 'PEN';
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
    
    _isController = TextEditingController(text: "50");
    _crController = TextEditingController(text: "10");
    _targetController = TextEditingController(text: "100");

    if (widget.profile != null) {
      _role = widget.profile!.role;
      _theme = widget.profile!.themePreference;
      _loadProfileDetails();
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
                  if (details.diabetesType != null) _diabetesType = details.diabetesType!;
                  if (details.therapyMode != null) _therapyMode = details.therapyMode!;
                  if (details.insulinSensitivity != null) _isController.text = details.insulinSensitivity.toString();
                  if (details.carbRatio != null) _crController.text = details.carbRatio.toString();
                  if (details.targetGlucose != null) _targetController.text = details.targetGlucose.toString();
              });
          }
      } catch (e) {
          // ignore error or show snackbar
          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error loading details: $e")));
      } finally {
          if (mounted) setState(() => _isLoading = false);
      }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _pinController.dispose();
    _isController.dispose();
    _crController.dispose();
    _targetController.dispose();
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
      if (widget.profile == null) {
        // CREATE
        final request = CreatePatientRequest(
          displayName: _nameController.text,
          role: _role,
          themePreference: _theme,
           birthDate: _birthDate?.toIso8601String().split('T')[0],
          pin: (_role == 'GUARDIAN' ? _pinController.text : null),
          diabetesType: _diabetesType,
          therapyMode: _therapyMode,
          insulinSensitivity: _isController.text,
          carbRatio: _crController.text,
          targetGlucose: _targetController.text
        );
        await repo.createProfile(request);
      } else {
        // UPDATE
        // Determine which PIN to send:
        // 1. If user entered a NEW PIN in _pinController (Guardian only), use it. (Note: currently fails backend auth if sensitive data changed)
        // 2. Else use _authPin (the PIN used to unlock/enter).
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
          diabetesType: _diabetesType,
          therapyMode: _therapyMode,
          insulinSensitivity: _isController.text,
          carbRatio: _crController.text,
          targetGlucose: _targetController.text
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
      appBar: AppBar(title: Text(isEditing ? "Edit Profile" : "New Profile")),
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
                     margin: const EdgeInsets.bottom(16),
                     decoration: BoxDecoration(
                         color: Colors.amber[100],
                         borderRadius: BorderRadius.circular(8),
                         border: Border.all(color: Colors.amber)
                     ),
                     child: Row(
                         children: [
                             const Icon(Icons.lock, color: Colors.orange),
                             const SizedBox(width: 10),
                             Expanded(child: const Text("Sensitive settings are locked. Unlock to edit medical data.", style: TextStyle(color: Colors.black87))),
                             TextButton(onPressed: _unlockSettings, child: const Text("UNLOCK"))
                         ],
                     ),
                 ),
                 
              const Text("Personal Info", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const Divider(),
              
              // NAME - Locked if !Unlocked
              TextFormField(
                controller: _nameController,
                enabled: _isUnlocked,
                decoration: const InputDecoration(labelText: "Display Name"),
                validator: (v) => v!.isEmpty ? "Required" : null,
              ),
              const SizedBox(height: 10),
              
              // ROLE - Locked if !Unlocked
              DropdownButtonFormField<String>(
                value: _role,
                decoration: const InputDecoration(labelText: "Role"),
                onChanged: _isUnlocked ? (val) => setState(() {
                  _role = val!;
                  if (_role == 'GUARDIAN') _theme = 'adult';
                  if (_role == 'DEPENDENT') _theme = 'child';
                }) : null, // Disable logic
                items: const [
                  DropdownMenuItem(value: 'GUARDIAN', child: Text("Guardian (Adult)")),
                  DropdownMenuItem(value: 'DEPENDENT', child: Text("Dependent (Child)")),
                ],
              ),
              
              // THEME - ALWAYS UNLOCKED (Requested Feature)
              const SizedBox(height: 10),
              const Text("Theme Preference (Avatar)", style: TextStyle(fontSize: 14, color: Colors.grey)),
              DropdownButtonFormField<String>(
                  value: _theme,
                  decoration: const InputDecoration(labelText: "Theme"),
                  items: const [
                       DropdownMenuItem(value: 'child', child: Text("Child (Fun)")),
                       DropdownMenuItem(value: 'adult', child: Text("Adult (Clean)")),
                       DropdownMenuItem(value: 'teen', child: Text("Teen (Minimal)")),
                  ],
                  onChanged: (v) => setState(() => _theme = v!),
              ),


              if (_role == 'GUARDIAN')
                TextFormField(
                  controller: _pinController,
                  enabled: _isUnlocked, 
                  decoration: const InputDecoration(labelText: "PIN (4 Digits)"),
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  validator: (v) {
                    if (isEditing && (v == null || v.isEmpty)) return null; 
                    if (v == null || v.length != 4) return "Must be 4 digits";
                    return null;
                  },
                ),
               const SizedBox(height: 10),

               // DOB - Locked
               ListTile(
                 title: Text(_birthDate == null ? "Select Birth Date" : "DOB: ${_birthDate.toString().split(' ')[0]}"),
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
                       const Text("Medical Settings", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                       const Divider(),
                       Row(
                         children: [
                           Expanded(
                             child: DropdownButtonFormField<String>(
                                value: _diabetesType,
                                decoration: const InputDecoration(labelText: "Diabetes Type"),
                                items: const [
                                  DropdownMenuItem(value: 'T1', child: Text("Type 1")),
                                  DropdownMenuItem(value: 'T2', child: Text("Type 2")),
                                  DropdownMenuItem(value: 'NONE', child: Text("None")),
                                ],
                                onChanged: (v) => setState(() => _diabetesType = v!),
                             ),
                           ),
                           const SizedBox(width: 10),
                           Expanded(
                             child: DropdownButtonFormField<String>(
                                value: _therapyMode,
                                decoration: const InputDecoration(labelText: "Therapy"),
                                items: const [
                                  DropdownMenuItem(value: 'PEN', child: Text("Pen/Injections")),
                                  DropdownMenuItem(value: 'PUMP', child: Text("Pump")),
                                ],
                                onChanged: (v) => setState(() => _therapyMode = v!),
                             ),
                           ),
                         ],
                       ),
                       const SizedBox(height: 10),
                       TextFormField(
                         controller: _isController,
                         decoration: const InputDecoration(labelText: "Insulin Sensitivity (ISF)"),
                         keyboardType: TextInputType.number,
                         validator: (v) => v!.isEmpty ? "Required" : null,
                       ),
                       TextFormField(
                         controller: _crController,
                         decoration: const InputDecoration(labelText: "Carb Ratio (g/U)"),
                         keyboardType: TextInputType.number,
                         validator: (v) => v!.isEmpty ? "Required" : null,
                       ),
                       TextFormField(
                         controller: _targetController,
                         decoration: const InputDecoration(labelText: "Target Glucose (mg/dL)"),
                         keyboardType: TextInputType.number,
                         validator: (v) => v!.isEmpty ? "Required" : null,
                       ),
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
                   child: _isLoading ? const CircularProgressIndicator() : Text(isEditing ? "Save Changes" : "Create Profile"),
                 ),
               )
            ],
          ),
        ),
      ),
    );
  }
}
