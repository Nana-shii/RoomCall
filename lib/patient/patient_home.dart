import 'package:flutter/material.dart';
import 'request_confirmation.dart';
import '../services/firebase_service.dart';

class PatientHomePage extends StatelessWidget {
  const PatientHomePage({super.key});

  static const Color primaryTeal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,

      // TOP BAR
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

      // BODY
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),

        child: Column(
          children: [
            // ROOM CARD
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),

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

              child: Row(
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

                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Room 302 • Bed A',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF173F57),
                          ),
                        ),

                        SizedBox(height: 5),

                        Row(
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10,
                              color: Color(0xFF2DBE70),
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Ready to assist',
                              style: TextStyle(
                                color: Color(0xFF2DBE70),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4),

                        Text(
                          'You\'re all set. Tap a button if you need assistance.',
                          style: TextStyle(
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

            // TITLE
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'How can we help you today?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF173F57),
                ),
              ),
            ),

            const SizedBox(height: 6),

            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Tap the button that matches your need.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blueGrey,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // 1. EMERGENCY
            requestButton(
              context,
              icon: Icons.notifications_active_rounded,
              title: 'EMERGENCY',
              subtitle: 'Need urgent help',
              color: const Color(0xFFFF5252),
            ),

            const SizedBox(height: 12),

            // 2. MEDICATION
            requestButton(
              context,
              icon: Icons.medication_rounded,
              title: 'MEDICATION / PAIN',
              subtitle: 'Request pain or meds',
              color: const Color(0xFFFFA726),
            ),

            const SizedBox(height: 12),

            // 3. BATHROOM
            requestButton(
              context,
              icon: Icons.accessibility_new_rounded,
              title: 'BATHROOM ASSIST',
              subtitle: 'Get help moving safely',
              color: const Color(0xFF2196F3),
            ),

            const SizedBox(height: 12),

            // 4. WATER / FOOD
            requestButton(
              context,
              icon: Icons.water_drop_rounded,
              title: 'WATER / FOOD',
              subtitle: 'Request basic refreshments',
              color: const Color(0xFF43A047),
            ),

            const SizedBox(height: 24),

            const Text(
              'We\'re here for you.',
              style: TextStyle(
                color: primaryTeal,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
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
      }) {
    return SizedBox(
      width: double.infinity,
      height: 82,

      child: ElevatedButton(
        onPressed: () async {
          print('1. BUTTON CLICKED');

          try {
            final requestId = await FirebaseService.sendRequest(
              requestType: title,
            );

            print('2. REQUEST ID: $requestId');

            if (!context.mounted) {
              print('3. CONTEXT NOT MOUNTED');
              return;
            }

            print('4. NAVIGATING');

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => RequestConfirmationPage(
                  requestType: title,
                  requestId: requestId,
                ),
              ),
            );

            print('5. NAVIGATION DONE');
          } catch (e) {
            print('ERROR: $e');
          }
        },

        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,

          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),

        child: Row(
          children: [
            // ICON
            Container(
              width: 52,
              height: 52,

              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.20),
                shape: BoxShape.circle,
              ),

              child: Icon(
                icon,
                size: 28,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 16),

            // TEXT
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
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // ARROW
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