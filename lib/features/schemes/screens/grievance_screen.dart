import 'package:flutter/material.dart';
import '../../../core/network/account_sync.dart';
import '../../../core/network/official_links.dart';

class GrievanceScreen extends StatefulWidget {
  const GrievanceScreen({super.key});
  @override State<GrievanceScreen> createState() => _GrievanceScreenState();
}
class _GrievanceScreenState extends State<GrievanceScreen> {
  final _form = GlobalKey<FormState>();
  final _fields = {for (final key in ['name','mobile','email','commodity','market','transactionDate','priceReceived','evidence','description']) key: TextEditingController()};
  String _category = 'Suspected underpayment';
  String? _message;
  bool _sending = false;
  final _id = DateTime.now().microsecondsSinceEpoch.toString();
  @override void dispose() { for (final c in _fields.values) { c.dispose(); } super.dispose(); }
  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _sending = true);
    try {
      await AccountSync.send('grievances', {'id': _id, 'payload': {
        for (final e in _fields.entries) e.key: e.key == 'priceReceived' ? double.parse(e.value.text) : e.value.text.trim(), 'category': _category}});
      if (mounted) setState(() => _message = 'Received privately by EcoSusRural. This is not an official government complaint. Reference: $_id');
    } catch (_) { if (mounted) setState(() => _message = 'Not submitted. Secure server sign-in and grievance storage are required. You can use the official grievance portal below.'); }
    finally { if (mounted) setState(() => _sending = false); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Market grievance support')),
    body: SafeArea(child: Form(key: _form, child: ListView(padding: const EdgeInsets.all(16), children: [
      const Text('MSP procurement complaints depend on crop coverage, procurement scheme and agency eligibility. Private market payment or weighing disputes may require the market authority or another channel. A price below a reported mandi price does not by itself establish illegality.'),
      const SizedBox(height: 12),
      DropdownButtonFormField<String>(initialValue: _category, isExpanded: true,
        items: ['Suspected underpayment','Delayed payment','Incorrect weighing','Market irregularities','Other'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => _category = v!),
      ..._fields.entries.map((e) => Padding(padding: const EdgeInsets.only(top: 12), child: TextFormField(controller: e.value,
        maxLines: e.key == 'description' ? 4 : 1,
        decoration: InputDecoration(labelText: {'name':'Name','mobile':'Mobile','email':'Email (optional)','commodity':'Commodity','market':'Market','transactionDate':'Transaction date (YYYY-MM-DD)','priceReceived':'Price received (INR/quintal)','evidence':'Supporting evidence reference / secure URL (optional)','description':'Description'}[e.key]),
        validator: (v) {
          if (['email','evidence'].contains(e.key)) return null;
          if (v == null || v.trim().isEmpty) return 'Required';
          if (e.key == 'priceReceived' && (double.tryParse(v) == null || double.parse(v) < 0)) return 'Enter a valid non-negative price';
          if (e.key == 'transactionDate' && DateTime.tryParse(v) == null) return 'Use YYYY-MM-DD';
          return null;
        }))),
      const SizedBox(height: 12), const Text('Do not enter Aadhaar, bank passwords or payment credentials. This form is sent only to the authenticated EcoSusRural service. Evidence files must be uploaded directly to the official portal when required.'),
      if (_message != null) Text(_message!),
      FilledButton(onPressed: _sending ? null : _submit, child: const Text('Send privately to EcoSusRural')),
      OutlinedButton(onPressed: () => openOfficialLink(context, 'https://pgportal.gov.in/'), child: const Text('Open official CPGRAMS grievance portal')),
    ]))));
}
