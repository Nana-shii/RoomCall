
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterNursePage extends StatefulWidget {
  const RegisterNursePage({super.key});

  @override
  State<RegisterNursePage> createState() => _RegisterNursePageState();
}

class _RegisterNursePageState extends State<RegisterNursePage> {
  final nameController = TextEditingController();
  final nurseIdController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  static const Color teal = Color(0xFF1B8B7F);

  @override
  void dispose() {
    nameController.dispose();
    nurseIdController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> createNurseAccount() async {
    if (isLoading) return;

    final name = nameController.text.trim();
    final nurseId = nurseIdController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (name.isEmpty ||
        nurseId.isEmpty ||
        email.isEmpty ||
        password.isEmpty) {
      showMessage('Please complete all fields.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password must be at least 6 characters.');
      return;
    }

    setState(() => isLoading = true);

    FirebaseApp? secondaryApp;
    FirebaseAuth? secondaryAuth;

    try {
      final existingNurse = await FirebaseFirestore.instance
          .collection('nurses')
          .where('nurseId', isEqualTo: nurseId)
          .limit(1)
          .get();

      if (existingNurse.docs.isNotEmpty) {
        showMessage('This Nurse ID is already registered.');
        return;
      }

      secondaryApp = await Firebase.initializeApp(
        name: 'NurseRegistration_${DateTime.now().microsecondsSinceEpoch}',
        options: Firebase.app().options,
      );

      secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final credential =
      await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user == null) {
        throw Exception('Unable to create the nurse account.');
      }

      await FirebaseFirestore.instance
          .collection('nurses')
          .doc(user.uid)
          .set({
        'name': name,
        'nurseId': nurseId,
        'email': email,
        'role': 'nurse',
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage('Nurse account created successfully!');

      nameController.clear();
      nurseIdController.clear();
      emailController.clear();
      passwordController.clear();

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      final message = switch (e.code) {
        'email-already-in-use' =>
        'This email is already registered.',
        'invalid-email' => 'Please enter a valid email address.',
        'weak-password' => 'Please choose a stronger password.',
        'operation-not-allowed' =>
        'Enable Email/Password sign-in in Firebase Authentication.',
        _ => e.message ?? 'Unable to create the nurse account.',
      };

      showMessage(message);
    } catch (e) {
      if (mounted) {
        showMessage(
          'Account creation failed. Check your connection and Firebase setup.',
        );
      }
    } finally {
      if (secondaryAuth != null) {
        await secondaryAuth.signOut();
      }

      if (secondaryApp != null) {
        await secondaryApp.delete();
      }

      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFFD),
      appBar: AppBar(
        title: const Text('Create Nurse Account'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.person_add_alt_1_rounded,
                  size: 64,
                  color: teal,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Register a Nurse',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF173F57),
                  ),
                ),
                const SizedBox(height: 24),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nurse Name',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: nurseIdController,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Nurse ID',
                    hintText: 'e.g. N002',
                    prefixIcon: Icon(Icons.badge_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  maxLength: 20,
                  enableInteractiveSelection: true,
                  keyboardType: TextInputType.visiblePassword,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: InputDecoration(
                    labelText: 'Temporary Password',
                    helperText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed:
                    isLoading ? null : createNurseAccount,
                    icon: const Icon(Icons.person_add_rounded),
                    label: isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      'Create Nurse Account',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}