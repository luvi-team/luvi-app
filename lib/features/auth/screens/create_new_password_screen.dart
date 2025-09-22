import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/login_password_field.dart';
import 'package:luvi_app/features/widgets/back_button.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _scrollController = ScrollController();
  final _headerKey = GlobalKey();
  final _ctaKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _confirmFieldKey = GlobalKey();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  static const EdgeInsets _fieldScrollPadding = EdgeInsets.only(
    bottom: Spacing.l,
    top: Spacing.m,
  );

  static const double _keyboardGap = Spacing.m;
  static const double _ctaStackHeight = Sizes.buttonHeight + Spacing.m;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _snapIntoViewWindow(GlobalKey fieldKey) async {
    final ctx = fieldKey.currentContext;
    final headerCtx = _headerKey.currentContext;
    final ctaCtx = _ctaKey.currentContext;
    if (ctx == null || headerCtx == null || ctaCtx == null) return;

    await Future<void>.microtask(() {});
    if (!mounted || !ctx.mounted || !_scrollController.hasClients) return;

    final fieldBox = ctx.findRenderObject() as RenderBox?;
    final headerBox = headerCtx.findRenderObject() as RenderBox?;
    final ctaBox = ctaCtx.findRenderObject() as RenderBox?;
    if (fieldBox == null || headerBox == null || ctaBox == null) return;

    final fieldRect = fieldBox.localToGlobal(Offset.zero) & fieldBox.size;
    final headerBottomY = headerBox.localToGlobal(Offset.zero).dy + headerBox.size.height;
    final ctaTopY = ctaBox.localToGlobal(Offset.zero).dy;

    final windowTop = headerBottomY + Spacing.m;
    final windowBottom = ctaTopY - _keyboardGap;
    if (windowBottom <= windowTop) return;

    final desiredTop = fieldRect.top < windowTop
        ? windowTop
        : (fieldRect.bottom > windowBottom
            ? windowBottom - fieldRect.height
            : fieldRect.top);

    final delta = desiredTop - fieldRect.top;
    if (delta.abs() < 0.5) return;

    final position = _scrollController.position;
    final targetOffset = (_scrollController.offset + delta)
        .clamp(position.minScrollExtent, position.maxScrollExtent);

    if ((targetOffset - _scrollController.offset).abs() < 0.5) return;

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;

    final backButtonTopSpacing = topOffsetFromSafeArea(
      context,
      AuthLayout.backButtonTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );

    final titleStyle = theme.textTheme.headlineMedium?.copyWith(
      fontSize: 24,
      height: 32 / 24,
      fontWeight: FontWeight.w400,
      color: theme.colorScheme.onSurface,
    );

    final subtitleStyle = theme.textTheme.bodySmall?.copyWith(
      fontSize: 17,
      height: 25 / 17,
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.onSurface,
    );

    final confirmTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );

    final confirmHintStyle = theme.textTheme.bodySmall?.copyWith(
      color: tokens.grayscale500,
    );

    final mediaQuery = MediaQuery.of(context);
    final keyboardInset = mediaQuery.viewInsets.bottom;
    final hasKeyboard = keyboardInset > 0;
    final safeTop = mediaQuery.padding.top;

    return Scaffold(
      key: const ValueKey('auth_create_new_screen'),
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        children: [
          AuthScreenShell(
            includeBottomReserve: false,
            controller: _scrollController,
            children: [
              Column(
                key: _headerKey,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: backButtonTopSpacing + 40 + AuthLayout.gapTitleToInputs / 2,
                  ),
                  Text('Neues Passwort erstellen 💜', style: titleStyle),
                  const SizedBox(height: Spacing.xs),
                  Text('Mach es stark.', style: subtitleStyle),
                ],
              ),
              const SizedBox(height: AuthLayout.gapTitleToInputs),
              Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) _snapIntoViewWindow(_passwordFieldKey);
                },
                child: LoginPasswordField(
                  key: _passwordFieldKey,
                  controller: _newPasswordController,
                  errorText: null,
                  onChanged: (_) {},
                  obscure: _obscureNewPassword,
                  onToggleObscure: () {
                    setState(() => _obscureNewPassword = !_obscureNewPassword);
                  },
                  textInputAction: TextInputAction.next,
                  onSubmitted: (_) => FocusScope.of(context).nextFocus(),
                  scrollPadding: _fieldScrollPadding,
                  hintText: 'Neues Passwort',
                ),
              ),
              const SizedBox(height: AuthLayout.gapInputToCta),
              Focus(
                onFocusChange: (hasFocus) {
                  if (hasFocus) _snapIntoViewWindow(_confirmFieldKey);
                },
                child: LoginPasswordField(
                  key: _confirmFieldKey,
                  controller: _confirmPasswordController,
                  errorText: null,
                  onChanged: (_) {},
                  obscure: _obscureConfirmPassword,
                  onToggleObscure: () {
                    setState(
                      () => _obscureConfirmPassword = !_obscureConfirmPassword,
                    );
                  },
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  scrollPadding: _fieldScrollPadding,
                  hintText: 'Neues Passwort bestätigen',
                  textStyle: confirmTextStyle,
                  hintStyle: confirmHintStyle,
                ),
              ),
              SizedBox(height: hasKeyboard ? _ctaStackHeight + _keyboardGap : 0),
            ],
          ),
          Positioned(
            top: safeTop + AuthLayout.backButtonTopInset,
            left: AuthLayout.horizontalPadding,
            child: BackButtonCircle(
              onPressed: () {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                } else {
                  context.go('/auth/login');
                }
              },
              size: 40,
              innerSize: 40,
              backgroundColor: theme.colorScheme.primary,
              iconColor: theme.colorScheme.onSurface,
              iconSize: 20,
            ),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: keyboardInset),
        child: SafeArea(
          top: false,
          bottom: !hasKeyboard,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              AuthLayout.horizontalPadding,
              Spacing.m,
              AuthLayout.horizontalPadding,
              hasKeyboard ? _keyboardGap : Spacing.s,
            ),
            child: SizedBox(
              key: _ctaKey,
              height: Sizes.buttonHeight,
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text('Speichern'),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
