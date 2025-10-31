import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:luvi_app/features/consent/state/consent_service.dart';

class ConsentButton extends ConsumerStatefulWidget {
  const ConsentButton({super.key});

  @override
  ConsumerState<ConsentButton> createState() => _ConsentButtonState();
}

class _ConsentButtonState extends ConsumerState<ConsentButton> {
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
        ref: ref as Ref,
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
