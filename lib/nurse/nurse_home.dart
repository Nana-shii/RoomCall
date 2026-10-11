
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'nurse_login_page.dart';

class NurseHomePage extends StatefulWidget {
  const NurseHomePage({super.key});

  @override
  State<NurseHomePage> createState() => _NurseHomePageState();
}

class _NurseHomePageState extends State<NurseHomePage> {
  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text(
          'Are you sure you want to logout from RoomCall?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(false);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout != true || !mounted) return;

    try {
      await FirebaseAuth.instance.signOut();

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const NurseLoginPage(),
        ),
            (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to logout. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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
              Icon(Icons.local_hospital_rounded, size: 27),
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
          actions: [
            IconButton(
              tooltip: 'Logout',
              onPressed: _logout,
              icon: const Icon(Icons.logout_rounded),
            ),
            const SizedBox(width: 8),
          ],
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
            RequestList(status: 'PENDING'),
            RequestList(status: 'ACTIVE'),
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

  Future<void> updateRequestStatus({
    required BuildContext context,
    required String requestId,
    required String currentStatus,
  }) async {
    String? nextStatus;

    switch (currentStatus) {
      case 'PENDING':
        nextStatus = 'ACKNOWLEDGED';
        break;
      case 'ACKNOWLEDGED':
        nextStatus = 'RESPONDING';
        break;
      case 'RESPONDING':
        nextStatus = 'COMPLETED';
        break;
      default:
        return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': nextStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request updated to $nextStatus.'),
          backgroundColor: primaryTeal,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Unable to update request. Please try again.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot<Map<String, dynamic>>> requestStream =
    status == 'ACTIVE'
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
      isEqualTo: 'PENDING',
    )
        .snapshots();

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: requestStream,
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
                'Unable to load requests. Please check your connection.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            ),
          );
        }

        final requests = snapshot.data?.docs ?? [];

        if (requests.isEmpty) {
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

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            final request = requests[index];
            final data = request.data();

            final requestStatus =
                data['status'] as String? ?? 'UNKNOWN';
            final room =
                data['room']?.toString() ?? 'Unknown Room';
            final bed =
                data['bed']?.toString() ?? 'Unknown Bed';
            final requestType =
                data['requestType']?.toString() ?? 'Unknown Request';

            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(18),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
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
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: requestStatus == 'PENDING'
                              ? const Color(0xFFFFF3CD)
                              : const Color(0xFFEAF7F5),
                          borderRadius: BorderRadius.circular(20),
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
                  Row(
                    children: [
                      const Icon(
                        Icons.bed_rounded,
                        color: primaryTeal,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '$room • $bed',
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: [
                        'PENDING',
                        'ACKNOWLEDGED',
                        'RESPONDING',
                      ].contains(requestStatus)
                          ? () => updateRequestStatus(
                        context: context,
                        requestId: request.id,
                        currentStatus: requestStatus,
                      )
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryTeal,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.shade300,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        requestStatus == 'PENDING'
                            ? 'Acknowledge Request'
                            : requestStatus == 'ACKNOWLEDGED'
                            ? 'Start Responding'
                            : requestStatus == 'RESPONDING'
                            ? 'Complete Request'
                            : 'Request Completed',
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
