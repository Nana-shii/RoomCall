import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_patient.dart';
import 'patient_details.dart';

class RegisteredPatientsPage extends StatelessWidget {
  const RegisteredPatientsPage({super.key});

  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // =========================
      // APP BAR
      // =========================

      appBar: AppBar(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Registered Patients',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // =========================
      // PATIENT LIST
      // =========================

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('patients')
            .orderBy(
          'createdAt',
          descending: true,
        )
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
              child: Text(
                'Unable to load patients.',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          final patients =
              snapshot.data?.docs ?? [];

          if (patients.isEmpty) {
            return const Center(
              child: Text(
                'No registered patients yet.',
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 16,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              100,
            ),

            itemCount: patients.length,

            itemBuilder: (context, index) {
              final patient = patients[index];

              final data =
              patient.data()
              as Map<String, dynamic>;

              final patientId =
                  data['patientId'] ?? 'No ID';

              final name =
                  data['name'] ??
                      'Unknown Patient';

              final room =
                  data['room'] ??
                      'Unknown Room';

              final bed =
                  data['bed'] ??
                      'Unknown Bed';

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          PatientDetailsPage(
                            patientId:
                            patientId.toString(),
                            name:
                            name.toString(),
                            room:
                            room.toString(),
                            bed:
                            bed.toString(),
                          ),
                    ),
                  );
                },

                child: Container(
                  width: double.infinity,

                  margin:
                  const EdgeInsets.only(
                    bottom: 12,
                  ),

                  padding:
                  const EdgeInsets.all(16),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(16),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.05),
                        blurRadius: 10,
                        offset:
                        const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Row(
                    children: [
                      // PATIENT ICON
                      Container(
                        width: 48,
                        height: 48,

                        decoration:
                        BoxDecoration(
                          color: primaryTeal
                              .withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.person_rounded,
                          color: primaryTeal,
                        ),
                      ),

                      const SizedBox(width: 14),

                      // PATIENT INFORMATION
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,

                          children: [
                            Text(
                              name.toString(),
                              style:
                              const TextStyle(
                                fontSize: 16,
                                fontWeight:
                                FontWeight.bold,
                                color:
                                Color(0xFF173F57),
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Patient ID: ${patientId.toString()}',
                              style:
                              const TextStyle(
                                fontSize: 12,
                                color:
                                Colors.blueGrey,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '${room.toString()} • ${bed.toString()}',
                              style:
                              const TextStyle(
                                fontSize: 13,
                                fontWeight:
                                FontWeight.w600,
                                color:
                                primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // ARROW
                      const Icon(
                        Icons
                            .arrow_forward_ios_rounded,
                        size: 16,
                        color: Colors.blueGrey,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      // =========================
      // REGISTER PATIENT BUTTON
      // =========================

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            16,
            10,
            16,
            10,
          ),

          child: SizedBox(
            width: double.infinity,
            height: 52,

            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                    const RegisterPatientPage(),
                  ),
                );
              },

              icon: const Icon(
                Icons.person_add_rounded,
              ),

              label: const Text(
                'Register Patient',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),

              style:
              ElevatedButton.styleFrom(
                backgroundColor: primaryTeal,
                foregroundColor: Colors.white,
                elevation: 0,

                shape:
                RoundedRectangleBorder(
                  borderRadius:
                  BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}