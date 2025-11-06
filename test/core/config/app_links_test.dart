import 'package:flutter_test/flutter_test.dart';
import 'package:luvi_app/core/config/app_links.dart';

void main() {
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
}
