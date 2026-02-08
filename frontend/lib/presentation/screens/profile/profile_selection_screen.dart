import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../data/models/family_models.dart';
import '../../../data/repositories/family_repository.dart';
import '../auth/pin_verify_screen.dart';
import 'edit_patient_screen.dart';

class ProfileSelectionScreen extends StatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  State<ProfileSelectionScreen> createState() => _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState extends State<ProfileSelectionScreen> {
  late Future<List<PatientProfile>> _profilesFuture;

  @override
  void initState() {
    super.initState();
    // Ideally this comes from a FamilyBloc, but for MVP we fetch in UI
    final repo = context.read<FamilyRepository>();
    _profilesFuture = repo.getProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark background like Netflix
      appBar: AppBar(
        title: const Text("Who's using DiaBeaty?"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Center(
        child: FutureBuilder<List<PatientProfile>>(
            future: _profilesFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.white));
              }

              final profiles = snapshot.data ?? [];
              
              if (profiles.isEmpty) {
                 return Column(
                     mainAxisAlignment: MainAxisAlignment.center,
                     children: [
                       const Icon(Icons.family_restroom, size: 80, color: Colors.grey),
                       const SizedBox(height: 20),
                       const Text(
                         "Welcome to DiaBeaty Family",
                         style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                       ),
                       const SizedBox(height: 10),
                       const Text(
                         "Please create your first profile to get started.",
                         style: TextStyle(color: Colors.grey),
                       ),
                       const SizedBox(height: 30),
                       _buildCreateProfileButton(),
                     ],
                 );
              }

              return GridView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.all(32),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 0.8,
                ),
                itemCount: profiles.length + 1, // +1 for Add button
                itemBuilder: (context, index) {
                  if (index == profiles.length) {
                    return _buildAddProfileCard();
                  }
                  return _buildProfileCard(profiles[index]);
                },
              );
            },
        ),
      ),
    );
  }

  Widget _buildProfileCard(PatientProfile profile) {
    return GestureDetector(
      onTap: () {
        if (profile.isProtected) {
          Navigator.push(
            context,
            MaterialPageRoute(
               builder: (_) => PinVerifyScreen(profile: profile),
            ),
          );
        } else {
          context.read<AuthBloc>().add(SelectProfile(profile));
        }
      },
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                height: 100,
                width: 100,
                decoration: BoxDecoration(
                  color: _getProfileColor(profile),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white, width: 2)
                ),
                child: Icon(
                  profile.isChild ? Icons.child_care : Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              if (profile.isProtected)
                  Positioned(
                      bottom: 5,
                      right: 5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                            color: Colors.black54,
                            shape: BoxShape.circle
                        ),
                        child: const Icon(Icons.lock, size: 16, color: Colors.white),
                      )
                  ),
              Positioned(
                  top: 0,
                  right: 0,
                  child: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.white, size: 18),
                    onPressed: () => _editProfile(profile),
                  )
              )
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          )
        ],
      ),
    );
  }

  Future<void> _editProfile(PatientProfile profile) async {
      bool canEdit = true;
      bool startUnlocked = true;
      String? authPin;

      // Logic: 
      // Guardians: Must enter PIN to access.
      // Dependents: Can access without PIN.
      
      if (profile.role == 'GUARDIAN') {
          if (profile.isProtected) {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                   builder: (_) => PinVerifyScreen(profile: profile, verifyOnly: true),
                ),
              );
              // Result is String (PIN) if success, null if cancelled
              if (result != null && result is String) {
                  canEdit = true;
                  authPin = result;
              } else {
                  canEdit = false;
              }
          }
          startUnlocked = true; 
      } else {
          // Dependent
          canEdit = true; 
          startUnlocked = !profile.isProtected;
      }

      if (canEdit && mounted) {
          final bool? result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => EditPatientScreen(
                profile: profile, 
                isInitiallyUnlocked: startUnlocked,
                authPin: authPin
            )),
          );
          if (result == true) {
              setState(() {
                  final repo = context.read<FamilyRepository>();
                  _profilesFuture = repo.getProfiles();
              });
          }
      }
  }

  Widget _buildAddProfileCard() {
    return GestureDetector(
      onTap: () {
        // Show dialog
        _showAddProfileDialog();
      },
      child: Column(
        children: [
          Container(
            height: 100,
            width: 100,
            decoration: BoxDecoration(
              color: Colors.grey[800],
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.add, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 10),
          const Text(
            "Add Profile",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          )
        ],
      ),
    );
  }
  
  Widget _buildCreateProfileButton() {
      return ElevatedButton(
          onPressed: _showAddProfileDialog,
          child: const Text("Create First Profile")
      );
  }

  Future<void> _showAddProfileDialog() async {
      final bool? result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const EditPatientScreen()),
      );

      if (result == true) {
        setState(() {
            final repo = context.read<FamilyRepository>();
            _profilesFuture = repo.getProfiles();
        });
      }
  }

  Color _getProfileColor(PatientProfile p) {
      if (p.isChild) return Colors.blueAccent;
      return Colors.teal;
  }
}
