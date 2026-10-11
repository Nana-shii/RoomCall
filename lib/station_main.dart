
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'station/station_login_page.dart';
import 'station/station_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RoomCallStationApp());
}

class RoomCallStationApp extends StatelessWidget {
  const RoomCallStationApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomCall Station',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const LoadingPage();
          }

          final user = authSnapshot.data;

          if (user == null) {
            return const StationLoginPage();
          }

          return StationAccessCheck(uid: user.uid);
        },
      ),
    );
  }
}

class StationAccessCheck extends StatelessWidget {
  final String uid;

  const StationAccessCheck({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      future: FirebaseFirestore.instance
          .collection('staff')
          .doc(uid)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        }

        if (snapshot.hasError) {
          return const AccessDeniedPage(
            message: 'Unable to verify your account. Please try again.',
          );
        }

        final data = snapshot.data?.data();

        if (data == null ||
            data['role'] != 'station' ||
            data['active'] != true) {
          return const AccessDeniedPage(
            message: 'Your account is not authorized for Main Station.',
          );
        }

        return const StationHomePage();
      },
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1B8B7F),
        ),
      ),
    );
  }
}

class AccessDeniedPage extends StatelessWidget {
  final String message;

  const AccessDeniedPage({
    super.key,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 64,
                color: Color(0xFF1B8B7F),
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Denied',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}