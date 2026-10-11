import 'package:flutter/material.dart';

class RequestDetailsPage extends StatelessWidget {
  final String requestType;
  final String room;
  final String status;
  final String requestId;

  const RequestDetailsPage({
    super.key,
    required this.requestType,
    required this.room,
    required this.status,
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
        title: const Text(
          'Request Details',
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
              'Patient Assistance Request',
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.bold,
                color: Color(0xFF173F57),
              ),
            ),

            const SizedBox(height: 6),

            const Text(
              'View the details of this assistance request.',
              style: TextStyle(
                color: Colors.blueGrey,
              ),
            ),

            const SizedBox(height: 25),

            // REQUEST TYPE
            detailCard(
              icon: Icons.notifications_active_rounded,
              title: 'Request Type',
              value: requestType,
              color: requestColor(requestType),
            ),

            const SizedBox(height: 12),

            // ROOM / BED
            detailCard(
              icon: Icons.bed_rounded,
              title: 'Location',
              value: room,
              color: primaryTeal,
            ),

            const SizedBox(height: 12),

            // STATUS
            detailCard(
              icon: Icons.sync_rounded,
              title: 'Status',
              value: status,
              color: statusColor(status),
            ),

            const SizedBox(height: 12),

            // REQUEST ID
            detailCard(
              icon: Icons.tag_rounded,
              title: 'Request ID',
              value: requestId,
              color: Colors.blueGrey,
            ),

            const SizedBox(height: 30),

            // BACK BUTTON
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(
                  Icons.arrow_back_rounded,
                ),
                label: const Text(
                  'Back to Station',
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
          ],
        ),
      ),
    );
  }

  // =========================
  // DETAIL CARD
  // =========================

  Widget detailCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),

      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F57),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // REQUEST COLOR
  // =========================

  Color requestColor(String type) {
    if (type == 'EMERGENCY') {
      return const Color(0xFFFF5252);
    } else if (type == 'MEDICATION / PAIN') {
      return const Color(0xFFFFA726);
    } else if (type == 'BATHROOM ASSIST') {
      return const Color(0xFF2196F3);
    } else {
      return const Color(0xFF43A047);
    }
  }

  Color statusColor(String status) {
    if (status == 'PENDING') {
      return const Color(0xFFFFA726);
    } else if (status == 'ACKNOWLEDGED' ||
        status == 'RESPONDING') {
      return const Color(0xFF2196F3);
    } else if (status == 'COMPLETED') {
      return const Color(0xFF43A047);
    } else {
      return Colors.blueGrey;
    }
  }
}