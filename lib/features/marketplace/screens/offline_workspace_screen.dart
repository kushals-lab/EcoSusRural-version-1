import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/localization/language_provider.dart';
import '../../../core/storage/offline_workspace.dart';
import '../../../core/network/account_sync.dart';

class OfflineWorkspaceScreen extends ConsumerStatefulWidget {
  const OfflineWorkspaceScreen({super.key});
  @override ConsumerState<OfflineWorkspaceScreen> createState() => _OfflineWorkspaceScreenState();
}
class _OfflineWorkspaceScreenState extends ConsumerState<OfflineWorkspaceScreen> {
  String _tr(String key) => ref.read(languageProvider.notifier)
      .translate(key, ref.read(languageProvider).code);
  List<Map<String, dynamic>> _records = [];
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async { final data = await OfflineWorkspace.records(); if (mounted) setState(() => _records = data); }
  Future<void> _draft([Map<String, dynamic>? record]) async {
    final payload = record?['payload'] as Map? ?? {};
    final title = TextEditingController(text: payload['title']?.toString());
    final price = TextEditingController(text: payload['price']?.toString());
    final description = TextEditingController(text: payload['description']?.toString());
    final form = GlobalKey<FormState>();
    final queue = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: Text(_tr('productListingDraft')), content: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: title, maxLength: 255, decoration: InputDecoration(labelText: _tr('productTitle')), validator: (v) => v == null || v.trim().isEmpty ? _tr('requiredField') : null),
        TextFormField(controller: price, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: _tr('priceInr')), validator: (v) => double.tryParse(v ?? '') == null || double.parse(v!) < 0 ? _tr('validPrice') : null),
        TextFormField(controller: description, maxLines: 4, maxLength: 5000, decoration: InputDecoration(labelText: _tr('description'))),
        Text(_tr('draftUploadNote')),
      ]))), actions: [TextButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(c, false); }, child: Text(_tr('saveDraft'))),
        FilledButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(c, true); }, child: Text(_tr('queueUpload')))]));
    if (queue != null) {
      await OfflineWorkspace.save('drafts', record?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        {'title': title.text.trim(), 'price': double.parse(price.text), 'description': description.text.trim()}, queued: queue);
      await OfflineWorkspace.sync(); await _load();
    }
    title.dispose(); price.dispose(); description.dispose();
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: Text(ref.tr('offlineLibrary'))),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _draft(), icon: const Icon(Icons.add), label: Text(ref.tr('productDraft'))),
    body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,100), children: [
      Text(ref.tr('offlineLibraryNote')),
      TextButton(onPressed: () async {
        await OfflineWorkspace.sync();
        await _load();
        if (context.mounted && AccountSync.accessToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_tr('signInRequiredUpload'))));
        }
      }, child: Text(ref.tr('retryUploads'))),
      ..._records.where((r) => ['drafts','learning'].contains(r['kind'])).map((r) => Card(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ListTile(title: Text(r['payload']['title'] ?? r['id']), subtitle: Text('${ref.tr('savedAt')}: ${r['savedAt']}\n${r['queued'] == true ? ref.tr('pendingUpload') : r['serverStatus'] ?? ref.tr('savedLocally')}')),
        Padding(padding: const EdgeInsets.all(12), child: Text(r['payload']['description'] ?? '')),
        Wrap(children: [if (r['kind'] == 'drafts') TextButton(onPressed: () => _draft(r), child: Text(ref.tr('editDraft'))),
          TextButton(onPressed: () async { await OfflineWorkspace.remove(r['kind'], r['id']); await _load(); }, child: Text(ref.tr('removeLocalCopy')))]),
      ]))),
    ])));
}
