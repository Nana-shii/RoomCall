
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'firebase_options.dart';
import 'nurse/nurse_login_page.dart';
import 'nurse/nurse_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const NurseApp());
}

class NurseApp extends StatelessWidget {
  const NurseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomCall Nurse',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState ==
              ConnectionState.waiting) {
            return const LoadingPage();
          }

          if (authSnapshot.hasError) {
            return const AccessDeniedPage(
              message: 'Unable to check your login. Please restart the app.',
            );
          }

          final user = authSnapshot.data;

          if (user == null) {
            return const NurseLoginPage();
          }

          return NurseAuthorizationPage(uid: user.uid);
        },
      ),
    );
  }
}

class NurseAuthorizationPage extends StatelessWidget {
  final String uid;

  const NurseAuthorizationPage({
    super.key,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final nurseStream = FirebaseFirestore.instance
        .collection('nurses')
        .doc(uid)
        .snapshots();

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: nurseStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const LoadingPage();
        }

        if (snapshot.hasError) {
          return AccessDeniedPage(
            message: snapshot.error is TimeoutException
                ? 'Verification timed out. Check your connection and try again.'
                : 'Unable to verify your nurse account. Check your connection and Firebase permissions.',
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const AccessDeniedPage(
            message:
            'Your nurse account could not be found. Please contact the administrator.',
          );
        }

        final data = snapshot.data!.data();

        if (data?['role'] != 'nurse') {
          return const AccessDeniedPage(
            message: 'Your account is not authorized as a nurse.',
          );
        }

        if (data?['active'] != true) {
          return const AccessDeniedPage(
            message:
            'Your account has been deactivated. Please contact the administrator.',
          );
        }

        return const NurseHomePage();
      },
    );
  }
}

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFFF5FFFD),
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
      backgroundColor: const Color(0xFFF5FFFD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.lock_outline,
                size: 56,
                color: Color(0xFF1B8B7F),
              ),
              const SizedBox(height: 16),
              const Text(
                'Access Restricted',
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
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B8B7F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
