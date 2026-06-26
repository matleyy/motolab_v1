import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PinOverrideDialog extends StatefulWidget {
  final Function() onApprovalSuccess;

  const PinOverrideDialog({super.key, required this.onApprovalSuccess});

  @override
  State<PinOverrideDialog> createState() => _PinOverrideDialogState();
}

class _PinOverrideDialogState extends State<PinOverrideDialog> {
  final TextEditingController _pinController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _verifySupervisorPIN() async {
    setState(() { _isLoading = true; _errorMessage = null; });
    try {
      final response = await Supabase.instance.client
          .from('users')
          .select('name, role')
          .eq('pin_hash', _pinController.text) // In production, match SHA-256 string hash
          .inFilter('role', ['Owner', 'Finance'])
          .maybeSingle();

      if (response != null) {
        Navigator.of(context).pop(); // Close dialog screen
        widget.onApprovalSuccess();  // Trigger application price unlock
      } else {
        setState(() { _errorMessage = "Invalid Authorization PIN."; });
      }
    } catch (e) {
      setState(() { _errorMessage = "Verification Failed: Server Unreachable."; });
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Freeze system back-button actions
      child: AlertDialog(
        title: const Text('⚠️ Supervisor Override Required'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('This operation requires an Owner or Finance security PIN confirmation.'),
            const SizedBox(height: 16),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Enter Secure PIN',
                errorText: _errorMessage,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _verifySupervisorPIN,
            child: _isLoading ? const CircularProgressIndicator() : const Text('Authorize'),
          ),
        ],
      ),
    );
  }
}
