import 'package:flutter/material.dart';

class PatientDetailsPage extends StatelessWidget {
  final String patientId;
  final String name;
  final String room;
  final String bed;

  const PatientDetailsPage({
    super.key,
    required this.patientId,
    required this.name,
    required this.room,
    required this.bed,
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
          'Patient Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),

                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),

              child: Column(
                children: [
                  Container(
                    width: 75,
                    height: 75,

                    decoration: BoxDecoration(
                      color: primaryTeal.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),

                    child: const Icon(
                      Icons.person_rounded,
                      size: 40,
                      color: primaryTeal,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Text(
                    name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF173F57),
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Patient ID: $patientId',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.blueGrey,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            detailCard(
              icon: Icons.meeting_room_rounded,
              title: 'Room',
              value: room,
            ),

            const SizedBox(height: 12),

            detailCard(
              icon: Icons.bed_rounded,
              title: 'Bed',
              value: bed,
            ),

            const SizedBox(height: 25),

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

  Widget detailCard({
    required IconData icon,
    required String title,
    required String value,
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
              color: primaryTeal.withOpacity(0.12),
              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: primaryTeal,
            ),
          ),

          const SizedBox(width: 14),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.blueGrey,
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
        ],
      ),
    );
  }
}