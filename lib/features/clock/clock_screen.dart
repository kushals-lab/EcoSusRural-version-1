import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'reminder_store.dart';

class ClockScreen extends StatefulWidget {
  const ClockScreen({super.key});
  @override State<ClockScreen> createState() => _ClockScreenState();
}
class _ClockScreenState extends State<ClockScreen> {
  final _store = ReminderStore();
  final _stopwatch = Stopwatch();
  final _minutes = TextEditingController(text: '5');
  List<Reminder> _reminders = [];
  List<String> _zones = ['Asia/Kolkata', 'Europe/London', 'America/New_York'];
  Timer? _tick;
  DateTime? _timerEnd;
  int? _timerId;
  String _status = 'Reminders use notifications; they are not full-screen alarm clocks. Delivery can be delayed by Android battery restrictions.';
  @override void initState() {
    super.initState(); initializeTimeZones(); _load();
    _tick = Timer.periodic(const Duration(seconds: 1), (_) { if (mounted) setState(() {}); });
  }
  Future<void> _load() async {
    try {
      final records = await _store.load();
      final prefs = await SharedPreferences.getInstance();
      if (mounted) {
        setState(() {
        _reminders = records; _zones = prefs.getStringList('ecosus.world_clocks') ?? _zones;
        _timerId = prefs.getInt('ecosus.timer_id');
        final end = prefs.getInt('ecosus.timer_end');
        _timerEnd = end == null ? null : DateTime.fromMillisecondsSinceEpoch(end);
      });
      }
    } catch (_) { if (mounted) setState(() => _status = 'Unable to load reminders. Please retry.'); }
  }
  @override void dispose() { _tick?.cancel(); _minutes.dispose(); super.dispose(); }
  Future<void> _save(List<Reminder> next) async {
    try {
      final status = await _store.save(next);
      if (mounted) setState(() { _reminders = next; _status = status; });
    } catch (_) { if (mounted) setState(() => _status = 'Scheduling failed. Your existing reminders were not removed.'); }
  }
  Future<void> _edit([Reminder? existing]) async {
    final result = await Navigator.push<Reminder>(context, MaterialPageRoute(builder: (_) => ReminderEditor(existing: existing)));
    if (result == null) return;
    await _store.permissions();
    await _save([..._reminders.where((r) => r.id != result.id), result]);
  }
  Future<void> _addZone() async {
    final controller = TextEditingController();
    final chosen = await showDialog<String>(context: context, builder: (c) => AlertDialog(
      title: const Text('Add world clock'), content: Autocomplete<String>(
        optionsBuilder: (v) => tz.timeZoneDatabase.locations.keys.where((z) => z.toLowerCase().contains(v.text.toLowerCase())).take(30),
        onSelected: (s) => controller.text = s,
        fieldViewBuilder: (c, text, focus, submit) => TextField(controller: text, focusNode: focus, onChanged: (s) => controller.text = s,
          decoration: const InputDecoration(labelText: 'IANA zone, e.g. Asia/Kolkata'))),
      actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')),
        TextButton(onPressed: () { if (tz.timeZoneDatabase.locations.containsKey(controller.text)) Navigator.pop(c, controller.text); }, child: const Text('Add'))]));
    controller.dispose();
    if (chosen != null) { setState(() => _zones = {..._zones, chosen}.toList()); await _saveZones(); }
  }
  Future<void> _saveZones() async { final p = await SharedPreferences.getInstance(); await p.setStringList('ecosus.world_clocks', _zones); }
  Future<void> _startTimer() async {
    final minutes = int.tryParse(_minutes.text);
    if (minutes == null || minutes <= 0 || minutes > 5256000) { setState(() => _status = 'Enter 1–5256000 minutes.'); return; }
    final end = DateTime.now().add(Duration(minutes: minutes));
    final id = DateTime.now().millisecondsSinceEpoch % 2000000000;
    await _store.permissions();
    await _save([..._reminders.where((r) => r.id != _timerId), Reminder(id: id, title: 'Countdown finished', at: end, zone: 'UTC')]);
    if (!_reminders.any((r) => r.id == id)) return;
    final prefs = await SharedPreferences.getInstance(); await prefs.setInt('ecosus.timer_end', end.millisecondsSinceEpoch); await prefs.setInt('ecosus.timer_id', id);
    setState(() { _timerEnd = end; _timerId = id; });
  }
  @override Widget build(BuildContext context) => DefaultTabController(length: 4, child: Scaffold(
    appBar: AppBar(title: const Text('Reminders & clocks'), bottom: const TabBar(isScrollable: true, tabs: [Tab(text: 'Reminders'), Tab(text: 'Stopwatch'), Tab(text: 'Timer'), Tab(text: 'World clock')])),
    body: SafeArea(child: TabBarView(children: [
      ListView(padding: const EdgeInsets.all(16), children: [
        Text(_status), Wrap(spacing: 8, children: [FilledButton.icon(onPressed: () => _edit(), icon: const Icon(Icons.add_alarm), label: const Text('Add reminder')),
          TextButton(onPressed: () async { final message = await _store.permissions(exact: true); if (mounted) setState(() => _status = message); }, child: const Text('Exact alarm access'))]),
        ..._reminders.map((r) => Card(child: Column(children: [SwitchListTile(value: r.enabled,
          onChanged: (v) => _save(_reminders.map((e) => e.id == r.id ? e.withEnabled(v) : e).toList()),
          title: Text(r.title), subtitle: Text('${tz.TZDateTime.from(r.at, tz.getLocation(r.zone))}\n${r.zone} • ${r.repeat}\n${r.description}')),
          Wrap(children: [TextButton(onPressed: () => _edit(r), child: const Text('Edit')),
            TextButton(onPressed: () => _save(_reminders.where((e) => e.id != r.id).toList()), child: const Text('Delete'))])]))) ]),
      ListView(padding: const EdgeInsets.all(24), children: [Text(_stopwatch.elapsed.toString().split('.').first, style: const TextStyle(fontSize: 36)),
        const Text('Stopwatch uses elapsed time while this app process is running.'),
        Wrap(spacing: 12, children: [FilledButton(onPressed: () => setState(() { _stopwatch.isRunning ? _stopwatch.stop() : _stopwatch.start(); }), child: Text(_stopwatch.isRunning ? 'Pause' : 'Start')),
          OutlinedButton(onPressed: () => setState(_stopwatch.reset), child: const Text('Reset'))])]),
      ListView(padding: const EdgeInsets.all(24), children: [TextField(controller: _minutes, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Minutes')),
        FilledButton(onPressed: _startTimer, child: const Text('Start countdown')),
        if (_timerEnd != null) Text(_timerEnd!.isAfter(DateTime.now()) ? _timerEnd!.difference(DateTime.now()).toString().split('.').first : 'Countdown finished', style: const TextStyle(fontSize: 30)),
        if (_timerId != null) TextButton(onPressed: () async {
          await _save(_reminders.where((r) => r.id != _timerId).toList());
          final p = await SharedPreferences.getInstance(); await p.remove('ecosus.timer_end'); await p.remove('ecosus.timer_id');
          if (mounted) setState(() { _timerEnd = null; _timerId = null; });
        }, child: const Text('Cancel countdown')),
        Text(_status)]),
      ListView(padding: const EdgeInsets.all(16), children: [FilledButton(onPressed: _addZone, child: const Text('Add time zone')),
        ..._zones.where(tz.timeZoneDatabase.locations.containsKey).map((z) => ListTile(title: Text(z), subtitle: Text(tz.TZDateTime.now(tz.getLocation(z)).toString()),
          trailing: IconButton(icon: const Icon(Icons.delete_outline), onPressed: () { setState(() => _zones.remove(z)); _saveZones(); })))])
    ]))));
}

