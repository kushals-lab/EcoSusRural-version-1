import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:eco_sus_rural/core/config/app_config.dart';
import 'package:eco_sus_rural/core/localization/language_provider.dart';
import 'package:eco_sus_rural/features/profile/providers/farmer_profile_provider.dart';

void main() {
  testWidgets('Simple widget build test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: Text('EcoSusRural'))),
      ),
    );

    expect(find.text('EcoSusRural'), findsOneWidget);
  });

  test('Legal agreement strings resolve through the Hindi translation dictionary', () {
    final notifier = LanguageNotifier();

    expect(notifier.translate('legalAgreementTitle', 'hi'), 'नियम, गोपनीयता और अखंडता समझौता');
  });

  test('FarmerProfileState soilType default matches the dropdown item label contract', () {
    expect(FarmerProfileState().soilType, 'Unknown / पता नहीं');
  });

  test('Dart UI HTTP and AI service defaults keep a safe localhost contract', () {
    final sanitizerHost = Platform.isAndroid ? '10.0.2.2' : '127.0.0.1';

    expect(AppConfig.apiBaseUrl, 'http://$sanitizerHost:5000/api');
    expect(AppConfig.aiServiceUrl, 'http://$sanitizerHost:8000');
    expect(AppConfig.connectTimeout, 5000);
    expect(AppConfig.receiveTimeout, 5000);
  });

  test('Dart gateway contract carries the expected backend-to-AI forwarding envelope', () {
    final backendRoute = '${AppConfig.apiBaseUrl}/gateway/forward-ai';
    final aiComputeRoute = '${AppConfig.aiServiceUrl}/compute';

    expect(backendRoute, 'http://${Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'}:5000/api/gateway/forward-ai');
    expect(aiComputeRoute, 'http://${Platform.isAndroid ? '10.0.2.2' : '127.0.0.1'}:8000/compute');
  });

  testWidgets('ListTile in a decorative container should not rely on Material transparency', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: DecoratedBox(
            decoration: BoxDecoration(color: Colors.white),
            child: ListTile(
              leading: Icon(Icons.check),
              title: Text('EcoSusRural tile'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ),
      ),
    );

    final transparentMaterials = tester.widgetList<Material>(find.byType(Material)).where(
      (material) => material.type == MaterialType.transparency,
    );

    expect(transparentMaterials.isEmpty, isTrue);
  });
}