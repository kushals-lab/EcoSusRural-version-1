/// Crop profile create/edit sheet (Page B). Validated before save.
library;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/crop_profile.dart';
import '../providers/dryer_extra_providers.dart';
class CropProfileEditSheet extends ConsumerStatefulWidget {
  final CropProfile? existing;
  const CropProfileEditSheet({super.key, this.existing});
  @override
  ConsumerState<CropProfileEditSheet> createState() =>
      _CropProfileEditSheetState();
}
class _CropProfileEditSheetState
    extends ConsumerState<CropProfileEditSheet> {
  late final TextEditingController _name;
  late final TextEditingController _variety;
  late final TextEditingController _min;
  late final TextEditingController _max;
  late final TextEditingController _abs;
  late final TextEditingController _fan;
  late final TextEditingController _hours;
  late final TextEditingController _notes;
  late final TextEditingController _targetMc;
  late final TextEditingController _source;
  String _flow = 'auto';
  bool _verified = false;
  String? _err;
  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.cropName ?? '');
    _variety = TextEditingController(text: e?.variety ?? '');
    _min = TextEditingController(text: '${e?.minTempC ?? 40}');
    _max = TextEditingController(text: '${e?.maxTempC ?? 50}');
    _abs = TextEditingController(text: '${e?.absMaxTempC ?? 60}');
    _fan = TextEditingController(text: '${e?.fanPwm ?? 70}');
    _hours = TextEditingController(text: '${e?.hoursEst ?? 12}');
    _notes = TextEditingController(text: e?.notes ?? '');
    _targetMc = TextEditingController(
      text: e?.targetMc == null ? '' : '${e?.targetMc}');
    _source = TextEditingController(
      text: e?.source ?? 'Provisional - validate locally');
    _flow = e?.airflowMode ?? 'auto';
    _verified = e?.verified ?? false;
  }
  @override
  void dispose() {
    _name.dispose(); _variety.dispose(); _min.dispose();
    _max.dispose(); _abs.dispose(); _fan.dispose();
    _hours.dispose(); _notes.dispose(); _targetMc.dispose();
    _source.dispose();
    super.dispose();
  }
  void _save() {
    final c = CropProfile(
      id: widget.existing?.id ??
        DateTime.now().microsecondsSinceEpoch.toString(),
      cropName: _name.text,
      variety: _variety.text.isEmpty ? null : _variety.text,
      minTempC: double.tryParse(_min.text) ?? -1,
      maxTempC: double.tryParse(_max.text) ?? -1,
      absMaxTempC: double.tryParse(_abs.text) ?? -1,
      airflowMode: _flow,
      fanPwm: int.tryParse(_fan.text) ?? -1,
      hoursEst: double.tryParse(_hours.text) ?? -1,
      notes: _notes.text,
      targetMc: double.tryParse(_targetMc.text),
      source: _source.text, verified: _verified,
      updatedAt: DateTime.now());
    final v = c.validate();
    if (v != null) { setState(() => _err = v); return; }
    ref.read(cropProfilesProvider.notifier).upsert(c);
    Navigator.pop(context);
  }
  @override
  Widget build(BuildContext context) {
    const modes = ['low', 'medium', 'high', 'auto'];
    return SafeArea(child: Padding(
      padding: EdgeInsets.only(bottom:
        MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(widget.existing == null ? 'New crop profile'
            : 'Edit ${widget.existing!.cropName}',
            style: const TextStyle(fontWeight: FontWeight.bold,
              fontSize: 16)),
          TextField(controller: _name,
            decoration: const InputDecoration(labelText: 'Crop name')),
          TextField(controller: _variety,
            decoration: const InputDecoration(
              labelText: 'Variety / subtype (optional)')),
          TextField(controller: _min, keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Recommended min temp (C)')),
          TextField(controller: _max, keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Recommended max temp (C)')),
          TextField(controller: _abs, keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Absolute max temp (C, 30-85)')),
          DropdownButton<String>(value: _flow,
            items: [for (final m in modes)
              DropdownMenuItem(value: m, child: Text(m))],
            onChanged: (v) => setState(() => _flow = v ?? _flow)),
          TextField(controller: _fan, keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Default fan PWM (0-100)')),
          TextField(controller: _hours, keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duration estimate (h, 1-96)')),
          TextField(controller: _targetMc,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Target moisture % (optional)')),
          TextField(controller: _source,
            decoration: const InputDecoration(
              labelText: 'Source / reference')),
          TextField(controller: _notes,
            decoration: const InputDecoration(
              labelText: 'Preparation notes')),
          SwitchListTile(value: _verified,
            title: const Text('Verified against a reference'),
            subtitle: const Text(
              'Off = provisional (confirm before auto)'),
            onChanged: (v) => setState(() => _verified = v)),
          if (_err != null)
            Text(_err!, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 8),
          ElevatedButton(onPressed: _save,
            child: const Text('Save crop profile')),
        ]),
      ),
    ));
  }
}
