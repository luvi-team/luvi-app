import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:luvi_app/core/design_tokens/spacing.dart';
import 'package:luvi_app/features/auth/layout/auth_layout.dart';
import 'package:luvi_app/features/auth/state/login_state.dart';
import 'package:luvi_app/features/auth/state/login_submit_provider.dart';
import 'package:luvi_app/features/auth/widgets/global_error_banner.dart';
import 'package:luvi_app/features/auth/widgets/login_cta_section.dart';
import 'package:luvi_app/features/auth/widgets/login_form_section.dart';
import 'package:luvi_app/features/auth/widgets/login_header_section.dart';
import 'package:luvi_app/core/config/app_links.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supa;
// LaunchMode kommt über supabase_flutter (kein url_launcher nötig)

/// LoginScreen with pixel-perfect Figma implementation.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  static const String routeName = '/auth/login';

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  bool _obscurePassword = true;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GlobalKey _socialAuthKey = GlobalKey(debugLabel: 'login_social_auth');
  double _socialBlockHeight = AuthLayout.socialBlockReserveFallback;
  MediaQueryData? _lastMediaQuery;
  Locale? _lastLocale;
  bool _pendingSocialMeasurement = false;

  @override
  void initState() {
    super.initState();
    final loginNotifier = ref.read(loginProvider.notifier);
    final initialState = loginNotifier.currentState;
    if (_emailController.text != initialState.email) {
      _emailController.value = _emailController.value.copyWith(
        text: initialState.email,
        selection: TextSelection.collapsed(offset: initialState.email.length),
      );
    }
    if (_passwordController.text != initialState.password) {
      _passwordController.value = _passwordController.value.copyWith(
        text: initialState.password,
        selection: TextSelection.collapsed(
          offset: initialState.password.length,
        ),
      );
    }
    // Schedule initial measurement once after first layout.
    _scheduleSocialBlockMeasurement();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final mediaQuery = MediaQuery.of(context);
    final locale = Localizations.maybeLocaleOf(context);
    if (_shouldReMeasure(mediaQuery, locale)) {
      _lastMediaQuery = mediaQuery;
      _lastLocale = locale;
      _scheduleSocialBlockMeasurement();
    }
  }

  @override
  Widget build(BuildContext context) {
    final loginAsync = ref.watch(loginProvider);
    final loginState = loginAsync.value ?? LoginState.initial();
    final emailError = loginState.emailError;
    final passwordError = loginState.passwordError;
    final globalError = loginState.globalError;
    final submitState = ref.watch(loginSubmitProvider);
    final isLoading = submitState.isLoading;
    final hasValidationError = emailError != null || passwordError != null;

    // Measurement scheduled in initState and when dependencies change.

    void submit() => ref
        .read(loginSubmitProvider.notifier)
        .submit(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    final mediaQuery = MediaQuery.of(context);
    final safeBottom = mediaQuery.padding.bottom;
    final inlineReserve = AuthLayout.inlineCtaReserveLogin(_socialBlockHeight);
    final fieldScrollPadding = EdgeInsets.only(
      // Reserve unterhalb der Felder: CTA + Social-Block + Footer + safeBottom
      bottom: inlineReserve + safeBottom,
    );
    const gapBelowForgot = Spacing.m;
    const socialGap = Spacing.m;

    return Scaffold(
      key: const ValueKey('auth_login_screen'),
      resizeToAvoidBottomInset: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) => _buildScrollableBody(
                  context: context,
                  constraints: constraints,
                  fieldScrollPadding: fieldScrollPadding,
                  safeBottom: safeBottom,
                  gapBelowForgot: gapBelowForgot,
                  socialGap: socialGap,
                  globalError: globalError,
                  emailError: emailError,
                  passwordError: passwordError,
                  onSubmit: submit,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, safeBottom),
              child: LoginCtaSection(
                onSubmit: submit,
                onSignup: () => context.goNamed('signup'),
                hasValidationError: hasValidationError,
                isLoading: isLoading,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldReMeasure(MediaQueryData mediaQuery, Locale? locale) {
    final mediaChanged =
        _lastMediaQuery == null ||
        _mediaQueryChanged(_lastMediaQuery!, mediaQuery);
    final localeChanged = locale != _lastLocale;
    return mediaChanged || localeChanged;
  }

  bool _mediaQueryChanged(MediaQueryData previous, MediaQueryData next) {
    final previousScale = previous.textScaler.scale(1.0);
    final nextScale = next.textScaler.scale(1.0);
    return previous.size != next.size ||
        previous.padding != next.padding ||
        previous.viewInsets != next.viewInsets ||
        previous.devicePixelRatio != next.devicePixelRatio ||
        previousScale != nextScale;
  }

  void _scheduleSocialBlockMeasurement() {
    if (_pendingSocialMeasurement) {
      return;
    }
    _pendingSocialMeasurement = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _pendingSocialMeasurement = false;
      _measureSocialBlock();
    });
  }

  void _measureSocialBlock() {
    final element = _socialAuthKey.currentContext;
    if (element == null) {
      return;
    }
    final size = element.size;
    if (size == null) {
      return;
    }
    final measuredHeight = size.height;
    if ((measuredHeight - _socialBlockHeight).abs() > 0.5) {
      setState(() {
        _socialBlockHeight = measuredHeight;
      });
    }
  }

  Widget _buildScrollableBody({
    required BuildContext context,
    required BoxConstraints constraints,
    required EdgeInsets fieldScrollPadding,
    required double safeBottom,
    required double gapBelowForgot,
    required double socialGap,
    required String? globalError,
    required String? emailError,
    required String? passwordError,
    required VoidCallback onSubmit,
  }) {
    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.fromLTRB(Spacing.l, 0, Spacing.l, safeBottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(minHeight: constraints.maxHeight),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LoginHeaderSection(
              emailController: _emailController,
              passwordController: _passwordController,
              emailError: emailError,
              passwordError: passwordError,
              obscurePassword: _obscurePassword,
              fieldScrollPadding: fieldScrollPadding,
              onEmailChanged: _onEmailChanged,
              onPasswordChanged: _onPasswordChanged,
              onToggleObscure: _toggleObscurePassword,
              onForgotPassword: () => context.goNamed('forgot'),
              onSubmit: onSubmit,
            ),
            LoginFormSection(
              gapBelowForgot: gapBelowForgot,
              socialGap: socialGap,
              socialBlockKey: _socialAuthKey,
              onGoogle: () {
                final redirect = AppLinks.oauthRedirectUri;
                supa.Supabase.instance.client.auth.signInWithOAuth(
                  supa.OAuthProvider.google,
                  redirectTo: kIsWeb ? null : redirect,
                  authScreenLaunchMode: supa.LaunchMode.externalApplication,
                );
              },
              onApple: () {
                final redirect = AppLinks.oauthRedirectUri;
                supa.Supabase.instance.client.auth.signInWithOAuth(
                  supa.OAuthProvider.apple,
                  redirectTo: kIsWeb ? null : redirect,
                  authScreenLaunchMode: supa.LaunchMode.externalApplication,
                );
              },
            ),
            if (globalError != null) ...[
              const SizedBox(height: Spacing.m),
              GlobalErrorBanner(
                message: globalError,
                onTap: () =>
                    ref.read(loginProvider.notifier).clearGlobalError(),
              ),
            ],
            const SizedBox(height: AuthLayout.ctaTopAfterCopy),
          ],
        ),
      ),
    );
  }

  void _onEmailChanged(String value) {
    final notifier = ref.read(loginProvider.notifier);
    notifier.setEmail(value);
    final state = ref.read(loginProvider).value;
    if (state?.globalError != null) {
      notifier.clearGlobalError();
    }
  }

  void _onPasswordChanged(String value) {
    final notifier = ref.read(loginProvider.notifier);
    notifier.setPassword(value);
    final state = ref.read(loginProvider).value;
    if (state?.globalError != null) {
      notifier.clearGlobalError();
    }
  }

  void _toggleObscurePassword() {
    setState(() => _obscurePassword = !_obscurePassword);
  }
}
