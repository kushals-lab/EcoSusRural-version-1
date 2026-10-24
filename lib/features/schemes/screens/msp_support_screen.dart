import 'package:flutter/material.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/official_links.dart';
import 'live_mandi_prices_screen.dart';
import 'grievance_screen.dart';

class MspSupportScreen extends StatefulWidget {
  const MspSupportScreen({super.key});
  @override State<MspSupportScreen> createState() => _MspSupportScreenState();
}
class _MspSupportScreenState extends State<MspSupportScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  bool _loading = false;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      final data = await DependencyInjection.apiClient.get('/msp', cacheTtl: const Duration(days: 30));
      if (mounted) setState(() { _data = Map<String, dynamic>.from(data); _error = null; });
    } catch (_) { if (mounted) setState(() => _error = 'Official MSP data unavailable. No prices are substituted.'); }
    finally { if (mounted) setState(() => _loading = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('MSP Support & Grievance')),
    body: SafeArea(child: RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('MSP is an officially declared support price for a covered crop and season. Mandi prices are reported market transactions. These are separate datasets.'),
      const SizedBox(height: 12),
      OutlinedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LiveMandiPricesScreen())), child: const Text('View reported mandi prices')),
      if (_loading) const LinearProgressIndicator(),
      if (_error != null) Text(_error!),
      if (_data != null) ...[
        Text('Published season: ${_data!['effective_season']}\nLast successful update: ${_data!['last_synced_at']}\n${_data!['_isCache'] == true || _data!['cache_status'] != 'fresh' ? 'Cached records — not live' : 'Latest retrieved official records'}'),
        const Text('Coverage is limited to the crops and season published by this source. Sugarcane FRP is excluded.'),
        ...((_data!['records'] as List?) ?? []).map((r) => Card(child: ListTile(title: Text(r['commodity'].toString()),
          subtitle: Text('MSP: ₹${r['msp']} per quintal\nSeason: ${r['season']}')))),
        TextButton(onPressed: () => openOfficialLink(context, _data!['source']), child: const Text('View price source')),
      ],
      OutlinedButton(onPressed: () => openOfficialLink(context, 'https://desagri.gov.in/notification-type/msp-notifications/'), child: const Text('Latest government MSP notifications')),
      FilledButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GrievanceScreen())), child: const Text('Report a market grievance')),
    ]))));
}
