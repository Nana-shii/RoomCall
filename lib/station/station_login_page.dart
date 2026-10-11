
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StationLoginPage extends StatefulWidget {
  const StationLoginPage({super.key});

  @override
  State<StationLoginPage> createState() => _StationLoginPageState();
}

class _StationLoginPageState extends State<StationLoginPage> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();

  bool isLoading = false;
  bool obscurePassword = true;

  static const Color teal = Color(0xFF1B8B7F);
  static const Color background = Color(0xFFF5FFFD);
  static const Color darkText = Color(0xFF173F57);

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (isLoading) return;

    final stationId = idController.text.trim();
    final password = passwordController.text;

    if (stationId.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your Station ID and password.'),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final result = await FirebaseFirestore.instance
          .collection('staff')
          .where('staffId', isEqualTo: stationId)
          .where('role', isEqualTo: 'station')
          .where('active', isEqualTo: true)
          .limit(1)
          .get();

      if (result.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Invalid Station ID or password.',
        );
      }

      final data = result.docs.first.data();
      final email = data['email'] as String?;

      if (email == null || email.isEmpty) {
        throw FirebaseAuthException(
          code: 'account-not-configured',
          message: 'Station account needs to be configured.',
        );
      }

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.code == 'invalid-credential'
                ? 'Invalid Station ID or password.'
                : e.message ?? 'Login failed. Please try again.',
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Login failed. Check your connection and account setup.',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: teal),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 18,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0EEEB)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: teal, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child:
                  const Icon(
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
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Your Call. Our Care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: teal,
                    letterSpacing: 0.5,
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  'Station Login',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                    color: darkText,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Sign in to manage patient requests.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.blueGrey,
                  ),
                ),

                const SizedBox(height: 28),

                TextField(
                  controller: idController,
                  textInputAction: TextInputAction.next,
                  decoration: _inputDecoration(
                    label: 'Station ID',
                    icon: Icons.badge_outlined,
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword,
                  onSubmitted: (_) => login(),
                  decoration: _inputDecoration(
                    label: 'Password',
                    icon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          obscurePassword = !obscurePassword;
                        });
                      },
                      icon: Icon(
                        obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: Colors.blueGrey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                SizedBox(
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: teal,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: teal.withValues(alpha: 0.6),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                        : const Text(
                      'Sign In',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'RoomCall • Your Call. Our Care.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blueGrey,
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
