import 'package:flutter/material.dart';
import '../../../core/storage/offline_workspace.dart';
import '../../../core/network/account_sync.dart';

class OfflineWorkspaceScreen extends StatefulWidget {
  const OfflineWorkspaceScreen({super.key});
  @override State<OfflineWorkspaceScreen> createState() => _OfflineWorkspaceScreenState();
}
class _OfflineWorkspaceScreenState extends State<OfflineWorkspaceScreen> {
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
      title: const Text('Product listing draft'), content: SingleChildScrollView(child: Form(key: form, child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: title, maxLength: 255, decoration: const InputDecoration(labelText: 'Product title'), validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null),
        TextFormField(controller: price, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Price (INR)'), validator: (v) => double.tryParse(v ?? '') == null || double.parse(v!) < 0 ? 'Enter a valid price' : null),
        TextFormField(controller: description, maxLines: 4, maxLength: 5000, decoration: const InputDecoration(labelText: 'Description')),
        const Text('Uploads require verified seller sign-in. Queued listings are not published until approved.'),
      ]))), actions: [TextButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(c, false); }, child: const Text('Save draft')),
        FilledButton(onPressed: () { if (form.currentState!.validate()) Navigator.pop(c, true); }, child: const Text('Queue upload'))]));
    if (queue != null) {
      await OfflineWorkspace.save('drafts', record?['id'] ?? DateTime.now().microsecondsSinceEpoch.toString(),
        {'title': title.text.trim(), 'price': double.parse(price.text), 'description': description.text.trim()}, queued: queue);
      await OfflineWorkspace.sync(); await _load();
    }
    title.dispose(); price.dispose(); description.dispose();
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Offline library & drafts')),
    floatingActionButton: FloatingActionButton.extended(onPressed: () => _draft(), icon: const Icon(Icons.add), label: const Text('Product draft')),
    body: SafeArea(child: ListView(padding: const EdgeInsets.fromLTRB(16,16,16,100), children: [
      const Text('Saved learning notes and product drafts remain available offline. Video streams require a connection unless a licensed download is provided.'),
      TextButton(onPressed: () async {
        await OfflineWorkspace.sync();
        await _load();
        if (context.mounted && AccountSync.accessToken == null) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Uploads remain pending: verified server sign-in is required.')));
        }
      }, child: const Text('Retry pending uploads')),
      ..._records.where((r) => ['drafts','learning'].contains(r['kind'])).map((r) => Card(child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        ListTile(title: Text(r['payload']['title'] ?? r['id']), subtitle: Text('Saved: ${r['savedAt']}\n${r['queued'] == true ? 'Pending upload — not published' : r['serverStatus'] ?? 'Saved locally'}')),
        Padding(padding: const EdgeInsets.all(12), child: Text(r['payload']['description'] ?? '')),
        Wrap(children: [if (r['kind'] == 'drafts') TextButton(onPressed: () => _draft(r), child: const Text('Edit draft')),
          TextButton(onPressed: () async { await OfflineWorkspace.remove(r['kind'], r['id']); await _load(); }, child: const Text('Remove local copy'))]),
      ]))),
    ])));
}
