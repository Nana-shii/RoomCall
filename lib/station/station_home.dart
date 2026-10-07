import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'register_patient.dart';
import 'registered_patients.dart';
import 'request_details.dart';

class StationHomePage extends StatelessWidget {
  const StationHomePage({super.key});

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

        title: const Row(
          children: [
            Icon(
              Icons.local_hospital_rounded,
              size: 27,
            ),
            SizedBox(width: 8),
            Text(
              'RoomCall Station',
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

      // =========================
      // DASHBOARD
      // =========================

      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
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
                'Unable to load dashboard.',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            );
          }

          final requests =
              snapshot.data?.docs ?? [];

          final currentRequests = requests.where((doc) {
            final data = doc.data() as Map<String, dynamic>;

            return data['status'] == 'PENDING' ||
                data['status'] == 'ACKNOWLEDGED' ||
                data['status'] == 'RESPONDING';
          }).toList();

          // =========================
          // REQUEST COUNTS
          // =========================

          final pendingCount = requests.where((doc) {
            final data =
            doc.data() as Map<String, dynamic>;

            return data['status'] == 'PENDING';
          }).length;

          final activeCount = requests.where((doc) {
            final data =
            doc.data() as Map<String, dynamic>;

            return data['status'] == 'ACKNOWLEDGED' ||
                data['status'] == 'RESPONDING';
          }).length;

          final completedCount = requests.where((doc) {
            final data =
            doc.data() as Map<String, dynamic>;

            return data['status'] == 'COMPLETED';
          }).length;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                // =========================
                // MAIN STATION
                // =========================

                const Text(
                  'Main Station',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F57),
                  ),
                ),

                const SizedBox(height: 5),

                const Text(
                  'Monitor patient assistance requests.',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),

                const SizedBox(height: 22),

                // =========================
                // STAT CARDS - ROW 1
                // =========================

                Row(
                  children: [
                    // PATIENTS
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('patients')
                            .snapshots(),

                        builder:
                            (context, patientSnapshot) {
                          final patientsCount =
                              patientSnapshot
                                  .data
                                  ?.docs
                                  .length ??
                                  0;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                  const RegisteredPatientsPage(),
                                ),
                              );
                            },

                            child: statCard(
                              icon: Icons.bed_rounded,
                              title: 'Patients',
                              value:
                              patientsCount.toString(),
                              color: primaryTeal,
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(width: 12),

                    // PENDING
                    Expanded(
                      child: statCard(
                        icon: Icons
                            .notifications_active_rounded,
                        title: 'Pending',
                        value:
                        pendingCount.toString(),
                        color:
                        const Color(0xFFFFA726),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // =========================
                // STAT CARDS - ROW 2
                // =========================

                Row(
                  children: [
                    // ACTIVE
                    Expanded(
                      child: statCard(
                        icon: Icons
                            .medical_services_rounded,
                        title: 'Active',
                        value:
                        activeCount.toString(),
                        color:
                        const Color(0xFF2196F3),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // COMPLETED
                    Expanded(
                      child: statCard(
                        icon: Icons
                            .check_circle_rounded,
                        title: 'Completed',
                        value:
                        completedCount.toString(),
                        color:
                        const Color(0xFF43A047),
                      ),
                    ),
                  ],
                ),

                // =========================
                // REGISTER NEW PATIENT
                // =========================

                const SizedBox(height: 20),

                SizedBox(
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
                      'Register New Patient',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    style:
                    ElevatedButton.styleFrom(
                      backgroundColor:
                      primaryTeal,
                      foregroundColor:
                      Colors.white,
                      elevation: 0,

                      shape:
                      RoundedRectangleBorder(
                        borderRadius:
                        BorderRadius.circular(
                          14,
                        ),
                      ),
                    ),
                  ),
                ),

                // =========================
                // CURRENT REQUESTS
                // =========================

                const SizedBox(height: 28),

                const Text(
                  'Current Requests',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F57),
                  ),
                ),

                const SizedBox(height: 12),

                if (currentRequests.isEmpty)
                  const Text(
                    'No requests yet.',
                    style: TextStyle(
                      color: Colors.blueGrey,
                    ),
                  ),

                // =========================
                // REQUEST LIST
                // =========================

                ...currentRequests.map((request) {
                  final data =
                  request.data()
                  as Map<String, dynamic>;

                  final requestType =
                      data['requestType'] ??
                          'UNKNOWN';

                  final room =
                      '${data['room'] ?? 'Unknown Room'} • ${data['bed'] ?? 'Unknown Bed'}';

                  final status =
                      data['status'] ?? 'UNKNOWN';

                  Color statusColor;

                  if (requestType ==
                      'EMERGENCY') {
                    statusColor =
                    const Color(0xFFFF5252);
                  } else if (requestType ==
                      'MEDICATION / PAIN') {
                    statusColor =
                    const Color(0xFFFFA726);
                  } else if (requestType ==
                      'BATHROOM ASSIST') {
                    statusColor =
                    const Color(0xFF2196F3);
                  } else {
                    statusColor =
                    const Color(0xFF43A047);
                  }

                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 12,
                    ),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequestDetailsPage(
                              requestType: requestType.toString(),
                              room: room,
                              status: status.toString(),
                              requestId: request.id,
                            ),
                          ),
                        );
                      },
                      child: requestCard(
                        requestType: requestType.toString(),
                        room: room,
                        status: status.toString(),
                        color: statusColor,
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  // =========================
  // STAT CARD
  // =========================

  Widget statCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,

        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),

          const SizedBox(height: 10),

          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight:
              FontWeight.bold,
              color: color,
            ),
          ),

          const SizedBox(height: 2),

          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.blueGrey,
              fontWeight:
              FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // REQUEST CARD
  // =========================

  Widget requestCard({
    required String requestType,
    required String room,
    required String status,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
        BorderRadius.circular(16),

        boxShadow: [
          BoxShadow(
            color:
            Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset:
            const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),

            child: const Icon(
              Icons
                  .notifications_active_rounded,
              color: Colors.white,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,

              children: [
                Text(
                  requestType,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight:
                    FontWeight.bold,
                    color:
                    Color(0xFF173F57),
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  room,
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                    Colors.blueGrey,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 6,
            ),

            decoration: BoxDecoration(
              color:
              color.withOpacity(0.12),
              borderRadius:
              BorderRadius.circular(20),
            ),

            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight:
                FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}