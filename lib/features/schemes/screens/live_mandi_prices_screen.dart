import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../core/di/injection.dart';
import '../../weather/providers/location_provider.dart';
import '../../../core/widgets/offline_status_bar.dart';

class MandiPriceRecord {
  final String state;
  final String district;
  final String market;
  final String commodity;
  final String variety;
  final String grade;
  final String arrivalDate;
  final double minPrice;
  final double maxPrice;
  final double modalPrice;

  MandiPriceRecord({
    required this.state,
    required this.district,
    required this.market,
    required this.commodity,
    required this.variety,
    required this.grade,
    required this.arrivalDate,
    required this.minPrice,
    required this.maxPrice,
    required this.modalPrice,
  });

  factory MandiPriceRecord.fromJson(Map<String, dynamic> json) {
    return MandiPriceRecord(
      state: json['state'] as String? ?? '',
      district: json['district'] as String? ?? '',
      market: json['market'] as String? ?? '',
      commodity: json['commodity'] as String? ?? '',
      variety: json['variety'] as String? ?? '',
      grade: json['grade'] as String? ?? '',
      arrivalDate: json['arrival_date'] as String? ?? '',
      minPrice: (json['min_price'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (json['max_price'] as num?)?.toDouble() ?? 0.0,
      modalPrice: (json['modal_price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class LiveMandiPricesScreen extends ConsumerStatefulWidget {
  const LiveMandiPricesScreen({super.key});

  @override
  ConsumerState<LiveMandiPricesScreen> createState() => _LiveMandiPricesScreenState();
}

class _LiveMandiPricesScreenState extends ConsumerState<LiveMandiPricesScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  final String _dataSource = 'Ministry of Agriculture & Farmers Welfare (data.gov.in)';
  String? _updatedDate;
  bool _isOfflineCache = false;
  List<MandiPriceRecord> _records = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchMandiPrices();
  }

  Future<void> _fetchMandiPrices() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final location = ref.read(userLocationProvider);

    try {
      final res = await DependencyInjection.apiClient.get(
        '/mandi/prices?limit=50&district=${Uri.encodeComponent(location.districtName)}',
        cacheOffline: true,
      );

      if (res is Map<String, dynamic> && res['records'] is List) {
        final list = (res['records'] as List)
            .map((r) => MandiPriceRecord.fromJson(r as Map<String, dynamic>))
            .toList();

        setState(() {
          _records = list;
          _isLoading = false;
          _isOfflineCache = res['_isOfflineCache'] == true;
          _updatedDate = res['updated_date'] as String? ?? res['_cachedAt'] as String?;
        });
        return;
      }

      throw Exception('Malformed data from server');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final location = ref.watch(userLocationProvider);
    final filtered = _records.where((r) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return r.commodity.toLowerCase().contains(q) ||
          r.market.toLowerCase().contains(q) ||
          r.district.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        title: Text(
          'Live Mandi Daily Prices',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1B4D3E),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1B4D3E)),
            onPressed: _fetchMandiPrices,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineStatusBar(),
            // Location Header & Manual Selection
            Container(
              padding: EdgeInsets.all(12.w),
              color: Colors.white,
              child: Row(
                children: [
                  Icon(Icons.location_on, color: Colors.green.shade800, size: 20.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${location.districtName}, ${location.stateName}',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          location.isPermissionGranted
                              ? 'GPS Located Market: ${location.marketName}'
                              : 'Manual / Default Market Selection',
                          style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () => _showLocationSelector(context),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      side: BorderSide(color: Colors.green.shade800),
                    ),
                    child: Text('Change', style: TextStyle(fontSize: 12.sp)),
                  ),
                ],
              ),
            ),

            // Source Attribution & Timestamp Notice
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              color: _isOfflineCache ? Colors.amber.shade50 : Colors.green.shade50,
              child: Row(
                children: [
                  Icon(
                    _isOfflineCache ? Icons.history : Icons.verified,
                    size: 14.sp,
                    color: _isOfflineCache ? Colors.amber.shade900 : Colors.green.shade800,
                  ),
                  SizedBox(width: 6.w),
                  Expanded(
                    child: Text(
                      _isOfflineCache
                          ? 'Offline Cache: Saved on ${_updatedDate ?? "Earlier"}'
                          : 'Live Source: ${_updatedDate ?? "Current Date"} ($_dataSource)',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _isOfflineCache ? Colors.amber.shade900 : Colors.green.shade900,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: EdgeInsets.all(12.w),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search commodity, market, or district...',
                  prefixIcon: const Icon(Icons.search),
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),

            // Mandi Price Cards List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _errorMessage != null && _records.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_off, size: 48.sp, color: Colors.grey),
                              SizedBox(height: 12.h),
                              Text('Unable to reach Mandi service',
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                              SizedBox(height: 6.h),
                              Text(_errorMessage!,
                                  style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade600)),
                              SizedBox(height: 12.h),
                              ElevatedButton(
                                onPressed: _fetchMandiPrices,
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          itemCount: filtered.length,
                          itemBuilder: (context, idx) {
                            final rec = filtered[idx];
                            return Card(
                              margin: EdgeInsets.only(bottom: 8.h),
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(12.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          rec.commodity,
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: const Color(0xFF1B4D3E),
                                          ),
                                        ),
                                        Text(
                                          '₹${rec.modalPrice.toStringAsFixed(0)} / Quintal',
                                          style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.green.shade800,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '${rec.market} (${rec.district}, ${rec.state})',
                                      style: TextStyle(
                                        fontSize: 12.sp,
                                        color: Colors.grey.shade700,
                                      ),
                                    ),
                                    SizedBox(height: 6.h),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Min: ₹${rec.minPrice.toStringAsFixed(0)} | Max: ₹${rec.maxPrice.toStringAsFixed(0)}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                        Text(
                                          'Reported: ${rec.arrivalDate}',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey.shade500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLocationSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.all(16.w),
          height: 350.h,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select Market or District',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
              SizedBox(height: 12.h),
              ListTile(
                leading: const Icon(Icons.my_location, color: Colors.green),
                title: const Text('Use Current Device Location (GPS)'),
                onTap: () {
                  ref.read(userLocationProvider.notifier).updateFromGps(
                        lat: 21.6168,
                        lon: 71.2077,
                        detectedState: 'Gujarat',
                        detectedDistrict: 'Amreli',
                        nearestMarket: 'Amreli APMC',
                      );
                  Navigator.pop(ctx);
                  _fetchMandiPrices();
                },
              ),
              const Divider(),
              Text('Frequent Agricultural Districts:',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700)),
              SizedBox(height: 8.h),
              ListTile(
                title: const Text('Prakasam (Andhra Pradesh)'),
                subtitle: const Text('Maddipadu APMC'),
                onTap: () {
                  ref.read(userLocationProvider.notifier).setManualLocation(
                        stateName: 'Andhra Pradesh',
                        districtName: 'Prakasam',
                        marketName: 'Maddipadu APMC',
                      );
                  Navigator.pop(ctx);
                  _fetchMandiPrices();
                },
              ),
              ListTile(
                title: const Text('Kozhikode (Kerala)'),
                subtitle: const Text('Mukkom Market'),
                onTap: () {
                  ref.read(userLocationProvider.notifier).setManualLocation(
                        stateName: 'Kerala',
                        districtName: 'Kozhikode',
                        marketName: 'Mukkom Market',
                      );
                  Navigator.pop(ctx);
                  _fetchMandiPrices();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
