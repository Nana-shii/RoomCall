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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_rounded,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(requestId)
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
                'Unable to load request status.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'Request not found.',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.red,
                ),
              ),
            );
          }

          final data =
          snapshot.data!.data()
          as Map<String, dynamic>;

          final status =
              data['status'] ?? 'PENDING';

          return Padding(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [
                const SizedBox(height: 30),

                // STATUS ICON
                Container(
                  width: 110,
                  height: 110,

                  decoration: BoxDecoration(
                    color: status == 'COMPLETED'
                        ? const Color(0xFF43A047)
                        : const Color(0xFFFF5252),

                    shape: BoxShape.circle,

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),

                  child: Icon(
                    status == 'COMPLETED'
                        ? Icons.check_rounded
                        : Icons.notifications_active_rounded,
                    color: Colors.white,
                    size: 55,
                  ),
                ),

                const SizedBox(height: 30),

                // TITLE
                Text(
                  status == 'PENDING'
                      ? 'Request Sent!'
                      : status == 'ACKNOWLEDGED'
                      ? 'Request Acknowledged'
                      : status == 'RESPONDING'
                      ? 'Nurse is Responding'
                      : 'Request Completed',

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
                  status == 'PENDING'
                      ? 'Your request for $requestType has been sent to the nursing staff. Please wait for assistance.'
                      : status == 'ACKNOWLEDGED'
                      ? 'A nurse has received your request and will assist you shortly.'
                      : status == 'RESPONDING'
                      ? 'A nurse is on the way to assist you.'
                      : 'Your request has been completed.',

                  textAlign: TextAlign.center,

                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.blueGrey,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

                // REQUEST DETAILS
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                    BorderRadius.circular(18),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.bed_rounded,
                            color: primaryTeal,
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Room 302 • Bed A',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          const Icon(
                            Icons.notifications_active_rounded,
                            color: primaryTeal,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              requestType,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Icon(
                            status == 'COMPLETED'
                                ? Icons.check_circle_rounded
                                : Icons.circle,
                            color: status == 'COMPLETED'
                                ? const Color(0xFF43A047)
                                : primaryTeal,
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              status,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: status ==
                                    'COMPLETED'
                                    ? const Color(0xFF43A047)
                                    : primaryTeal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                // BACK BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,

                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

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

                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 15),
              ],
            ),
          );
        },
      ),
    );
  }
}