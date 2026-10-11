import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NurseLoginPage extends StatefulWidget {
  const NurseLoginPage({super.key});

  @override
  State<NurseLoginPage> createState() => _NurseLoginPageState();
}

class _NurseLoginPageState extends State<NurseLoginPage> {
  final nurseIdController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;
  String? errorMessage;

  static const Color teal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);

  Future<void> login() async {
    if (isLoading) return;

    final nurseId = nurseIdController.text.trim();
    final password = passwordController.text;

    if (nurseId.isEmpty || password.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your Nurse ID and password.';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final result = await FirebaseFirestore.instance
          .collection('nurses')
          .where('nurseId', isEqualTo: nurseId)
          .where('role', isEqualTo: 'nurse')
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        throw FirebaseAuthException(code: 'invalid-credential');
      }

      final data = result.docs.first.data();

      if (data['active'] != true) {
        throw FirebaseAuthException(code: 'account-disabled');
      }

      final email = data['email'] as String?;

      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(code: 'account-not-configured');
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

// NurseApp listens to authStateChanges().
// It will automatically open the Nurse Dashboard.
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(() {
        errorMessage = switch (e.code) {
          'invalid-credential' => 'Incorrect Nurse ID or password.',
          'account-disabled' =>
          'Your account has been deactivated. Please contact the administrator.',
          'too-many-requests' => 'Too many attempts. Please try again later.',
          'account-not-configured' =>
          'This nurse account needs to be configured.',
          _ => 'Login failed. Please check your account.',
        };
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        errorMessage =
        'Unable to log in. Check your connection and account setup.';
      });
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    nurseIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      appBar: AppBar(
        title: const Text('RoomCall Nurse'),
        backgroundColor: teal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child:const Icon(
                    Icons.notifications_active_rounded,
                    size: 90,
                    color: teal,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'RoomCall',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: teal,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Your Call. Our Care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    letterSpacing: 1.5,
                    color: teal,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Nurse Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF263238),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign in to access patient requests.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 28),
                TextField(
                  controller: nurseIdController,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText: 'Nurse ID',
                    prefixIcon: const Icon(
                      Icons.badge_outlined,
                      color: teal,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD5E8E4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: teal,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) {
                    if (!isLoading) login();
                  },
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: teal,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: Color(0xFFD5E8E4),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: teal,
                        width: 1.5,
                      ),
                    ),
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
                        color: teal,
                      ),
                    ),
                  ),
                ),
                if (errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor:
                      teal.withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isLoading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'LOGIN',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
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