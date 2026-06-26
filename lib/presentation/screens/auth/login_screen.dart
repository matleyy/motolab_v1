import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isConnecting = false;

  Future<void> _handleGmailOAuth() async {
    setState(() { _isConnecting = true; });
    try {
      // Fires external browser frame handler
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'motolab://auth-callback',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign In Exception Interrupted: $e')),
      );
      setState(() { _isConnecting = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('⚡ MotoLab V1.0 ⚡', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Branch Terminal System Management Console'),
            const SizedBox(height: 32),
            _isConnecting 
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Sign In With Branch Gmail'),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16)),
                  onPressed: _handleGmailOAuth,
                ),
          ],
        ),
      ),
    );
  }
}
