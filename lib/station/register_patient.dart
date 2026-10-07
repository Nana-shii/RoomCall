import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'station_home.dart';

class RegisterPatientPage extends StatefulWidget {
  const RegisterPatientPage({super.key});

  @override
  State<RegisterPatientPage> createState() =>
      _RegisterPatientPageState();
}

class _RegisterPatientPageState
    extends State<RegisterPatientPage> {
  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  final patientIdController = TextEditingController();
  final patientNameController = TextEditingController();
  final roomController = TextEditingController();
  final bedController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    patientIdController.dispose();
    patientNameController.dispose();
    roomController.dispose();
    bedController.dispose();
    super.dispose();
  }

  Future<void> registerPatient() async {
    if (_isSaving) return;

    FocusScope.of(context).unfocus();

    if (patientIdController.text.trim().isEmpty ||
        patientNameController.text.trim().isEmpty ||
        roomController.text.trim().isEmpty ||
        bedController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all fields.'),
        ),
      );

      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('patients')
          .add({
        'patientId': patientIdController.text.trim(),
        'name': patientNameController.text.trim(),
        'room': roomController.text.trim(),
        'bed': bedController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const StationHomePage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to register patient: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Register Patient',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Patient Information',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F57),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'Register the patient and assign their room and bed.',
              style: TextStyle(
                color: Colors.blueGrey,
              ),
            ),

            const SizedBox(height: 25),

            TextField(
              controller: patientIdController,
              decoration: inputDecoration(
                'Patient ID',
                Icons.badge_outlined,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: patientNameController,
              decoration: inputDecoration(
                'Patient Name',
                Icons.person_outline_rounded,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: roomController,
              decoration: inputDecoration(
                'Room Number',
                Icons.meeting_room_outlined,
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: bedController,
              decoration: inputDecoration(
                'Bed',
                Icons.bed_outlined,
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isSaving ? null : registerPatient,
                icon: _isSaving
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.person_add_rounded,
                ),
                label: Text(
                  _isSaving
                      ? 'Registering...'
                      : 'Register Patient',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryTeal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor:
                  primaryTeal.withOpacity(0.6),
                  disabledForegroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration inputDecoration(
      String label,
      IconData icon,
      ) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(
        icon,
        color: primaryTeal,
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: primaryTeal,
          width: 2,
        ),
      ),
    );
  }
}