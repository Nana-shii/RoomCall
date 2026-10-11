
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<String> sendRequest({
    required String patientId,
    required String requestType,
    required String room,
    required String bed,
  }) async {
    // Find the registered patient.
    final patientSnapshot = await _firestore
        .collection('patients')
        .where('patientId', isEqualTo: patientId)
        .limit(1)
        .get();

    if (patientSnapshot.docs.isEmpty) {
      throw Exception(
        'Patient record not found. Please contact the station.',
      );
    }

    final patientData = patientSnapshot.docs.first.data();

    // Older records without admissionStatus are treated as admitted.
    final admissionStatus =
        patientData['admissionStatus']?.toString() ?? 'ADMITTED';

    if (admissionStatus != 'ADMITTED') {
      throw Exception(
        'This patient is no longer admitted. '
            'Please contact the station.',
      );
    }

    final patientName =
        patientData['name']?.toString() ?? 'Unknown Patient';

    // Create a request only for an admitted patient.
    final request = await _firestore.collection('requests').add({
      'patientId': patientId,
      'patientName': patientName,
      'room': room,
      'bed': bed,
      'requestType': requestType,
      'status': 'PENDING',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return request.id;
  }
}
