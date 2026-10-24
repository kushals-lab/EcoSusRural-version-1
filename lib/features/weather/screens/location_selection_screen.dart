import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/di/injection.dart';
import '../../../core/network/api_client.dart';
import '../../../core/widgets/pincode_verify_field.dart';
import '../providers/location_preferences.dart';
import '../providers/location_provider.dart';

class LocationSelectionScreen extends ConsumerStatefulWidget {
  final bool firstRegistration;
  const LocationSelectionScreen({super.key, this.firstRegistration = false});
  @override ConsumerState<LocationSelectionScreen> createState() => _LocationSelectionScreenState();
}
class _LocationSelectionScreenState extends ConsumerState<LocationSelectionScreen> {
  LocationPurpose _purpose = LocationPurpose.weather;
  final _fields = List.generate(5, (_) => TextEditingController());
  final _search = TextEditingController();
  Timer? _debounce;
  RequestCancellation? _request;
  List<SavedPlace> _results = [];
  SavedPlace? _selected;
  String? _message;
  bool _busy = false, _manual = false;
  @override void initState() { super.initState(); ref.read(locationPreferencesProvider.notifier).load(); }
  @override void dispose() {
    _debounce?.cancel(); _request?.cancel(); _search.dispose();
    for (final c in _fields) { c.dispose(); } super.dispose();
  }
  void _select(SavedPlace p) {
    _selected = p;
    final values = [p.country, p.state, p.district, p.city, p.postalCode];
    for (var i = 0; i < values.length; i++) { _fields[i].text = values[i]; }
    setState(() { _results = []; _manual = true; });
  }
  void _searchChanged(String text) {
    _debounce?.cancel(); _request?.cancel();
    if (text.trim().length < 2) { setState(() => _results = []); return; }
    _debounce = Timer(const Duration(milliseconds: 500), () async {
      final request = RequestCancellation(); _request = request;
      try {
        final result = await DependencyInjection.apiClient.get('/locations/search?q=${Uri.encodeQueryComponent(text.trim())}', cancellation: request);
        if (mounted && !request.isCancelled) {
          setState(() => _results =
          (result['results'] as List).map((v) => SavedPlace.fromSearch(Map<String, dynamic>.from(v))).toList());
        }
      } catch (_) { if (mounted && !request.isCancelled) setState(() => _message = 'Search unavailable. You can save an address manually and add map coordinates later.'); }
    });
  }
  Future<void> _gps() async {
    final consent = await showDialog<bool>(context: context, builder: (c) => AlertDialog(
      title: const Text('Use your current location?'),
      content: const Text('Location helps select local weather. Only foreground access is needed. Approximate access works. Your device position is kept only for this session; saving a preference retains rounded coordinates.'),
      actions: [TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        TextButton(onPressed: () => Navigator.pop(c, true), child: const Text('Continue'))]));
    if (consent != true) return;
    setState(() { _busy = true; _message = null; });
    try {
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        throw StateError('Location denied. Search or enter your location manually.');
      }
      final position = await Geolocator.getCurrentPosition(locationSettings:
        const LocationSettings(accuracy: LocationAccuracy.low, timeLimit: Duration(seconds: 20)));
      if (!mounted) return;
      final place = SavedPlace(city: 'Selected device location',
        latitude: double.parse(position.latitude.toStringAsFixed(2)), longitude: double.parse(position.longitude.toStringAsFixed(2)));
      ref.read(locationPreferencesProvider.notifier).deviceLocation = place;
      _select(place);
    } catch (_) { if (mounted) setState(() { _manual = true; _message = 'Location unavailable or permission denied. Please select a location manually.'; }); }
    finally { if (mounted) setState(() => _busy = false); }
  }
  Future<void> _save() async {
    if (_fields[3].text.trim().isEmpty) { setState(() => _message = 'Enter a city or village.'); return; }
    final place = SavedPlace(country: _fields[0].text.trim(), state: _fields[1].text.trim(),
      district: _fields[2].text.trim(), city: _fields[3].text.trim(), postalCode: _fields[4].text.trim(),
      timezone: _selected?.timezone ?? '', latitude: _selected?.latitude, longitude: _selected?.longitude);
    await ref.read(locationPreferencesProvider.notifier).save(_purpose, place);
    if (_purpose == LocationPurpose.market) {
      await ref.read(userLocationProvider.notifier).setManualLocation(
      stateName: place.state, districtName: place.district, marketName: place.city, latitude: place.latitude, longitude: place.longitude);
    }
    if (!mounted) return;
    setState(() => _message = 'Saved on this device. ${place.hasCoordinates ? '' : 'Select a search result to enable weather at this address.'}');
    if (widget.firstRegistration) Navigator.pop(context);
  }
  @override Widget build(BuildContext context) {
    final saved = ref.watch(locationPreferencesProvider)[_purpose];
    return Scaffold(appBar: AppBar(title: const Text('Choose your location')), body: SafeArea(child: ListView(
      padding: const EdgeInsets.all(16), children: [
        const Text('Your home, farm and business can be in different places.'),
        DropdownButtonFormField<LocationPurpose>(initialValue: _purpose, isExpanded: true,
          items: LocationPurpose.values.map((p) => DropdownMenuItem(value: p, child: Text('Preferred ${p.name} location'))).toList(),
          onChanged: (p) { if (p != null) setState(() { _purpose = p; _selected = null; for (final f in _fields) { f.clear(); } }); }),
        if (saved != null) Text('Saved: ${saved.label}'),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _busy ? null : _gps, icon: const Icon(Icons.my_location), label: const Text('Use my current location')),
        OutlinedButton.icon(onPressed: () => setState(() => _manual = true), icon: const Icon(Icons.search), label: const Text('Search and select a location manually')),
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Choose later')),
        if (_busy) const LinearProgressIndicator(),
        if (_message != null) Padding(padding: const EdgeInsets.all(8), child: Text(_message!)),
        if (_manual) ...[
          TextField(controller: _search, onChanged: _searchChanged, decoration: const InputDecoration(labelText: 'Search city, village or postal code')),
          ..._results.map((p) => ListTile(title: Text(p.label), subtitle: Text(p.postalCode), onTap: () => _select(p))),
          const SizedBox(height: 12),
          PincodeVerifyField(
            controller: _fields[4],
            countryController: _fields[0],
            stateController: _fields[1],
            districtController: _fields[2],
            cityController: _fields[3],
            labelText: 'Postal Code / PIN Code',
          ),
          for (var i = 0; i < 4; i++) Padding(padding: const EdgeInsets.only(top: 12), child: TextField(
            controller: _fields[i], onChanged: (_) => _selected = null,
            decoration: InputDecoration(labelText: ['Country', 'State or province', 'District', 'City or village'][i]))),
          const SizedBox(height: 16), FilledButton(onPressed: _save, child: const Text('Save preferred location')),
        ],
      ])));
  }
}
