import 'package:flutter/material.dart';
import 'consent_service.dart';

class ConsentButton extends StatefulWidget {
  const ConsentButton({super.key});

  @override
  State<ConsentButton> createState() => _ConsentButtonState();
}

class _ConsentButtonState extends State<ConsentButton> {
  final _consentService = ConsentService();
  bool _isLoading = false;

  Future<void> _handleAccept() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _consentService.accept(
        version: 'v1.0',
        scopes: ['terms', 'privacy'],
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Consent accepted')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: _isLoading ? null : _handleAccept,
      child: _isLoading
          ? const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text('Accept Terms'),
    );
  }
}
