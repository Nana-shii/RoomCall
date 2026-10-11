
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RequestConfirmationPage extends StatelessWidget {
  final String requestType;
  final String requestId;

  const RequestConfirmationPage({
    super.key,
    required this.requestType,
    required this.requestId,
  });

  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        backgroundColor: primaryTeal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          '$requestType Request',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: primaryTeal),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Unable to load request status.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Request not found.',
                style: TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          final status = data['status']?.toString() ?? 'PENDING';
          final patientName =
              data['patientName']?.toString() ?? 'Unknown Patient';
          final patientId = data['patientId']?.toString() ?? 'Unknown ID';
          final room = data['room']?.toString() ?? 'Unknown Room';
          final bed = data['bed']?.toString() ?? 'Unknown Bed';
          final request = data['requestType']?.toString() ?? requestType;

          late final IconData statusIcon;
          late final Color statusColor;
          late final String statusTitle;
          late final String statusDescription;

          switch (status) {
            case 'ACKNOWLEDGED':
              statusIcon = Icons.check_circle_rounded;
              statusColor = const Color(0xFF2196F3);
              statusTitle = 'Request Acknowledged';
              statusDescription =
              'A nurse has received your request and will assist you shortly.';
              break;

            case 'RESPONDING':
              statusIcon = Icons.directions_walk_rounded;
              statusColor = const Color(0xFFFFA726);
              statusTitle = 'Nurse is Responding';
              statusDescription = 'A nurse is on the way to assist you.';
              break;

            case 'COMPLETED':
              statusIcon = Icons.check_rounded;
              statusColor = const Color(0xFF43A047);
              statusTitle = 'Request Completed';
              statusDescription = 'Your request has been completed.';
              break;

            case 'PENDING':
            default:
              statusIcon = Icons.notifications_active_rounded;
              statusColor = const Color(0xFFFF5252);
              statusTitle = 'Request Sent!';
              statusDescription =
              'Your request for $request has been sent to the nursing staff. Please wait for assistance.';
              break;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 10),

                // STATUS ICON
                Center(
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Icon(
                      statusIcon,
                      color: Colors.white,
                      size: 55,
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // STATUS TITLE
                Text(
                  statusTitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F57),
                  ),
                ),

                const SizedBox(height: 10),

                // DESCRIPTION
                Text(
                  statusDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                // REQUEST DETAILS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
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
                    children: [
                      _detailRow(
                        Icons.person_rounded,
                        '$patientName ($patientId)',
                      ),
                      const SizedBox(height: 18),
                      _detailRow(
                        Icons.bed_rounded,
                        '$room • $bed',
                      ),
                      const SizedBox(height: 18),
                      _detailRow(
                        Icons.notifications_active_rounded,
                        request,
                      ),
                      const SizedBox(height: 18),
                      _detailRow(
                        statusIcon,
                        statusTitle,
                        color: statusColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // BACK BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryTeal,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(
      IconData icon,
      String text, {
        Color color = primaryTeal,
      }) {
    return Row(
      children: [
        Icon(icon, color: color),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: color == primaryTeal ? Colors.black87 : color,
            ),
          ),
        ),
      ],
    );
  }
}