class ReminderEditor extends StatefulWidget {
  final Reminder? existing;
  const ReminderEditor({super.key, this.existing});
  @override State<ReminderEditor> createState() => _ReminderEditorState();
}
class _ReminderEditorState extends State<ReminderEditor> {
  late final TextEditingController _title, _description, _zone;
  late DateTime _day;
  late TimeOfDay _time;
  String _repeat = 'none', _sound = 'alarm';
  bool _vibrate = true;
  int _snooze = 10;
  String? _error;
  @override void initState() {
    super.initState(); initializeTimeZones(); final r = widget.existing;
    _title = TextEditingController(text: r?.title); _description = TextEditingController(text: r?.description);
    _zone = TextEditingController(text: r?.zone ?? 'Asia/Kolkata');
    final at = tz.TZDateTime.from(r?.at ?? DateTime.now().add(const Duration(hours: 1)), tz.getLocation(_zone.text));
    _day = DateTime(at.year, at.month, at.day); _time = TimeOfDay(hour: at.hour, minute: at.minute);
    _repeat = r?.repeat ?? 'none'; _sound = r?.sound ?? 'alarm'; _vibrate = r?.vibration ?? true; _snooze = r?.snoozeMinutes ?? 10;
  }
  @override void dispose() { _title.dispose(); _description.dispose(); _zone.dispose(); super.dispose(); }
  void _submit() {
    try {
      if (_title.text.trim().isEmpty) throw const FormatException('Enter a title.');
      final at = reminderInstant(_zone.text.trim(), _day, _time.hour, _time.minute);
      if (!at.isAfter(DateTime.now())) throw const FormatException('Choose a future time.');
      Navigator.pop(context, Reminder(id: widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch % 2000000000,
        title: _title.text.trim(), description: _description.text.trim(), at: at, zone: _zone.text.trim(),
        repeat: _repeat, sound: _sound, vibration: _vibrate, snoozeMinutes: _snooze));
    } catch (e) { setState(() => _error = e.toString()); }
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Schedule reminder')),
    body: SafeArea(child: ListView(padding: const EdgeInsets.all(16), children: [
      TextField(controller: _title, maxLength: 120, decoration: const InputDecoration(labelText: 'Title')),
      TextField(controller: _description, maxLines: 3, maxLength: 1000, decoration: const InputDecoration(labelText: 'Description')),
      TextField(controller: _zone, decoration: const InputDecoration(labelText: 'IANA time zone', helperText: 'Fixed selected zone; e.g. Asia/Kolkata or Europe/London')),
      ListTile(title: Text('${_day.year}-${_day.month}-${_day.day}'), trailing: const Icon(Icons.calendar_month), onTap: () async {
        final day = await showDatePicker(context: context, initialDate: _day.isBefore(DateTime.now()) ? DateTime.now() : _day,
          firstDate: DateTime.now(), lastDate: DateTime(9999, 12, 31)); if (day != null) setState(() => _day = day);
      }),
      ListTile(title: Text(_time.format(context)), trailing: const Icon(Icons.schedule), onTap: () async {
        final time = await showTimePicker(context: context, initialTime: _time); if (time != null) setState(() => _time = time);
      }),
      DropdownButtonFormField<String>(initialValue: _repeat, decoration: const InputDecoration(labelText: 'Repeat'), items: ['none', 'daily', 'weekly'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => _repeat = v!),
      DropdownButtonFormField<String>(initialValue: _sound, decoration: const InputDecoration(labelText: 'Sound'), items: ['alarm', 'notification', 'silent'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) => _sound = v!),
      DropdownButtonFormField<int>(initialValue: _snooze, decoration: const InputDecoration(labelText: 'Snooze minutes'), items: [5, 10, 15, 30].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(), onChanged: (v) => _snooze = v!),
      SwitchListTile(title: const Text('Vibration'), value: _vibrate, onChanged: (v) => setState(() => _vibrate = v)),
      const Text('Times follow this IANA zone, including daylight saving. During a repeated autumn hour, the first occurrence is used. Distant reminders remain stored and enter Android scheduling within 30 days.'),
      if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
      FilledButton(onPressed: _submit, child: const Text('Save and schedule')),
    ])));
}
