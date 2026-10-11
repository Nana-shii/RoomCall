import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:room_call/station/register_patient.dart';
import 'package:room_call/station/station_home.dart';

import 'firebase_options.dart';
import 'patient/patient_home.dart';
import 'nurse/nurse_home.dart';
import 'station/station_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const RoomCallApp());
}

class RoomCallApp extends StatelessWidget {
  const RoomCallApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'RoomCall',
      home: const PatientHomePage(),
    );
  }
}