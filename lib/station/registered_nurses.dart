import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

const Color stationTeal = Color(0xFF1B8B7F);
const Color stationBg = Color(0xFFF1FAF9);
const Color stationText = Color(0xFF173F57);

class RegisteredNursesPage extends StatelessWidget {
  const RegisteredNursesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: stationBg,
      appBar: AppBar(
        title: const Text('Registered Nurses'),
        backgroundColor: stationTeal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('nurses').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Unable to load nurse accounts. Check your connection and Firestore access.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(color: stationTeal),
            );
          }

          final nurses = (snapshot.data?.docs ?? []).where((doc) {
            return doc.data()['role'] == 'nurse';
          }).toList();

          nurses.sort((a, b) {
            final nameA = (a.data()['name'] ?? '').toString().toLowerCase();
            final nameB = (b.data()['name'] ?? '').toString().toLowerCase();
            return nameA.compareTo(nameB);
          });

          final activeCount = nurses.where((nurse) {
            return nurse.data()['active'] == true;
          }).length;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              const Text(
                'Registered Nurses',
                style: TextStyle(
                  color: stationText,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'View all nurse accounts registered in RoomCall.',
                style: TextStyle(color: Colors.blueGrey),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _summaryCard('Total Nurses', nurses.length,
                      Icons.people_alt_rounded),
                  _summaryCard('Active', activeCount,
                      Icons.verified_user_rounded),
                  _summaryCard('Inactive', nurses.length - activeCount,
                      Icons.person_off_rounded),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: const Color(0xFFDCEDEC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        'Nurse List (${nurses.length})',
                        style: const TextStyle(
                          color: stationText,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    if (nurses.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(28),
                        child: Center(
                          child: Text(
                            'No nurse accounts found.',
                            style: TextStyle(color: Colors.blueGrey),
                          ),
                        ),
                      )
                    else
                      ...nurses.map((nurse) {
                        final data = nurse.data();
                        final name =
                        (data['name'] ?? 'Name unavailable').toString();
                        final nurseId =
                        (data['nurseId'] ?? 'No Nurse ID').toString();
                        final email = (data['email'] ?? 'No email').toString();
                        final isActive = data['active'] == true;

                        return Column(
                          children: [
                            ListTile(
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 8,
                              ),
                              leading: const CircleAvatar(
                                backgroundColor: Color(0xFFD9F1ED),
                                child: Icon(
                                  Icons.medical_services_rounded,
                                  color: stationTeal,
                                ),
                              ),
                              title: Text(
                                name,
                                style: const TextStyle(
                                  color: stationText,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 6),
                                child: Text('Nurse ID: $nurseId\n$email'),
                              ),
                              isThreeLine: true,
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: isActive
                                      ? const Color(0xFFE3F7EC)
                                      : const Color(0xFFFFE8E8),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isActive ? 'Active' : 'Inactive',
                                  style: TextStyle(
                                    color: isActive
                                        ? const Color(0xFF168653)
                                        : Colors.red,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              height: 1,
                              indent: 18,
                              endIndent: 18,
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _summaryCard(String title, int count, IconData icon) {
    return SizedBox(
      width: 180,
      child: Card(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFDCEDEC)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Icon(icon, color: stationTeal, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$count',
                      style: const TextStyle(
                        color: stationTeal,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      title,
                      style: const TextStyle(color: stationText, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
