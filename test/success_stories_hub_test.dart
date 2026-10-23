import 'package:eco_sus_rural/features/marketplace/screens/marketplace_screen.dart';
import 'package:eco_sus_rural/features/marketplace/screens/success_stories_hub_screen.dart';
import 'package:eco_sus_rural/features/marketplace/screens/success_story_upload_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    // The hub and the upload flow share this in-memory moderation queue.
    globalStorySubmissions.clear();
  });

  Future<void> pumpScreen(WidgetTester tester, Widget child) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpWidget(
      ProviderScope(
        child: ScreenUtilInit(
          designSize: const Size(390, 844),
          minTextAdapt: true,
          child: MaterialApp(home: child),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpHub(WidgetTester tester, {int initialTabIndex = 0}) {
    return pumpScreen(
      tester,
      SuccessStoriesHubScreen(initialTabIndex: initialTabIndex),
    );
  }

  Future<void> pumpMarketplace(WidgetTester tester) {
    return pumpScreen(tester, const MarketplaceScreen());
  }

  testWidgets('hub exposes a watch section and an upload section', (
    tester,
  ) async {
    await pumpHub(tester);

    // Two sections, both reachable without logging in.
    expect(find.text('Stories & Videos'), findsOneWidget);
    expect(find.text('Upload Video'), findsOneWidget);

    // Section 1 — anyone can see the published video interviews.
    expect(find.text('Featured Video Interviews'), findsOneWidget);
    expect(
      find.text('Radha Devi • Madhubani Master Artist, Bihar'),
      findsOneWidget,
    );
    expect(find.textContaining('Anyone can watch these interviews'), findsOneWidget);
  });

  testWidgets('upload section opens the video submission form', (tester) async {
    await pumpHub(tester);

    await tester.tap(find.text('Upload Video'));
    await tester.pumpAndSettle();

    // Section 2 — anyone can upload a video for review.
    expect(find.text('Story Details'), findsOneWidget);
    expect(find.textContaining('Tap to select a video or audio file'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(3));
  });

  testWidgets('an uploaded video enters the moderation queue', (tester) async {
    await pumpHub(tester, initialTabIndex: 1);

    final fields = find.byType(TextFormField);
    await tester.ensureVisible(fields.at(0));
    await tester.enterText(fields.at(0), 'My EcoSusRural journey');
    await tester.enterText(fields.at(1), 'Test Farmer • Nashik, Maharashtra');
    await tester.enterText(
      fields.at(2),
      'I doubled my farm income by selling organic produce directly to buyers.',
    );
    await tester.pumpAndSettle();

    final picker = find.textContaining('Tap to select a video or audio file');
    await tester.ensureVisible(picker);
    await tester.tap(picker);
    await tester.pumpAndSettle();

    final policy = find.byType(Checkbox);
    await tester.ensureVisible(policy);
    await tester.tap(policy);
    await tester.pumpAndSettle();

    final submit = find.text('Submit Story for Review');
    await tester.ensureVisible(submit);
    await tester.tap(submit);
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Story Submitted!'), findsOneWidget);
    expect(globalStorySubmissions, hasLength(1));
    expect(
      globalStorySubmissions.single.status,
      StoryModerationStatus.pending,
    );

    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();

    // The uploader immediately sees their own submission in the same hub.
    expect(find.text('My EcoSusRural journey'), findsOneWidget);
  });

  testWidgets('anyone can open a story video and watch it', (tester) async {
    await pumpHub(tester);

    await tester.tap(
      find.text('Radha Devi • Madhubani Master Artist, Bihar'),
    );
    await tester.pumpAndSettle();

    // Simulated player chrome with playback controls.
    expect(find.text('SIMULATED PLAYBACK'), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Share'), findsOneWidget);
  });

  testWidgets('approved uploads are published for everyone to watch', (
    tester,
  ) async {
    globalStorySubmissions.add(
      SuccessStorySubmission(
        id: 'sub_demo',
        title: 'Community video story',
        personName: 'Sunita Devi • Bhagalpur, Bihar',
        description: 'My handicraft business now sells to six countries.',
        videoFileName: 'community_story.mp4',
        status: StoryModerationStatus.approved,
        submittedAt: DateTime(2026, 1, 12),
      ),
    );

    await pumpHub(tester);

    // The watch section scrolls — bring the published uploads into view.
    await tester.drag(find.byType(ListView), const Offset(0, -320));
    await tester.pumpAndSettle();

    expect(find.text('Community Uploads'), findsOneWidget);
    expect(find.text('Community video story'), findsOneWidget);
    expect(find.text('Approved'), findsOneWidget);
  });

  testWidgets('marketplace banner links to both success story sections', (
    tester,
  ) async {
    await pumpMarketplace(tester);

    // Banner body → watch section.
    await tester.tap(find.textContaining('Watch video interviews'));
    await tester.pumpAndSettle();
    expect(find.text('Stories & Videos'), findsOneWidget);
    expect(find.text('Featured Video Interviews'), findsOneWidget);

    // Back to the marketplace, then the upload icon → upload section.
    await tester.pageBack();
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Upload video'));
    await tester.pumpAndSettle();
    expect(find.text('Story Details'), findsOneWidget);
    expect(
      find.textContaining('Tap to select a video or audio file'),
      findsOneWidget,
    );
  });
}