import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// BookMyShow / ConfirmTKT-style movies, events & live shows booking.
class EntertainmentScreen extends ConsumerStatefulWidget {
  const EntertainmentScreen({super.key});

  @override
  ConsumerState<EntertainmentScreen> createState() => _EntertainmentScreenState();
}

class _EntertainmentScreenState extends ConsumerState<EntertainmentScreen> {
  int _movieIndex = 0;
  int _showIndex = 0;
  final Set<int> _selectedSeats = <int>{};
  bool _booked = false;
  String _bookingCode = '';

  @override
  Widget build(BuildContext context) {
    final movie = _kEntertainmentMovies[_movieIndex];
    final show = movie.shows[_showIndex % movie.shows.length];
    return Scaffold(
      backgroundColor: const Color(0xFF0F1422),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F1422),
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Movies & Events',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: () {}),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMovieStrip(),
                SizedBox(height: 14.h),
                _buildShowPicker(movie),
                SizedBox(height: 14.h),
                _buildSeatMap(show),
                SizedBox(height: 14.h),
                _buildBookingCard(show),
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _buildMovieStrip() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Now Showing',
          style: TextStyle(color: Colors.white, fontSize: 17.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        Row(children: [
          for (var i = 0; i < _kEntertainmentMovies.length; i++)
            Expanded(child: _moviePoster(i)),
        ]),
      ],
    );
  }

  Widget _moviePoster(int i) {
    final movie = _kEntertainmentMovies[i];
    return InkWell(
      onTap: () => setState(() {
        _movieIndex = i;
        _selectedSeats.clear();
        _booked = false;
      }),
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 148.h,
        decoration: BoxDecoration(
          color: movie.posterColor,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: i == _movieIndex ? const Color(0xFFFFC107) : const Color(0x00000000),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(8.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  movie.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 10.5.sp, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 4.h),
              Flexible(
                child: Text(
                  '${movie.language} - ${movie.genre}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 9.sp),
                ),
              ),
              SizedBox(height: 4.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                decoration: const BoxDecoration(
                  color: Color(0xFF21A34A),
                  borderRadius: BorderRadius.all(Radius.circular(4)),
                ),
                child: Text(
                  'Star ${movie.rating}',
                  style: TextStyle(color: Colors.white, fontSize: 9.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShowPicker(_EntertainmentMovie movie) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose a show - ${movie.title}',
          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (var i = 0; i < movie.shows.length; i++)
              ChoiceChip(
                selected: _showIndex == i,
                onSelected: (_) => setState(() => _showIndex = i),
                label: Text(movie.shows[i].time, style: TextStyle(fontSize: 11.sp)),
                avatar: Icon(movie.shows[i].isToday ? Icons.today : Icons.calendar_month, size: 14.sp),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          '${movie.shows[_showIndex].venue} - ${movie.shows[_showIndex].screenLabel}',
          style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
        ),
      ],
    );
  }
  Widget _buildSeatMap(_EntertainmentShow show) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select seats - Rs ${show.price} each',
          style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 7.w,
          runSpacing: 7.h,
          children: [
            for (var seatId = 0; seatId < show.totalSeats; seatId++) _seat(seatId, show),
          ],
        ),
        SizedBox(height: 8.h),
        Wrap(
          spacing: 6.w,
          runSpacing: 4.h,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _legend(const Color(0xFF21A34A), 'Available'),
            _legend(const Color(0xFF4A4A4A), 'Occupied'),
            _legend(const Color(0xFFFFC107), 'Your pick'),
          ],
        ),
      ],
    );
  }

  Widget _seat(int seatId, _EntertainmentShow show) {
    final isOccupied = show.occupiedSeats.contains(seatId);
    final isSelected = _selectedSeats.contains(seatId);
    final Color seatColor;
    if (isOccupied) {
      seatColor = const Color(0xFF4A4A4A);
    } else if (isSelected) {
      seatColor = const Color(0xFFFFC107);
    } else {
      seatColor = const Color(0xFF21A34A);
    }
    return InkWell(
      onTap: isOccupied ? null : () {
        setState(() {
          if (isSelected) {
            _selectedSeats.remove(seatId);
          } else {
            _selectedSeats.add(seatId);
          }
        });
      },
      borderRadius: BorderRadius.circular(6.r),
      child: Container(
        width: 26.w,
        height: 26.w,
        decoration: BoxDecoration(
          color: seatColor.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Center(
          child: Text('${seatId + 1}', style: TextStyle(color: Colors.white, fontSize: 9.sp)),
        ),
      ),
    );
  }

  Widget _legend(Color color, String label) {
    return Row(children: [
      Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      SizedBox(width: 4.w),
      Text(label, style: TextStyle(color: Colors.white, fontSize: 10.sp)),
    ]);
  }

  Widget _buildBookingCard(_EntertainmentShow show) {
    final movie = _kEntertainmentMovies[_movieIndex];
    final seats = _selectedSeats.toList()..sort();
    final total = seats.length * show.price;
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2134),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: _booked ? const Color(0xFFFFC107) : const Color(0xFF2A3350)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_booked) ...[
            Row(children: [
              const Icon(Icons.check_circle, color: Color(0xFF21A34A), size: 22),
              SizedBox(width: 6.w),
              Expanded(
                child: Text(
                  'Booked! Code $_bookingCode - sent to SMS & in-app tickets',
                  style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            SizedBox(height: 10.h),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${movie.title} - ${seats.length} seat(s)',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white, fontSize: 12.5.sp),
                ),
              ),
              SizedBox(width: 8.w),
              Text(
                'Rs $total',
                style: TextStyle(color: Colors.white, fontSize: 12.5.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  '${show.time} - ${show.screenLabel}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  'Pay with EcoBharatPay',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                  style: TextStyle(color: Colors.grey[400], fontSize: 11.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ElevatedButton(
            onPressed: seats.isEmpty
                ? null
                : () {
                    setState(() {
                      _booked = true;
                      _bookingCode = 'ESR${DateTime.now().millisecondsSinceEpoch % 1000000}';
                    });
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF21A34A),
              padding: EdgeInsets.symmetric(vertical: 12.h),
            ),
            child: Text(
              seats.isEmpty
                  ? 'Select at least 1 seat'
                  : 'Book tickets - Rs $total via EcoBharatPay',
              style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
class _EntertainmentMovie {
  final String title;
  final String language;
  final String genre;
  final String rating;
  final Color posterColor;
  final List<_EntertainmentShow> shows;

  const _EntertainmentMovie({
    required this.title,
    required this.language,
    required this.genre,
    required this.rating,
    required this.posterColor,
    required this.shows,
  });
}

class _EntertainmentShow {
  final String time;
  final String venue;
  final String screenLabel;
  final int price;
  final int totalSeats;
  final bool isToday;
  final Set<int> occupiedSeats;

  const _EntertainmentShow({
    required this.time,
    required this.venue,
    required this.screenLabel,
    required this.price,
    required this.totalSeats,
    required this.isToday,
    required this.occupiedSeats,
  });
}

const List<_EntertainmentMovie> _kEntertainmentMovies = [
  _EntertainmentMovie(
    title: 'Vidya Vriksha',
    language: 'Hindi',
    genre: 'Ed-Drama',
    rating: '8.9',
    posterColor: Color(0xFFB3541E),
    shows: [
      _EntertainmentShow(
        time: '10:30 AM',
        venue: 'Gram Cineplex, Raipur',
        screenLabel: 'Screen 1 - 4K Laser',
        price: 180,
        totalSeats: 24,
        isToday: true,
        occupiedSeats: <int>{3, 7, 9, 18},
      ),
      _EntertainmentShow(
        time: '1:15 PM',
        venue: 'Gram Cineplex, Raipur',
        screenLabel: 'Screen 2 - Dolby',
        price: 220,
        totalSeats: 24,
        isToday: true,
        occupiedSeats: <int>{0, 1, 2, 23},
      ),
      _EntertainmentShow(
        time: '6:45 PM',
        venue: 'Gram Cineplex, Raipur',
        screenLabel: 'Screen 1 - 4K Laser',
        price: 240,
        totalSeats: 24,
        isToday: false,
        occupiedSeats: <int>{},
      ),
    ],
  ),
  _EntertainmentMovie(
    title: 'Kisan Diwas Live',
    language: 'Regional Live',
    genre: 'Event',
    rating: '9.2',
    posterColor: Color(0xFF2E7D32),
    shows: [
      _EntertainmentShow(
        time: '11:00 AM',
        venue: 'Agro Arena, Bhopal',
        screenLabel: 'Live Stage - Open Air',
        price: 300,
        totalSeats: 22,
        isToday: true,
        occupiedSeats: <int>{5, 6, 7, 8, 9, 10},
      ),
      _EntertainmentShow(
        time: '5:30 PM',
        venue: 'Agro Arena, Bhopal',
        screenLabel: 'Live Stage - Open Air',
        price: 350,
        totalSeats: 22,
        isToday: false,
        occupiedSeats: <int>{},
      ),
    ],
  ),
  _EntertainmentMovie(
    title: 'Artisan Fest 2026',
    language: 'Pan-India',
    genre: 'Expo',
    rating: '8.5',
    posterColor: Color(0xFF4A148C),
    shows: [
      _EntertainmentShow(
        time: '12:00 PM',
        venue: 'Shilp Haat, Varanasi',
        screenLabel: 'Main Pavilion',
        price: 150,
        totalSeats: 24,
        isToday: true,
        occupiedSeats: <int>{4, 11, 12},
      ),
      _EntertainmentShow(
        time: '7:00 PM',
        venue: 'Shilp Haat, Varanasi',
        screenLabel: 'Main Pavilion',
        price: 175,
        totalSeats: 24,
        isToday: false,
        occupiedSeats: <int>{},
      ),
    ],
  ),
];
