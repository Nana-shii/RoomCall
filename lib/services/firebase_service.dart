import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  static Future<String> sendRequest({
    required String requestType,
  }) async {
    final request = await _firestore.collection('requests').add({
      'room': 'Room 302',
      'bed': 'Bed A',
      'requestType': requestType,
      'status': 'PENDING',
      'createdAt': FieldValue.serverTimestamp(),
    });

    return request.id;
  }
}