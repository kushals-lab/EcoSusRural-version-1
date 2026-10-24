import '../../clock/clock_screen.dart';
import '../../clock/reminder_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CompetitionModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status; // Upcoming, Ongoing, Closed
  final String startDate;
  final String endDate;
  final String prize;
  final String icon;

  const CompetitionModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.startDate,
    required this.endDate,
    required this.prize,
    required this.icon,
  });
}

const List<CompetitionModel> kCompetitions = [
  CompetitionModel(
    id: 'comp1',
    title: 'National Handicraft Excellence Award',
    description: 'Showcase your finest handcrafted piece. Winners get national recognition and cash prizes.',
    category: 'Handicrafts',
    status: 'Ongoing',
    startDate: 'Aug 1, 2026',
    endDate: 'Oct 15, 2026',
    prize: '₹1,00,000 + Premium Subscription',
    icon: '🏆',
  ),
  CompetitionModel(
    id: 'comp2',
    title: 'Organic Farmer of the Year',
    description: 'Demonstrate innovative organic farming practices with measurable impact.',
    category: 'Farming',
    status: 'Upcoming',
    startDate: 'Oct 1, 2026',
    endDate: 'Dec 30, 2026',
    prize: '₹50,000 + Free Export Training',
    icon: '🌱',
  ),
  CompetitionModel(
    id: 'comp3',
    title: 'Best Rural Food Product',
    description: 'Enter your processed food product for a chance to be featured on the marketplace homepage.',
    category: 'Food Processing',
    status: 'Upcoming',
    startDate: 'Nov 1, 2026',
    endDate: 'Jan 15, 2027',
    prize: '₹25,000 + Marketing Boost',
    icon: '🍲',
  ),
  CompetitionModel(
    id: 'comp4',
    title: 'Sustainable Packaging Innovation',
    description: 'Design eco-friendly packaging solutions for rural products.',
    category: 'Sustainability',
    status: 'Closed',
    startDate: 'May 1, 2026',
    endDate: 'Jul 30, 2026',
    prize: '₹30,000 + GreenPack Partnership',
    icon: '♻️',
  ),
];

class CompetitionsScreen extends StatefulWidget {
  const CompetitionsScreen({super.key});

  @override
  State<CompetitionsScreen> createState() => _CompetitionsScreenState();
}

class _CompetitionsScreenState extends State<CompetitionsScreen> {
  static const String _reminderPrefsKey = 'ecosus.competitions.reminders';

  final Color _primaryGreen = const Color(0xFF1B4D3E);
  String _selectedStatus = 'All';
  final List<String> _statuses = ['All', 'Upcoming', 'Ongoing', 'Closed'];

  /// Competitions the user has already set a reminder for (persisted so the
  /// tick mark survives navigation and app restarts).
  final Set<String> _reminderIds = <String>{};

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  Future<void> _loadReminders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_reminderPrefsKey);
      if (!mounted || saved == null || saved.isEmpty) return;
      setState(() => _reminderIds.addAll(saved));
    } catch (_) {
      // Reminders stay in memory when storage is unavailable.
    }
  }

  Future<void> _setReminder(CompetitionModel competition) async {
    final reminder = await Navigator.push<Reminder>(context, MaterialPageRoute(builder: (_) => ReminderEditor(
      existing: Reminder(id: DateTime.now().millisecondsSinceEpoch % 2000000000,
        title: competition.title, at: DateTime.now().add(const Duration(days: 1)), zone: 'Asia/Kolkata'))));
    if (reminder == null) return;
    try {
      final store = ReminderStore();
      await store.permissions();
      final records = await store.load();
      final status = await store.save([...records, reminder]);
      final prefs = await SharedPreferences.getInstance();
      _reminderIds.add(competition.id);
      await prefs.setStringList(_reminderPrefsKey, _reminderIds.toList());
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(status)));
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reminder was not scheduled. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final competitions = _selectedStatus == 'All'
        ? kCompetitions
        : kCompetitions.where((c) => c.status == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Text(
          'Competitions & Events',
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: _primaryGreen),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Status Filter Chips.
          //
          // The strip is deliberately taller than the chip itself and text
          // scaling is clamped, so All / Upcoming / Ongoing / Closed are always
          // fully visible instead of being clipped at the bottom.
          SizedBox(
            height: 68.h,
            child: MediaQuery.withClampedTextScaling(
              maxScaleFactor: 1.2,
              child: ListView(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                children: _statuses.map((status) {
                  final isSelected = _selectedStatus == status;
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Center(
                      child: ChoiceChip(
                        label: Text(status),
                        selected: isSelected,
                        selectedColor: _primaryGreen,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                        ),
                        labelPadding: EdgeInsets.symmetric(horizontal: 6.w),
                        visualDensity: VisualDensity.compact,
                        onSelected: (_) => setState(() => _selectedStatus = status),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          SizedBox(height: 8.h),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16.r),
              itemCount: competitions.length,
              itemBuilder: (context, index) {
                final comp = competitions[index];
                return _CompetitionCard(
                  competition: comp,
                  reminderSet: _reminderIds.contains(comp.id),
                  onSetReminder: () => _setReminder(comp),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _CompetitionCard extends StatelessWidget {
  const _CompetitionCard({
    required this.competition,
    required this.reminderSet,
    required this.onSetReminder,
  });
  final CompetitionModel competition;

  /// Whether the user already set a reminder for this competition.
  final bool reminderSet;

  /// Called when the user taps "Set Reminder".
  final VoidCallback onSetReminder;

  final Color _primaryGreen = const Color(0xFF1B4D3E);

  @override
  Widget build(BuildContext context) {
    final statusColor = switch (competition.status) {
      'Upcoming' => const Color(0xFF1565C0),
      'Ongoing' => const Color(0xFF2E7D32),
      'Closed' => const Color(0xFF757575),
      _ => const Color(0xFF757575),
    };

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(child: Text(competition.icon, style: TextStyle(fontSize: 24.sp))),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      competition.title,
                      style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '${competition.category} • ${competition.startDate} - ${competition.endDate}',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  competition.status,
                  style: TextStyle(fontSize: 10.sp, color: statusColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            competition.description,
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700], height: 1.4),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Icon(Icons.emoji_events, color: Colors.amber.shade700, size: 16),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  'Prize: ${competition.prize}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.amber.shade800,
                      fontWeight: FontWeight.w600),
                ),
              ),
              const Spacer(),
              if (competition.status != 'Closed')
                reminderSet
                    ? Flexible(
                        child: Tooltip(
                          message: 'Reminder is set for this competition',
                          child: Semantics(
                            label: 'Reminder set for ${competition.title}',
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 5.h),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                borderRadius: BorderRadius.circular(20.r),
                                border: Border.all(color: Colors.green.shade600),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.check_circle,
                                      size: 14.r, color: Colors.green.shade700),
                                  SizedBox(width: 4.w),
                                  Flexible(
                                    child: Text(
                                      'Reminder set',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green.shade700,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : TextButton.icon(
                        onPressed: onSetReminder,
                        icon: const Icon(Icons.notifications_none, size: 16),
                        label: Text(
                          'Set Reminder',
                          style: TextStyle(color: _primaryGreen, fontSize: 12.sp),
                        ),
                      ),
            ],
          ),
        ],
      ),
    );
  }
}