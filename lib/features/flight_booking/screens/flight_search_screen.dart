import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';

class FlightSearchScreen extends ConsumerStatefulWidget {
  const FlightSearchScreen({super.key});
  @override ConsumerState<FlightSearchScreen> createState() => _FlightSearchScreenState();
}

class _FlightSearchScreenState extends ConsumerState<FlightSearchScreen> {
  String _from = '';
  String _to = '';
  String _tripType = 'one_way';
  final DateTime _date = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.black), onPressed: () => Navigator.pop(context)),
        title: Text(tr('flights'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(padding: EdgeInsets.all(16.w), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text(tr('tripType'), style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
          SizedBox(height: 4.h),
          Wrap(spacing: 8.w, children: [
            _Chip(label: tr('oneWay'), selected: _tripType == 'one_way', onTap: () => setState(() => _tripType = 'one_way')),
            _Chip(label: tr('roundTrip'), selected: _tripType == 'round', onTap: () => setState(() => _tripType = 'round')),
            _Chip(label: tr('multiCity'), selected: _tripType == 'multi', onTap: () => setState(() => _tripType = 'multi')),
          ]),
          SizedBox(height: 16.h),
          _buildField(tr('from'), (v) => setState(() => _from = v)),
          SizedBox(height: 12.h),
          _buildField(tr('to'), (v) => setState(() => _to = v)),
          SizedBox(height: 12.h),
          _buildDateField(tr('departure'), _date),
          SizedBox(height: 16.h),
          ElevatedButton(onPressed: _from.isNotEmpty && _to.isNotEmpty ? _search : null, child: Text(tr('searchFlights'), style: TextStyle(fontSize: 16.sp))),
          SizedBox(height: 24.h),
          Text(tr('topDestinations'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
          SizedBox(height: 8.h),
          Wrap(spacing: 12.w, runSpacing: 12.h, children: const [
            _DestCard('Goa', 'India', 'Rs 4,500'),
            _DestCard('Bali', 'Indonesia', 'Rs 18,000'),
            _DestCard('Dubai', 'UAE', 'Rs 22,000'),
          ]),
        ])),
      ),
    );
  }

  Widget _buildField(String hint, Function(String) onChanged) {
    return Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: TextField(decoration: InputDecoration(hintText: hint, hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp), border: InputBorder.none, prefixIcon: const Icon(Icons.flight_takeoff, color: Color(0xFF2E7D3E))), onChanged: onChanged));
  }

  Widget _buildDateField(String label, DateTime date) {
    return Container(decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12.r), border: Border.all(color: Colors.grey[300]!)), child: ListTile(contentPadding: EdgeInsets.symmetric(horizontal: 12.w), title: Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)), subtitle: Text('//', style: TextStyle(color: Colors.black87, fontSize: 14.sp)), trailing: const Icon(Icons.calendar_today, color: Color(0xFF2E7D3E)), onTap: () {}));
  }

  void _search() {}
}

class _Chip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.selected, required this.onTap});
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(label: Text(label, style: TextStyle(color: selected ? Colors.white : Colors.black87, fontSize: 12.sp)), selected: selected, onSelected: (_) => onTap(), backgroundColor: Colors.grey[200], selectedColor: const Color(0xFF2E7D3E), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)));
  }
}

class _DestCard extends StatelessWidget {
  final String city, country, price;
  const _DestCard(this.city, this.country, this.price);
  @override
  Widget build(BuildContext context) {
    return Container(width: 100.w, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12.r), boxShadow: [BoxShadow(color: Colors.grey.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, 2))]), child: Column(children: [Icon(Icons.flight, color: const Color(0xFF2E7D3E), size: 30.sp), SizedBox(height: 4.h), Text(city, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp)), Text(country, style: TextStyle(color: Colors.grey[600], fontSize: 10.sp)), Text(price, style: TextStyle(color: const Color(0xFF2E7D3E), fontWeight: FontWeight.bold, fontSize: 12.sp))]));
  }
}
