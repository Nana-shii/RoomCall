
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'request_confirmation.dart';
import 'patient_setup.dart';
import '../services/firebase_service.dart';

class PatientHomePage extends StatefulWidget {
  const PatientHomePage({super.key});

  @override
  State<PatientHomePage> createState() => _PatientHomePageState();
}

class _PatientHomePageState extends State<PatientHomePage> {
  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  String patientId = '';
  bool isLoadingPatientId = true;

  @override
  void initState() {
    super.initState();
    loadPatientId();
  }

  Future<void> loadPatientId() async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getString('assignedPatientId');

    if (!mounted) return;

    setState(() {
      patientId = savedId ?? '';
      isLoadingPatientId = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoadingPatientId) {
      return const Scaffold(
        backgroundColor: background,
        body: Center(
          child: CircularProgressIndicator(
            color: primaryTeal,
          ),
        ),
      );
    }

    if (patientId.isEmpty) {
      return PatientSetupPage(
        onAssigned: loadPatientId,
      );
    }

    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Row(
          children: [
            Icon(
              Icons.notifications_active_rounded,
              size: 27,
            ),
            SizedBox(width: 8),
            Text(
              'RoomCall',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
            ),
          ),
        ],
      ),

      // REAL-TIME PATIENT INFORMATION
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .where('patientId', isEqualTo: patientId)
            .limit(1)
            .snapshots(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: primaryTeal,
              ),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load patient information. '
                      'Check your connection.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.person_search_rounded,
                      size: 60,
                      color: Colors.blueGrey,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Patient information not found.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text('Assigned Patient ID: $patientId'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        final prefs =
                        await SharedPreferences.getInstance();
                        await prefs.remove('assignedPatientId');

                        if (!context.mounted) return;

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => PatientSetupPage(
                              onAssigned: loadPatientId,
                            ),
                          ),
                        );
                      },
                      child: const Text('Change Patient ID'),
                    ),
                  ],
                ),
              ),
            );
          }

          final patientData = snapshot.data!.docs.first.data();

          final name =
              patientData['name']?.toString() ?? 'Unknown Patient';

          final registeredPatientId =
              patientData['patientId']?.toString() ?? patientId;

          final room =
              patientData['room']?.toString() ?? 'Unknown Room';

          final bed =
              patientData['bed']?.toString() ?? 'Unknown Bed';

          // Missing status is treated as admitted for older records.
          final admissionStatus =
              patientData['admissionStatus']?.toString() ?? 'ADMITTED';

          final isDischarged = admissionStatus != 'ADMITTED';

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              children: [
                // PATIENT / ROOM CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 55,
                        height: 55,
                        decoration: const BoxDecoration(
                          color: Color(0xFFA7E8E0),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bed_rounded,
                          color: primaryTeal,
                          size: 30,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '$name ($registeredPatientId)',
                              style: const TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF173F57),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '$room • $bed',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: primaryTeal,
                              ),
                            ),
                            const SizedBox(height: 5),

                            // LIVE ADMISSION STATUS
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: isDischarged
                                      ? Colors.red
                                      : const Color(0xFF2DBE70),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    isDischarged
                                        ? 'Admission Ended'
                                        : 'Ready to assist',
                                    style: TextStyle(
                                      color: isDischarged
                                          ? Colors.red
                                          : const Color(0xFF2DBE70),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              isDischarged
                                  ? 'Your admission has ended.'
                                  : "You're all set. Tap a button if you need assistance.",
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 26),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isDischarged
                        ? 'Admission Status'
                        : 'How can we help you today?',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F57),
                    ),
                  ),
                ),

                const SizedBox(height: 6),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    isDischarged
                        ? 'Please contact the station for assistance.'
                        : 'Tap the button that matches your need.',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // DISCHARGED MESSAGE OR ACTIVE REQUEST BUTTONS
                if (isDischarged)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.red.shade200,
                      ),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: Colors.red,
                          size: 40,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Your admission has ended.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Please contact the station for assistance.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ],
                    ),
                  )
                else ...[
                  requestButton(
                    context,
                    icon: Icons.notifications_active_rounded,
                    title: 'EMERGENCY',
                    subtitle: 'Need urgent help',
                    color: const Color(0xFFFF5252),
                    room: room,
                    bed: bed,
                  ),

                  const SizedBox(height: 12),

                  requestButton(
                    context,
                    icon: Icons.medication_rounded,
                    title: 'MEDICATION / PAIN',
                    subtitle: 'Request pain or meds',
                    color: const Color(0xFFFFA726),
                    room: room,
                    bed: bed,
                  ),

                  const SizedBox(height: 12),

                  requestButton(
                    context,
                    icon: Icons.accessibility_new_rounded,
                    title: 'BATHROOM ASSIST',
                    subtitle: 'Get help moving safely',
                    color: const Color(0xFF2196F3),
                    room: room,
                    bed: bed,
                  ),

                  const SizedBox(height: 12),

                  requestButton(
                    context,
                    icon: Icons.water_drop_rounded,
                    title: 'WATER / FOOD',
                    subtitle: 'Request basic refreshments',
                    color: const Color(0xFF43A047),
                    room: room,
                    bed: bed,
                  ),
                ],

                const SizedBox(height: 24),

                const Text(
                  "We're here for you.",
                  style: TextStyle(
                    color: primaryTeal,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // REQUEST BUTTON
  Widget requestButton(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String subtitle,
        required Color color,
        required String room,
        required String bed,
      }) {
    return SizedBox(
      width: double.infinity,
      height: 82,
      child: ElevatedButton(
        onPressed: () async {
          try {
            final requestId = await FirebaseService.sendRequest(
              patientId: patientId,
              requestType: title,
              room: room,
              bed: bed,
            );

            if (!context.mounted) return;

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => RequestConfirmationPage(
                  requestType: title,
                  requestId: requestId,
                ),
              ),
            );
          } catch (e) {
            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  e.toString().replaceFirst('Exception: ', ''),
                ),
              ),
            );

            debugPrint('Failed to send request: $e');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.20),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }
}
