import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/family_models.dart';
import '../../../data/repositories/family_repository.dart';
import '../../bloc/auth/auth_bloc.dart';

class PinVerifyScreen extends StatefulWidget {
  final PatientProfile profile;
  final bool verifyOnly;

  const PinVerifyScreen({super.key, required this.profile, this.verifyOnly = false});

  @override
  State<PinVerifyScreen> createState() => _PinVerifyScreenState();
}

class _PinVerifyScreenState extends State<PinVerifyScreen> {
  String _pin = "";
  bool _isLoading = false;
  String? _error;

  void _onDigitPress(String digit) {
    if (_pin.length < 4) {
      setState(() {
        _pin += digit;
        _error = null;
      });
      if (_pin.length == 4) {
        _verifyPin();
      }
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin = _pin.substring(0, _pin.length - 1);
        _error = null;
      });
    }
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    try {
      final repo = context.read<FamilyRepository>();
      final isValid = await repo.verifyPin(widget.profile.id, _pin);
      
      if (isValid) {
        if (mounted) {
           if (widget.verifyOnly) {
              Navigator.pop(context, _pin);
           } else {
              context.read<AuthBloc>().add(SelectProfile(widget.profile));
              Navigator.pop(context);
           }
        }
      } else {
        setState(() {
            _error = "Incorrect PIN";
            _pin = "";
        });
      }
    } catch (e) {
      setState(() => _error = "Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        backgroundColor: Colors.transparent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, color: Colors.white, size: 48),
            const SizedBox(height: 20),
            Text(
              "Start PIN for ${widget.profile.displayName}",
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            const SizedBox(height: 30),
            _buildPinDots(),
            if (_error != null) ...[
                const SizedBox(height: 20),
                Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 16)),
            ],
            const SizedBox(height: 40),
            _buildKeypad(),
          ],
        ),
      ),
    );
  }

  Widget _buildPinDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index < _pin.length ? Colors.blueAccent : Colors.grey[800],
            border: Border.all(color: Colors.white)
          ),
        );
      }),
    );
  }

  Widget _buildKeypad() {
    return Container(
      width: 300,
      child: GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        childAspectRatio: 1.5,
        children: [
          ...List.generate(9, (index) => _buildKeyBtn("${index + 1}")),
          const SizedBox(), // Empty
          _buildKeyBtn("0"),
          IconButton(
            onPressed: _onDelete,
            icon: const Icon(Icons.backspace_outlined, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyBtn(String val) {
    return TextButton(
      onPressed: _isLoading ? null : () => _onDigitPress(val),
      child: Text(val, style: const TextStyle(color: Colors.white, fontSize: 24)),
    );
  }
}
