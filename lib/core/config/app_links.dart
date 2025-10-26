class AppLinks {
  static final Uri privacyPolicy = Uri.parse(
    const String.fromEnvironment(
      'PRIVACY_URL',
      defaultValue: 'https://example.com/privacy',
    ),
  );

  static final Uri termsOfService = Uri.parse(
    const String.fromEnvironment(
      'TERMS_URL',
      defaultValue: 'https://example.com/terms',
    ),
  );
}
