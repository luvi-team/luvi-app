import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/app_links.dart';

void main() {
  test('ProdAppLinks rejects sentinel and invalid hosts', () {
    const api = ProdAppLinks();
    expect(api.isConfiguredUrl(Uri.parse('about:blank')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://example.com/privacy')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://legal.luvi.app/privacy')), isTrue);
    expect(api.isConfiguredUrl(Uri.parse('https://localhost/legal')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://[::1]/legal')), isFalse);
  });

  test('ProdAppLinks blocks non-https schemes', () {
    const api = ProdAppLinks();
    expect(api.isConfiguredUrl(Uri.parse('http://secure.luvi.app')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://secure.luvi.app')), isTrue);
  });

  test('ProdAppLinks blocks IPv6 link-local fe80::/10', () {
    const api = ProdAppLinks();
    // fe80..febf should be blocked
    expect(api.isConfiguredUrl(Uri.parse('https://[fe80::1]/path')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://[fe8f::1]/index.html')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://[febf:abcd::1234]')), isFalse);
  });

  test('ProdAppLinks blocks IPv6 unique-local fc00::/7', () {
    const api = ProdAppLinks();
    expect(api.isConfiguredUrl(Uri.parse('https://[fc00::1]')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://[fdff::abcd]')), isFalse);
  });

  test('ProdAppLinks allows global IPv6 hosts outside fe80::/10 and fc00::/7', () {
    const api = ProdAppLinks();
    expect(api.isConfiguredUrl(Uri.parse('https://[2001:4860:4860::8888]')), isTrue);
    expect(api.isConfiguredUrl(Uri.parse('https://[2a00:1450:4001:829::200e]')), isTrue);
  });

  test('ProdAppLinks rejects private IPv4 ranges', () {
    const api = ProdAppLinks();
    expect(api.isConfiguredUrl(Uri.parse('https://10.0.0.5/legal')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://192.168.1.4/privacy')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://169.254.1.2/terms')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://172.16.0.1/legal')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://172.31.255.254/legal')), isFalse);
    // 172.32.x.x should be allowed (outside /12)
    expect(api.isConfiguredUrl(Uri.parse('https://172.32.0.1/legal')), isTrue);
  });

  test('ProdAppLinks rejects .local and .localhost hosts', () {
    const api = ProdAppLinks();
    expect(api.isConfiguredUrl(Uri.parse('https://printer.local/docs')), isFalse);
    expect(api.isConfiguredUrl(Uri.parse('https://app.localhost/legal')), isFalse);
  });

  test('ProdAppLinks rejects malformed IPv6 literals', () {
    const api = ProdAppLinks();
    final invalidUri = Uri.tryParse('https://[:::1]/legal');
    expect(invalidUri, isNull, reason: 'invalid IPv6 should fail parsing');
    expect(api.isConfiguredUrl(invalidUri), isFalse);
  });
}
