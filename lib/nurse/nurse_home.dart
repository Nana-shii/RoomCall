import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NurseHomePage extends StatefulWidget {
  const NurseHomePage({super.key});

  @override
  State<NurseHomePage> createState() => _NurseHomePageState();
}

class _NurseHomePageState extends State<NurseHomePage> {
  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: background,

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
                'Nurse Dashboard',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          bottom: const TabBar(
            indicatorColor: Colors.white,
            indicatorWeight: 5,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            tabs: [
              Tab(text: 'Pending'),
              Tab(text: 'Active'),
            ],
          ),
        ),

        body: const TabBarView(
          children: [
            RequestList(
              status: 'PENDING',
            ),
            RequestList(
              status: 'ACTIVE',
            ),
          ],
        ),
      ),
    );
  }
}

class RequestList extends StatelessWidget {
  final String status;

  const RequestList({
    super.key,
    required this.status,
  });

  static const Color primaryTeal = Color(0xFF1B8B7F);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: status == 'ACTIVE'
          ? FirebaseFirestore.instance
          .collection('requests')
          .where(
        'status',
        whereIn: ['ACKNOWLEDGED', 'RESPONDING'],
      )
          .snapshots()
          : FirebaseFirestore.instance
          .collection('requests')
          .where(
        'status',
        isEqualTo: status,
      )
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
            child: Text(
              'Something went wrong.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.red,
              ),
            ),
          );
        }

        if (!snapshot.hasData ||
            snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'PENDING'
                      ? Icons.check_circle_outline_rounded
                      : Icons.medical_services_outlined,
                  size: 70,
                  color: primaryTeal,
                ),
                const SizedBox(height: 16),
                Text(
                  status == 'PENDING'
                      ? 'No pending requests'
                      : 'No active requests',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F57),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  status == 'PENDING'
                      ? 'All requests have been handled.'
                      : 'No requests are currently being handled.',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                  ),
                ),
              ],
            ),
          );
        }

        final requests = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,

          itemBuilder: (context, index) {
            final request = requests[index];

            final data =
            request.data() as Map<String, dynamic>;

            // Get the REAL status from Firestore.
            final requestStatus =
                data['status'] ?? 'UNKNOWN';

            final room =
                data['room'] ?? 'Unknown Room';

            final bed =
                data['bed'] ?? 'Unknown Bed';

            final requestType =
                data['requestType'] ?? 'Unknown Request';

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,

                children: [
                  // REQUEST HEADER
                  Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,

                        decoration: BoxDecoration(
                          color: requestType == 'EMERGENCY'
                              ? const Color(0xFFFF5252)
                              : primaryTeal,
                          shape: BoxShape.circle,
                        ),

                        child: const Icon(
                          Icons.notifications_active_rounded,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Text(
                          requestType,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F57),
                          ),
                        ),
                      ),

                      // STATUS
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: requestStatus == 'PENDING'
                              ? const Color(0xFFFFF3CD)
                              : const Color(0xFFEAF7F5),

                          borderRadius:
                          BorderRadius.circular(20),
                        ),

                        child: Text(
                          requestStatus,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: requestStatus == 'PENDING'
                                ? const Color(0xFF856404)
                                : primaryTeal,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ROOM
                  Row(
                    children: [
                      const Icon(
                        Icons.bed_rounded,
                        color: primaryTeal,
                      ),

                      const SizedBox(width: 10),

                      Text(
                        '$room • $bed',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,

                    child: ElevatedButton(
                      onPressed: () async {
                        if (requestStatus == 'PENDING') {
                          await FirebaseFirestore.instance
                              .collection('requests')
                              .doc(request.id)
                              .update({
                            'status': 'ACKNOWLEDGED',
                          });
                        }

                        else if (
                        requestStatus == 'ACKNOWLEDGED') {
                          await FirebaseFirestore.instance
                              .collection('requests')
                              .doc(request.id)
                              .update({
                            'status': 'RESPONDING',
                          });
                        }

                        else if (
                        requestStatus == 'RESPONDING') {
                          await FirebaseFirestore.instance
                              .collection('requests')
                              .doc(request.id)
                              .update({
                            'status': 'COMPLETED',
                          });
                        }
                      },

                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        elevation: 0,

                        shape:
                        RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(12),
                        ),
                      ),

                      child: Text(
                        requestStatus == 'PENDING'
                            ? 'Acknowledge Request'
                            : requestStatus == 'ACKNOWLEDGED'
                            ? 'Start Responding'
                            : 'Complete Request',

                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}