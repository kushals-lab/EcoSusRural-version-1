import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/localization/language_provider.dart';
import 'rider_partner_screen.dart';

class RideBookingScreen extends ConsumerStatefulWidget {
  const RideBookingScreen({super.key});
  @override
  ConsumerState<RideBookingScreen> createState() => _RideBookingScreenState();
}

class _RideBookingScreenState extends ConsumerState<RideBookingScreen> {
  String _pickup = '';
  String _drop = '';
  String _selectedOption = 'bike';
  String _ridePhase = 'idle'; // idle -> searching -> matched
  String _driverName = '';
  String _driverVehicle = '';
  String _driverRating = '4.9';
  String _otp = '';
  int _etaMin = 3;

  static const List<List<String>> _driverPool = [
    ['Ramesh K.', 'Bike - KA 05 MJ 4521'],
    ['Sunita D.', 'Auto - MH 12 QR 8830'],
    ['Arjun P.', 'Cab - DL 3C AB 1102'],
    ['Meena S.', 'Bike - UP 32 CD 7745'],
  ];

  @override
  Widget build(BuildContext context) {
    final tr = ref.tr;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(tr('ride'), style: const TextStyle(color: Color(0xFF2E7D3E), fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium, color: Color(0xFF5E35B1)),
            tooltip: 'Rider Partner Hub',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RiderPartnerScreen()),
            ),
          ),
        ],
      ),
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Text(tr('from'), style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
            SizedBox(height: 4.h),
            _buildLocationField(tr('enterPickup'), (val) => setState(() => _pickup = val)),
            SizedBox(height: 12.h),
            Text(tr('to'), style: TextStyle(color: Colors.grey[600], fontSize: 12.sp)),
            SizedBox(height: 4.h),
            _buildLocationField(tr('enterDrop'), (val) => setState(() => _drop = val)),
          ]),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Text(tr('rideOptions'), style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
        ),
        SizedBox(height: 8.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Wrap(spacing: 12.w, runSpacing: 12.h, children: [
            _RideOption(icon: Icons.motorcycle, label: tr('bike'), price: 'Rs 45', duration: '5 min',
                selected: _selectedOption == 'bike', onTap: () => setState(() => _selectedOption = 'bike')),
            _RideOption(icon: Icons.directions_car, label: tr('auto'), price: 'Rs 80', duration: '8 min',
                selected: _selectedOption == 'auto', onTap: () => setState(() => _selectedOption = 'auto')),
            _RideOption(icon: Icons.directions_car_filled, label: tr('cab'), price: 'Rs 120', duration: '10 min',
                selected: _selectedOption == 'cab', onTap: () => setState(() => _selectedOption = 'cab')),
          ]),
        ),
        const Spacer(),
        if (_ridePhase == 'searching')
          _buildSearchingCard()
        else if (_ridePhase == 'matched')
          _buildMatchedCard()
        else
          Padding(
            padding: EdgeInsets.all(16.w),
            child: ElevatedButton(
              onPressed: _pickup.isNotEmpty && _drop.isNotEmpty ? _bookRide : null,
              style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 24.w)),
              child: Text(tr('bookRide'), style: TextStyle(fontSize: 16.sp)),
            ),
          ),
      ]),
    );
  }

  Widget _buildLocationField(String hint, Function(String) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
          border: InputBorder.none,
          prefixIcon: const Icon(Icons.location_on, color: Color(0xFF2E7D3E)),
        ),
        onChanged: onChanged,
      ),
    );
  }

  void _bookRide() {
    if (_pickup.trim().isEmpty || _drop.trim().isEmpty) {
      return;
    }
    setState(() => _ridePhase = 'searching');
    // Simulated partner matching — production hits the /api/rides gateway.
    final seed = DateTime.now().millisecondsSinceEpoch;
    final driver = _driverPool[seed % _driverPool.length];
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted || _ridePhase != 'searching') {
        return;
      }
      setState(() {
        _ridePhase = 'matched';
        _driverName = driver[0];
        _driverVehicle = driver[1];
        _driverRating = '${4 + (seed % 10) / 10}';
        _otp = '${(seed ~/ 7) % 9000 + 1000}';
        _etaMin = 2 + seed % 6;
      });
    });
  }

  void _cancelRide() {
    setState(() {
      _ridePhase = 'idle';
      _driverName = '';
      _driverVehicle = '';
      _otp = '';
    });
  }

  Widget _buildSearchingCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEDF4EA),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF2E7D3E)),
      ),
      child: Row(children: [
        SizedBox(
          width: 22.w,
          height: 22.w,
          child: const CircularProgressIndicator(strokeWidth: 2.5),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            'Matching you with a nearby partner…',
            style: TextStyle(fontSize: 12.5.sp, color: const Color(0xFF2E7D3E)),
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close, color: Colors.grey),
          onPressed: _cancelRide,
        ),
      ]),
    );
  }

  Widget _buildMatchedCard() {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4D3E),
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Partner on the way · $_etaMin min',
            style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 10.h),
          Row(children: [
            CircleAvatar(
              radius: 20.r,
              backgroundColor: const Color(0xFFDCF2C0),
              child: Text(
                _driverName.isNotEmpty ? _driverName.substring(0, 1) : '?',
                style: TextStyle(color: const Color(0xFF1B4D3E), fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$_driverName  ·  $_driverRating',
                    style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    _driverVehicle,
                    style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 11.sp),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: const BoxDecoration(
                color: Color(0xFFFFD166),
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              child: Text(
                'OTP $_otp',
                style: TextStyle(color: const Color(0xFF1B4D3E), fontSize: 12.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ]),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$_pickup  to  $_drop',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10.5.sp),
              ),
              Row(children: [
                const Icon(Icons.lock_rounded, color: Color(0xFFDCF2C0), size: 13),
                SizedBox(width: 4.w),
                Text(
                  'Paying via EcoBharatPay',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 10.5.sp),
                ),
              ]),
            ],
          ),
          SizedBox(height: 10.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _cancelRide,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFB3261E)),
              child: Text(
                'Cancel ride',
                style: TextStyle(color: Colors.white, fontSize: 13.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RideOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String price;
  final String duration;
  final bool selected;
  final VoidCallback onTap;
  const _RideOption({
    required this.icon, required this.label, required this.price, required this.duration,
    required this.selected, required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      onSelected: (_) => onTap(),
      backgroundColor: Colors.grey[100],
      selectedColor: const Color(0xFF2E7D3E).withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: selected ? const Color(0xFF2E7D3E) : Colors.grey[300]!),
      ),
      avatar: Icon(icon, color: selected ? const Color(0xFF2E7D3E) : Colors.grey[600], size: 20.sp),
      label: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: selected ? const Color(0xFF2E7D3E) : Colors.black87, fontWeight: FontWeight.bold, fontSize: 12.sp)),
        Text(price, style: TextStyle(color: selected ? const Color(0xFF2E7D3E) : Colors.grey[600], fontSize: 11.sp)),
        Text(duration, style: TextStyle(color: Colors.grey[600], fontSize: 10.sp)),
      ]),
    );
  }
}
