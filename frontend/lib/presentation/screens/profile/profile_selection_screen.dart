import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../bloc/auth/auth_bloc.dart';
import '../../../data/models/family_models.dart';
import '../../../data/repositories/family_repository.dart';

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
                 // Should ideally prompt to create one
                 return _buildCreateProfileButton();
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
        context.read<AuthBloc>().add(SelectProfile(profile));
      },
      child: Column(
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
          const SizedBox(height: 10),
          Text(
            profile.displayName,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          )
        ],
      ),
    );
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
      // MVP Dialog to create profile
      final nameController = TextEditingController();
      await showDialog(
          context: context, 
          builder: (context) => AlertDialog(
              title: const Text("New Profile"),
              content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
                      // Add other fields mocked for MVP
                  ],
              ),
              actions: [
                  TextButton(
                      child: const Text("Create"),
                      onPressed: () async {
                          final repo = context.read<FamilyRepository>();
                          try {
                              // Identify as child for now
                              await repo.createProfile(CreatePatientRequest(
                                  displayName: nameController.text, 
                                  diabetesType: "Type 1",
                                  insulinSensitivity: "1:50",
                                  carbRatio: "1:10",
                                  targetGlucose: "100"
                              ));
                              setState(() {
                                  _profilesFuture = repo.getProfiles();
                              });
                              Navigator.pop(context);
                          } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                      },
                  )
              ],
          )
      );
  }

  Color _getProfileColor(PatientProfile p) {
      if (p.isChild) return Colors.blueAccent;
      return Colors.teal;
  }
}
