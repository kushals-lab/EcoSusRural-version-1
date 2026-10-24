import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/network/official_links.dart';
import '../models/scheme_model.dart';

class SchemeDetailScreen extends ConsumerWidget {
  final SchemeModel scheme;
  const SchemeDetailScreen({super.key, required this.scheme});
  @override Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.tr;
    return Scaffold(appBar: AppBar(title: Text(scheme.name)), body: SafeArea(child: ListView(
      padding: const EdgeInsets.all(16), children: [
        Text(scheme.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text('${scheme.provider} • ${scheme.providerCategory}'),
        const SizedBox(height: 12), Text(scheme.description),
        const SizedBox(height: 16), Text(t('eligibilityCriteria'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(scheme.eligibility),
        const SizedBox(height: 16), const Text('Required documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ...scheme.documents.map((d) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Text('• $d'))),
        const SizedBox(height: 16),
        Text('Application status: ${scheme.applicationStatus}'),
        Text('Opening date: ${scheme.openingDate ?? 'Not verified'}'),
        Text('Closing date: ${scheme.closingDate ?? 'Not verified'}'),
        Text('Official link last reviewed: ${scheme.lastVerifiedAt?.toIso8601String().split('T').first ?? 'Not verified'}'),
        const SizedBox(height: 12),
        const Text('The provider confirms eligibility, deadlines, identity and any official fee. Opening its website does not submit an application. EcoSusRural does not collect an application fee here.'),
        const SizedBox(height: 16),
        if (scheme.officialApplicationUrl != null)
          FilledButton(onPressed: () => openOfficialLink(context, scheme.officialApplicationUrl),
            child: Text('Apply for ${scheme.name}', textAlign: TextAlign.center))
        else const Text('Official application link unavailable'),
        if (scheme.officialInformationUrl != null)
          OutlinedButton(onPressed: () => openOfficialLink(context, scheme.officialInformationUrl),
            child: const Text('View verified official information'))
        else const Text('Official information source has not yet been verified.'),
      ])));
  }
}
