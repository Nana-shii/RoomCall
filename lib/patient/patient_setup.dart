
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientSetupPage extends StatefulWidget {
  final Future<void> Function() onAssigned;

  const PatientSetupPage({
    super.key,
    required this.onAssigned,
  });

  @override
  State<PatientSetupPage> createState() =>
      _PatientSetupPageState();
}

class _PatientSetupPageState extends State<PatientSetupPage> {
  final TextEditingController patientIdController =
  TextEditingController();

  bool isLoading = false;

  Future<void> assignPatient() async {
    final patientId =
    patientIdController.text.trim().toUpperCase();

    if (patientId.isEmpty) {
      showMessage('Please enter a Patient ID.');
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      // Find the registered patient.
      final result = await FirebaseFirestore.instance
          .collection('patients')
          .where('patientId', isEqualTo: patientId)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        showMessage(
          'Patient ID not found. Check the ID and try again.',
        );
        return;
      }

      final patientData = result.docs.first.data();

      // Check whether the patient is still admitted.
      // Records without admissionStatus are treated as admitted.
      final admissionStatus =
          patientData['admissionStatus']?.toString() ??
              'ADMITTED';

      if (admissionStatus != 'ADMITTED') {
        showMessage(
          'Your admission has ended. '
              'Please contact the station for assistance.',
        );
        return;
      }

      // Save the verified Patient ID on this device.
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('assignedPatientId', patientId);

      if (!mounted) return;

      // Continue to Patient Home.
      await widget.onAssigned();
    } on FirebaseException catch (e) {
      debugPrint(
        'Firebase patient verification error: '
            '${e.code} - ${e.message}',
      );

      if (!mounted) return;

      if (e.code == 'permission-denied') {
        showMessage(
          'Access denied. Please check your Firestore rules.',
        );
      } else {
        showMessage(
          'Unable to verify patient. Check your connection '
              'and try again.',
        );
      }
    } catch (e) {
      debugPrint('Patient assignment error: $e');

      if (!mounted) return;

      showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    patientIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF1B8B7F);
    const background = Color(0xFFF5FFFD);

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('Patient Login'),
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.personal_injury_outlined,
                  size: 76,
                  color: primaryTeal,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Welcome to RoomCall',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F57),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Enter your registered Patient ID '
                      'to continue to the home page.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: patientIdController,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onSubmitted: (_) {
                    if (!isLoading) {
                      assignPatient();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Patient ID',
                    hintText: 'Example: P002',
                    prefixIcon: const Icon(Icons.badge_outlined),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(
                        color: Colors.grey.shade300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(
                        color: primaryTeal,
                        width: 2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : assignPatient,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      primaryTeal.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Use the Patient ID provided by the Main Station.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
