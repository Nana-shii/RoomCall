
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_patient.dart';
import 'patient_details.dart';

class RegisteredPatientsPage extends StatefulWidget {
  const RegisteredPatientsPage({super.key});

  @override
  State<RegisteredPatientsPage> createState() =>
      _RegisteredPatientsPageState();
}

class _RegisteredPatientsPageState
    extends State<RegisteredPatientsPage> {
  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  String selectedFilter = 'ADMITTED';
  final Set<String> _processingPatients = {};

  Future<void> _dischargePatient(
      BuildContext context,
      DocumentSnapshot patient,
      ) async {
    final data = patient.data() as Map<String, dynamic>;
    final patientId = data['patientId']?.toString() ?? '';
    final patientName =
        data['name']?.toString() ?? 'Unknown Patient';

    if (patientId.isEmpty) {
      _showMessage('Patient ID is missing.');
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Discharge Patient?'),
        content: Text(
          'Are you sure you want to discharge $patientName?\n\n'
              'New assistance requests will be blocked. '
              'The patient record and request history will be retained.',
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, true),
            child: const Text('Discharge'),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _processingPatients.add(patient.id));

    try {
      // Check for unresolved requests for this patient.
      final activeRequests = await FirebaseFirestore.instance
          .collection('requests')
          .where('patientId', isEqualTo: patientId)
          .where(
        'status',
        whereIn: [
          'PENDING',
          'ACKNOWLEDGED',
          'RESPONDING',
        ],
      )
          .limit(1)
          .get();

      if (activeRequests.docs.isNotEmpty) {
        _showMessage(
          'Cannot discharge this patient while requests '
              'are still pending or active. Resolve them first.',
        );
        return;
      }

      // Recheck current admission status before updating.
      final latestPatient = await FirebaseFirestore.instance
          .collection('patients')
          .doc(patient.id)
          .get();

      if (!latestPatient.exists) {
        _showMessage('Patient record no longer exists.');
        return;
      }

      final latestData = latestPatient.data()!;
      final latestStatus =
          latestData['admissionStatus']?.toString() ??
              'ADMITTED';

      if (latestStatus != 'ADMITTED') {
        _showMessage('This patient is already discharged.');
        return;
      }

      await latestPatient.reference.update({
        'admissionStatus': 'DISCHARGED',
        'dischargedAt': FieldValue.serverTimestamp(),
      });

      _showMessage('$patientName has been discharged.');
    } catch (e) {
      _showMessage('Unable to discharge patient: $e');
    } finally {
      if (mounted) {
        setState(() => _processingPatients.remove(patient.id));
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
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
          'Registered Patients',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: _filterButton(
                    label: 'Admitted',
                    value: 'ADMITTED',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _filterButton(
                    label: 'Discharged',
                    value: 'DISCHARGED',
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('patients')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: primaryTeal,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Text('Unable to load patients.'),
                  );
                }

                final allPatients =
                    snapshot.data?.docs ?? [];

                final patients = allPatients.where((patient) {
                  final data =
                  patient.data() as Map<String, dynamic>;

                  // Existing records without a status are admitted.
                  final status =
                      data['admissionStatus']?.toString() ??
                          'ADMITTED';

                  return status == selectedFilter;
                }).toList();

                if (patients.isEmpty) {
                  return Center(
                    child: Text(
                      selectedFilter == 'ADMITTED'
                          ? 'No admitted patients.'
                          : 'No discharged patients.',
                      style: const TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    16, 12, 16, 24,
                  ),
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    final data = patient.data()
                    as Map<String, dynamic>;

                    final patientId =
                        data['patientId'] ?? 'No ID';
                    final name =
                        data['name'] ?? 'Unknown Patient';
                    final room =
                        data['room'] ?? 'Unknown Room';
                    final bed =
                        data['bed'] ?? 'Unknown Bed';

                    final isAdmitted =
                        selectedFilter == 'ADMITTED';
                    final isProcessing =
                    _processingPatients.contains(patient.id);

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(
                              alpha: 0.05,
                            ),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            borderRadius:
                            BorderRadius.circular(12),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      PatientDetailsPage(
                                        patientId:
                                        patientId.toString(),
                                        name: name.toString(),
                                        room: room.toString(),
                                        bed: bed.toString(),
                                      ),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: primaryTeal.withValues(
                                      alpha: 0.12,
                                    ),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.person_rounded,
                                    color: primaryTeal,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name.toString(),
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF173F57),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Patient ID: $patientId',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '$room • $bed',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: primaryTeal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios_rounded,
                                  size: 16,
                                  color: Colors.blueGrey,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Icon(
                                isAdmitted
                                    ? Icons.check_circle_rounded
                                    : Icons.history_rounded,
                                size: 18,
                                color: isAdmitted
                                    ? primaryTeal
                                    : Colors.blueGrey,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  isAdmitted
                                      ? 'Admitted'
                                      : 'Discharged',
                                  style: TextStyle(
                                    color: isAdmitted
                                        ? primaryTeal
                                        : Colors.blueGrey,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (isAdmitted)
                                OutlinedButton(
                                  onPressed: isProcessing
                                      ? null
                                      : () => _dischargePatient(
                                    context,
                                    patient,
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    side: const BorderSide(
                                      color: Colors.red,
                                    ),
                                  ),
                                  child: isProcessing
                                      ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child:
                                    CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                      : const Text('Discharge'),
                                ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RegisterPatientPage(),
                  ),
                );
              },
              icon: const Icon(Icons.person_add_rounded),
              label: const Text(
                'Register Patient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _filterButton({
    required String label,
    required String value,
  }) {
    final selected = selectedFilter == value;

    return ElevatedButton(
      onPressed: () {
        setState(() => selectedFilter = value);
      },
      style: ElevatedButton.styleFrom(
        backgroundColor:
        selected ? primaryTeal : Colors.white,
        foregroundColor:
        selected ? Colors.white : primaryTeal,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: primaryTeal),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
