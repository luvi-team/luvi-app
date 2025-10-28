import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/sizes.dart';
import 'package:luvi_app/features/auth/strings/auth_strings.dart';
import 'package:luvi_app/core/theme/app_theme.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/shared/utils/layout_utils.dart';
import 'package:luvi_app/features/auth/widgets/auth_bottom_cta.dart';
import 'package:luvi_app/features/auth/widgets/auth_screen_shell.dart';
import 'package:luvi_app/features/auth/widgets/create_new/create_new_header.dart';
import 'package:luvi_app/features/auth/widgets/create_new/create_new_form.dart';
import 'package:luvi_app/features/auth/widgets/create_new/back_button_overlay.dart';
import 'package:luvi_app/features/auth/utils/field_auto_scroller.dart';

class CreateNewPasswordScreen extends StatefulWidget {
  static const String routeName = '/auth/password/new';

  const CreateNewPasswordScreen({super.key});

  @override
  State<CreateNewPasswordScreen> createState() =>
      _CreateNewPasswordScreenState();
}

class _CreateNewPasswordScreenState extends State<CreateNewPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final FieldAutoScroller _autoScroller =
      FieldAutoScroller(ScrollController());

  final _headerKey = GlobalKey();
  final _passwordFieldKey = GlobalKey();
  final _confirmFieldKey = GlobalKey();

  ScrollController get _scrollController => _autoScroller.controller;

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  static const double _backButtonSize = AuthLayout.backButtonSize;
  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<DsTokens>()!;
    final mediaQuery = MediaQuery.of(context);

    final backButtonTopSpacing = topOffsetFromSafeArea(
      AuthLayout.backButtonTop,
      figmaSafeTop: AuthLayout.figmaSafeTop,
    );
    final headerTopGap =
        backButtonTopSpacing +
        _backButtonSize +
        AuthLayout.gapTitleToInputs / 2;
    final confirmTextStyle = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurface,
    );
    final confirmHintStyle = theme.textTheme.bodySmall?.copyWith(
      color: tokens.grayscale500,
    );

    final safeBottom = mediaQuery.padding.bottom;
    final fieldScrollPadding = EdgeInsets.only(
      bottom: Sizes.buttonHeight + AuthLayout.inputToCta + safeBottom,
    );

    return Scaffold(
      key: const ValueKey('auth_create_new_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.colorScheme.surface,
      bottomNavigationBar: AuthBottomCta(
        topPadding: AuthLayout.inputToCta,
        child: SizedBox(
          height: Sizes.buttonHeight,
          width: double.infinity,
          child: ElevatedButton(
            key: const ValueKey('create_new_cta_button'),
            onPressed: () {},
            child: Text(AuthStrings.createNewCta),
          ),
        ),
      ),
      body: _CreateNewBody(
        scrollController: _scrollController,
        headerKey: _headerKey,
        headerTopGap: headerTopGap,
        autoScroller: _autoScroller,
        newPasswordController: _newPasswordController,
        confirmPasswordController: _confirmPasswordController,
        passwordFieldKey: _passwordFieldKey,
        confirmFieldKey: _confirmFieldKey,
        isNewPasswordObscured: _obscureNewPassword,
        isConfirmPasswordObscured: _obscureConfirmPassword,
        onToggleNewPassword: () {
          setState(() => _obscureNewPassword = !_obscureNewPassword);
        },
        onToggleConfirmPassword: () {
          setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
        },
        fieldScrollPadding: fieldScrollPadding,
        confirmTextStyle: confirmTextStyle,
        confirmHintStyle: confirmHintStyle,
        safeTop: mediaQuery.padding.top,
        backgroundColor: theme.colorScheme.primary,
        iconColor: theme.colorScheme.onSurface,
      ),
    );
  }
}

class _CreateNewBody extends StatelessWidget {
  const _CreateNewBody({
    required this.scrollController,
    required this.headerKey,
    required this.headerTopGap,
    required this.autoScroller,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.passwordFieldKey,
    required this.confirmFieldKey,
    required this.isNewPasswordObscured,
    required this.isConfirmPasswordObscured,
    required this.onToggleNewPassword,
    required this.onToggleConfirmPassword,
    required this.fieldScrollPadding,
    required this.confirmTextStyle,
    required this.confirmHintStyle,
    required this.safeTop,
    required this.backgroundColor,
    required this.iconColor,
  });

  final ScrollController scrollController;
  final GlobalKey headerKey;
  final double headerTopGap;
  final FieldAutoScroller autoScroller;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final GlobalKey passwordFieldKey;
  final GlobalKey confirmFieldKey;
  final bool isNewPasswordObscured;
  final bool isConfirmPasswordObscured;
  final VoidCallback onToggleNewPassword;
  final VoidCallback onToggleConfirmPassword;
  final EdgeInsets fieldScrollPadding;
  final TextStyle? confirmTextStyle;
  final TextStyle? confirmHintStyle;
  final double safeTop;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AuthScreenShell(
          includeBottomReserve: false,
          controller: scrollController,
          children: [
            CreateNewHeader(headerKey: headerKey, topGap: headerTopGap),
            const SizedBox(height: AuthLayout.gapTitleToInputs),
            CreateNewForm(
              autoScroller: autoScroller,
              newPasswordController: newPasswordController,
              confirmPasswordController: confirmPasswordController,
              passwordFieldKey: passwordFieldKey,
              confirmFieldKey: confirmFieldKey,
              isNewPasswordObscured: isNewPasswordObscured,
              isConfirmPasswordObscured: isConfirmPasswordObscured,
              onToggleNewPassword: onToggleNewPassword,
              onToggleConfirmPassword: onToggleConfirmPassword,
              fieldScrollPadding: fieldScrollPadding,
              confirmTextStyle: confirmTextStyle,
              confirmHintStyle: confirmHintStyle,
            ),
          ],
        ),
        CreateNewBackButtonOverlay(
          safeTop: safeTop,
          onPressed: () {
            final router = GoRouter.of(context);
            if (router.canPop()) {
              router.pop();
            } else {
              context.goNamed('login');
            }
          },
          backgroundColor: backgroundColor,
          iconColor: iconColor,
          size: _CreateNewPasswordScreenState._backButtonSize,
          iconSize: AuthLayout.backIconSize,
        ),
      ],
    );
  }
}
