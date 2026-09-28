import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/service_category.dart';
import '../services/notification_service.dart';
import '../services/link_service.dart';
import '../services/location_share_service.dart';
import 'booking_form_screen.dart';
import 'catering_booking_screen.dart';
import 'community_market_screens.dart';
import 'profile_screen.dart';
import 'service_screen.dart';
import 'travel_scope_screen.dart';
import 'venue_booking_screen.dart';
import 'market_catalog_screen.dart';
import 'special_booking_screens.dart';
import 'clinic_screen.dart';
import 'demo_mode_screen.dart';

const orange = Color(0xfff45b22);
const cream = Color(0xfffff8f1);
const ink = Color(0xff30221c);

class ProductionHomeScreen extends StatefulWidget {
  const ProductionHomeScreen({super.key});
  @override
  State<ProductionHomeScreen> createState() => _ProductionHomeScreenState();
}

class _ProductionHomeScreenState extends State<ProductionHomeScreen> {
  String selectedTab = 'home';
  bool kannada = false;
  String tr(String en, String kn) => kannada ? kn : en;

  @override
  void initState() {
    super.initState();
    NotificationService().initialize();
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('platformSettings').doc('features').snapshots(),
    builder: (_, snapshot) => buildShell(snapshot.data?.data() ?? const <String, dynamic>{}),
  );

  Widget buildShell(Map<String, dynamic> features) {
    final tabs = <({String id, Widget page, NavigationDestination destination})>[
      (
        id: 'home',
        page: HomeTab(kannada: kannada, features: features, openService: openService, openFind: openFind, openFindTab: () => setState(() => selectedTab = 'find'), openAnnouncements: () => setState(() => selectedTab = 'announcements')),
        destination: NavigationDestination(icon: const Text('🏠', style: TextStyle(fontSize: 18)), label: tr('Home', 'ಮುಖಪುಟ')),
      ),
      if (features['nav_find'] != false)
        (
          id: 'find',
          page: FindForMeTab(kannada: kannada, openFind: openFind),
          destination: NavigationDestination(icon: const Text('🔎', style: TextStyle(fontSize: 18)), label: tr('Find For Me', 'ನನಗಾಗಿ ಹುಡುಕಿ')),
        ),
      if (features['nav_announcements'] != false)
        (
          id: 'announcements',
          page: AnnouncementsTab(kannada: kannada),
          destination: NavigationDestination(icon: const Text('📢', style: TextStyle(fontSize: 18)), label: tr('Announcements', 'ಪ್ರಕಟಣೆ')),
        ),
      if (features['nav_new_city'] != false)
        (
          id: 'new_city',
          page: NewCityTab(kannada: kannada),
          destination: NavigationDestination(icon: const Text('✨', style: TextStyle(fontSize: 18)), label: tr('New in City', 'ನಗರದಲ್ಲಿ ಹೊಸದು')),
        ),
      (
        id: 'sos',
        page: SosTab(kannada: kannada),
        destination: NavigationDestination(icon: const Text('🆘', style: TextStyle(fontSize: 18)), label: tr('SOS', 'ತುರ್ತು')),
      ),
    ];
    final requestedIndex = tabs.indexWhere((tab) => tab.id == selectedTab);
    final selectedIndex = requestedIndex < 0 ? 0 : requestedIndex;
    final selectedId = tabs[selectedIndex].id;
    final showSevakaButton = !(selectedId == 'sos' || features['assistant_enabled'] == false);
    return Scaffold(
      backgroundColor: cream,
      appBar: header(features['nav_announcements'] != false),
      body: Stack(children: [
        Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 430), child: IndexedStack(index: selectedIndex, children: tabs.map((tab) => tab.page).toList()))),
        if (showSevakaButton) DraggableSevakaButton(onPressed: showSevaka),
      ]),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          labelTextStyle: WidgetStateProperty.all(GoogleFonts.poppins(fontSize: 8, fontWeight: FontWeight.w600, color: ink, letterSpacing: -0.1, height: 1.1)),
        ),
        child: NavigationBar(
          selectedIndex: selectedIndex,
          onDestinationSelected: (value) => setState(() => selectedTab = tabs[value].id),
          indicatorColor: const Color(0xffffd9c7),
          destinations: tabs.map((tab) => tab.destination).toList(),
        ),
      ),
    );
  }


  PreferredSizeWidget header(bool announcementsEnabled) => AppBar(
    automaticallyImplyLeading: false, backgroundColor: orange, foregroundColor: Colors.white, toolbarHeight: 72, titleSpacing: 14,
    title: FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('NAMMA RANEBENNUR', maxLines: 1, style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: .3)),
      Text('ನಮ್ಮ ರಾಣೆಬೆಣ್ಣೂರು · Connecting People', maxLines: 1, style: GoogleFonts.poppins(fontSize: 9.5, fontWeight: FontWeight.w500)),
    ])),
    actions: [
      TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const DemoModeScreen())), child: const Text('DEMO', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900))),
      TextButton(onPressed: () => setState(() => kannada = !kannada), child: Text(kannada ? 'EN' : 'ಕನ್ನಡ', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
      IconButton(
        onPressed: () {
          if (announcementsEnabled) {
            setState(() => selectedTab = 'announcements');
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr('Announcements are temporarily unavailable.', 'ಪ್ರಕಟಣೆಗಳು ತಾತ್ಕಾಲಿಕವಾಗಿ ಲಭ್ಯವಿಲ್ಲ.'))));
          }
        },
        icon: const Badge(child: Text('🔔', style: TextStyle(fontSize: 19))),
      ),
      IconButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())), icon: const Text('👤', style: TextStyle(fontSize: 20))),
    ],
  );

  void openService(ServiceCategory category) {
    final page = switch (category.id) {
      'travel' => TravelScopeScreen(kannada: kannada),
      'hotels' => VenueBookingScreen(hotel: true, kannada: kannada),
      'halls' => VenueBookingScreen(hotel: false, kannada: kannada),
      'vibe_town' => VibeTownBookingScreen(kannada: kannada),
      'delivery' => DeliveryBookingScreen(kannada: kannada),
      'clinic' => ClinicScreen(kannada: kannada),
      _ => ServiceScreen(category: category, kannada: kannada),
    };
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void openFind(String name) {
    final Widget page = switch (name) {
      'Market' => const MarketCatalogScreen(),
      'Sale' => const LocalSaleScreen(),
      'Requirements' => const RequirementsScreen(),
      'Catering' => CateringBookingScreen(kannada: kannada),
      _ => BookingFormScreen(parent: ServiceCategory(name.toLowerCase(), name, name, Icons.search), service: ServiceCategory(name.toLowerCase(), name, name, Icons.search)),
    };
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  void showSevaka() => showModalBottomSheet<void>(
    context: context, isScrollControlled: true, showDragHandle: true,
    builder: (_) => Padding(
      padding: EdgeInsets.fromLTRB(20, 4, 20, MediaQuery.viewInsetsOf(context).bottom + 24),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Image.asset('assets/images/app/nimma-sevaka-genie.png', height: 96),
        Text(tr('Namaskara! I am Nimma Sevaka.', 'ನಮಸ್ಕಾರ! ನಾನು ನಿಮ್ಮ ಸೇವಕ.'), style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w700)),
        Text(tr('Speak or type what you need.', 'ನಿಮಗೆ ಬೇಕಾದುದನ್ನು ಹೇಳಿ ಅಥವಾ ಟೈಪ್ ಮಾಡಿ.')),
        const SizedBox(height: 12),
        TextField(decoration: InputDecoration(prefixIcon: const Icon(Icons.mic), hintText: tr('Type your requirement…', 'ನಿಮ್ಮ ಅಗತ್ಯವನ್ನು ಟೈಪ್ ಮಾಡಿ…'), suffixIcon: const Icon(Icons.send))),
      ]),
    ),
  );
}

class DraggableSevakaButton extends StatefulWidget {
  const DraggableSevakaButton({super.key, required this.onPressed}); final VoidCallback onPressed;
  @override
  State<DraggableSevakaButton> createState() => _DraggableSevakaButtonState();
}

class _DraggableSevakaButtonState extends State<DraggableSevakaButton> {
  static const buttonSize = 64.0;
  Offset? offset;

  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, constraints) {
    final bounds = constraints.biggest;
    final pos = offset ?? Offset(bounds.width - buttonSize - 16, bounds.height - buttonSize - 16);
    final maxX = (bounds.width - buttonSize).clamp(0, double.infinity).toDouble();
    final maxY = (bounds.height - buttonSize).clamp(0, double.infinity).toDouble();
    return Stack(children: [
      Positioned(
        left: pos.dx.clamp(0, maxX),
        top: pos.dy.clamp(0, maxY),
        child: GestureDetector(
          onPanUpdate: (details) => setState(() => offset = Offset(
            (pos.dx + details.delta.dx).clamp(0, maxX),
            (pos.dy + details.delta.dy).clamp(0, maxY),
          )),
          child: FloatingActionButton(
            heroTag: 'nimma-sevaka', backgroundColor: const Color(0xffffdac9), onPressed: widget.onPressed,
            child: Image.asset('assets/images/app/nimma-sevaka-genie.png', width: 60, height: 60),
          ),
        ),
      ),
    ]);
  });
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key, required this.kannada, required this.features, required this.openService, required this.openFind, required this.openFindTab, required this.openAnnouncements});
  final bool kannada;
  final Map<String, dynamic> features;
  final ValueChanged<ServiceCategory> openService;
  final ValueChanged<String> openFind;
  final VoidCallback openFindTab;
  final VoidCallback openAnnouncements;
  String tr(String en, String kn) => kannada ? kn : en;

  @override
  Widget build(BuildContext context) {
    const featureByService = <String, String>{
      'hotels': 'feature_hotel',
      'vibe_town': 'feature_vibe_town',
      'halls': 'feature_function_hall',
      'clinic': 'feature_clinic',
      'travel': 'feature_travel',
      'home_services': 'feature_home_services',
      'delivery': 'feature_nimma_sevaka_delivery',
      'machinery': 'feature_machinery',
    };
    final visibleBookings = quickBookings.where((item) => features[featureByService[item.id]] != false).toList();
    return ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 96), children: [
    SponsoredCard(kannada: kannada), const SizedBox(height: 10), AnnouncementTicker(kannada: kannada, onTap: openAnnouncements), const SizedBox(height: 18),
    Text(tr('QUICK BOOKING', 'ಸರಳ ಬುಕ್ಕಿಂಗ್'), style: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w800, color: orange, letterSpacing: .5)),
    Text(tr('What do you want to book?', 'ಏನು ಬುಕ್ ಮಾಡಬೇಕು?'), style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800, color: ink)),
    Text(tr('Choose a service, pick an available time and book. Simple.', 'ಸೇವೆಯನ್ನು ಆಯ್ಕೆ ಮಾಡಿ. ಲಭ್ಯ ಸಮಯವನ್ನು ನೋಡಿ ಮತ್ತು ಬುಕ್ ಮಾಡಿ.'), style: GoogleFonts.poppins(fontSize: 12, color: Colors.black54)), const SizedBox(height: 12),
    GridView.builder(
      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: visibleBookings.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: .78),
      itemBuilder: (_, i) => BookingTile(item: visibleBookings[i], kannada: kannada, onTap: () => openService(visibleBookings[i])),
    ),
    const SizedBox(height: 9),
    Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9), decoration: BoxDecoration(color: const Color(0xffffeadf), borderRadius: BorderRadius.circular(12)), child: Row(children: [const Icon(Icons.touch_app_rounded, color: orange, size: 18), const SizedBox(width: 8), Expanded(child: Text(tr('Tap one option to continue. Availability opens after selection.', 'ಮುಂದುವರಿಯಲು ಒಂದು ಆಯ್ಕೆಯನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ.'), style: GoogleFonts.poppins(fontSize: 10.5)))])),
    const SizedBox(height: 17),
    SectionLink(icon: Icons.receipt_long_rounded, title: tr('My Bookings', 'ನನ್ನ ಬುಕ್ಕಿಂಗ್‌ಗಳು'), subtitle: tr('Track requests, quotes and confirmations', 'ವಿನಂತಿಗಳು, ದರಗಳು ಮತ್ತು ದೃಢೀಕರಣಗಳನ್ನು ನೋಡಿ'), onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()))),
    const SizedBox(height: 17),
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(tr('Local Posts', 'ಸ್ಥಳೀಯ ಪೋಸ್ಟ್‌ಗಳು'), style: GoogleFonts.poppins(fontSize: 21, fontWeight: FontWeight.w800, color: ink)), TextButton(onPressed: () => openFind('Requirements'), child: Text(tr('View all', 'ಎಲ್ಲವನ್ನೂ ನೋಡಿ')))]),
    LocalPosts(kannada: kannada, openFind: openFindTab),
    ]);
  }
}

class SponsoredCard extends StatefulWidget {
  const SponsoredCard({super.key, required this.kannada}); final bool kannada;
  @override
  State<SponsoredCard> createState() => _SponsoredCardState();
}

class _SponsoredCardState extends State<SponsoredCard> {
  int index = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 3600), (_) {
      if (mounted) setState(() => index++);
    });
  }

  @override
  void dispose() { timer?.cancel(); super.dispose(); }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('advertisements').where('status', isEqualTo: 'approved').limit(10).snapshots(),
    builder: (_, snapshot) {
      final live = (snapshot.data?.docs ?? []).map((doc) => doc.data()).where((ad) => ad['active'] != false).toList();
      final ads = live.isEmpty ? <Map<String, dynamic>>[{
        'advertiserName': 'Your Business Here', 'title': 'Reach Ranebennur customers', 'body': 'Promote your shop, service or event on the first screen.', 'emoji': '📣', 'cta': 'Advertise Here', 'theme': 'orange', 'targetUrl': '',
      }, {
        'advertiserName': 'Partner Preview', 'title': 'Local offers get priority', 'body': 'Verified merchant offers will rotate in this space.', 'emoji': '🏪', 'cta': 'Join as Partner', 'theme': 'gold', 'targetUrl': '',
      }, {
        'advertiserName': 'Community Preview', 'title': 'Promote local events', 'body': 'Festivals, openings and public programmes can be featured here.', 'emoji': '🎪', 'cta': 'Submit Promotion', 'theme': 'red', 'targetUrl': '',
      }] : live;
      final activeIndex = index % ads.length;
      final ad = ads[activeIndex];
      return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(widget.kannada ? 'ಪ್ರಾಯೋಜಿತ ಜಾಹೀರಾತು' : 'SPONSORED AD', style: const TextStyle(color: orange, fontWeight: FontWeight.w900, fontSize: 10)), TextButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PostAdScreen())), child: Text(widget.kannada ? 'ಇಲ್ಲಿ ಜಾಹೀರಾತು ನೀಡಿ' : 'Advertise here'))]),
        Material(color: Colors.transparent, child: InkWell(borderRadius: BorderRadius.circular(18), onTap: () { final target = (ad['targetUrl'] ?? '').toString(); if (target.isNotEmpty) { LinkService.open(target); } else { Navigator.push(context, MaterialPageRoute(builder: (_) => const PostAdScreen())); } }, child: Container(constraints: const BoxConstraints(minHeight: 136), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [orange, Color(0xffff8a45)]), borderRadius: BorderRadius.circular(18)), child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [Text((ad['advertiserName'] ?? 'Namma Ranebennur').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontSize: 10)), const SizedBox(height: 4), Text((ad['title'] ?? '').toString(), maxLines: 1, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 18)), const SizedBox(height: 3), Text((ad['body'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontSize: 11, height: 1.3)), const SizedBox(height: 4), Text('${ad['cta'] ?? 'View'} →', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 11))])), const SizedBox(width: 8), Text((ad['emoji'] ?? '📣').toString(), style: const TextStyle(fontSize: 48))])))),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(ads.length, (dot) => GestureDetector(
            onTap: () => setState(() => index = dot),
            child: Container(
              width: dot == activeIndex ? 18 : 7,
              height: 7,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(color: dot == activeIndex ? orange : Colors.black26, borderRadius: BorderRadius.circular(9)),
            ),
          )),
        ),
      ]);
    },
  );
}

class AnnouncementTicker extends StatefulWidget {
  const AnnouncementTicker({super.key, required this.kannada, required this.onTap}); final bool kannada; final VoidCallback onTap;
  @override
  State<AnnouncementTicker> createState() => _AnnouncementTickerState();
}

class _AnnouncementTickerState extends State<AnnouncementTicker> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  int index = 0;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(seconds: 7))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() => index++);
          controller.forward(from: 0);
        }
      })
      ..forward();
  }

  @override
  void dispose() { controller.dispose(); super.dispose(); }

  double measureTextWidth(String text, TextStyle style) {
    final painter = TextPainter(text: TextSpan(text: text, style: style), maxLines: 1, textDirection: TextDirection.ltr)..layout();
    return painter.width;
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('announcements').where('published', isEqualTo: true).limit(8).snapshots(),
    builder: (_, snapshot) {
      final docs = snapshot.data?.docs ?? [];
      final texts = docs.isEmpty
        ? [widget.kannada ? 'ಪರಿಶೀಲಿಸಿದ ನಗರ ಪ್ರಕಟಣೆಗಳು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ' : 'Verified city announcements will appear here']
        : docs.map((doc) { final d = doc.data(); return (widget.kannada ? d['titleKn'] ?? d['title'] : d['title']).toString(); }).toList();
      final text = texts[index % texts.length];
      final style = GoogleFonts.poppins(fontSize: 11.5);
      final textWidth = measureTextWidth(text, style);
      return Material(color: const Color(0xffffedd5), borderRadius: BorderRadius.circular(12), child: InkWell(onTap: widget.onTap, borderRadius: BorderRadius.circular(12), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), child: Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
        const Text('📢', style: TextStyle(fontSize: 19)), const SizedBox(width: 8),
        Text(widget.kannada ? 'ಪ್ರಕಟಣೆ' : 'ANNOUNCEMENT', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900)), const SizedBox(width: 8),
        Expanded(child: ClipRect(child: SizedBox(height: 22, child: LayoutBuilder(builder: (context, constraints) => AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            final dx = constraints.maxWidth - controller.value * (constraints.maxWidth + textWidth);
            return Transform.translate(offset: Offset(dx, 0), child: child);
          },
          child: Text(text, maxLines: 1, overflow: TextOverflow.visible, softWrap: false, style: style),
        ))))),
        const SizedBox(width: 4), const Icon(Icons.chevron_right, size: 18),
      ]))));
    },
  );
}

class BookingTile extends StatelessWidget {
  const BookingTile({super.key, required this.item, required this.kannada, required this.onTap});
  final ServiceCategory item; final bool kannada; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(15), child: InkWell(onTap: onTap, borderRadius: BorderRadius.circular(15), child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10), child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [item.emoji == null ? Icon(item.icon, color: orange, size: 28) : Text(item.emoji!, style: const TextStyle(fontSize: 29)), const SizedBox(height: 7), Text(kannada ? item.kannadaTitle : item.title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: GoogleFonts.poppins(fontSize: 10.5, fontWeight: FontWeight.w600))]))));
}

class SectionLink extends StatelessWidget {
  const SectionLink({super.key, required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon; final String title; final String subtitle; final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(16), child: ListTile(onTap: onTap, leading: CircleAvatar(backgroundColor: const Color(0xffffeadf), child: Icon(icon, color: orange)), title: Text(title, style: GoogleFonts.poppins(fontWeight: FontWeight.w700)), subtitle: Text(subtitle, style: GoogleFonts.poppins(fontSize: 10.5)), trailing: const Icon(Icons.chevron_right_rounded)));
}

class LocalPosts extends StatelessWidget {
  const LocalPosts({super.key, required this.kannada, required this.openFind}); final bool kannada; final VoidCallback openFind;
  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('posts').where('status', isEqualTo: 'approved').limit(3).snapshots(),
    builder: (_, snapshot) {
      final docs = snapshot.data?.docs ?? [];
      if (docs.isEmpty) return SectionLink(icon: Icons.people_alt_rounded, title: kannada ? 'ನಿಮ್ಮ ನಗರದೊಂದಿಗೆ ಸಂಪರ್ಕದಲ್ಲಿರಿ' : 'Stay connected with your city', subtitle: kannada ? 'ಸ್ಥಳೀಯ ಅಗತ್ಯಗಳು ಮತ್ತು ನವೀಕರಣಗಳು ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತವೆ' : 'Local needs and updates will appear here', onTap: openFind);
      return Column(children: docs.map((doc) { final d = doc.data(); return Card(child: ListTile(onTap: openFind, leading: const Icon(Icons.forum_rounded, color: orange), title: Text((d['title'] ?? d['content'] ?? 'Local post').toString(), maxLines: 1, overflow: TextOverflow.ellipsis), subtitle: Text((d['content'] ?? '').toString(), maxLines: 2, overflow: TextOverflow.ellipsis), trailing: TextButton(onPressed: openFind, child: Text(kannada ? 'ನೋಡಿ' : 'View')))); }).toList());
    },
  );
}

class FindForMeTab extends StatefulWidget {
  const FindForMeTab({super.key, required this.kannada, required this.openFind});
  final bool kannada;
  final ValueChanged<String> openFind;
  @override
  State<FindForMeTab> createState() => _FindForMeTabState();
}

class _FindForMeTabState extends State<FindForMeTab> {
  String main = 'Property';
  String sub = '';
  String mode = '';
  String search = '';

  static const groups = <String, List<String>>{
    'Property': ['House', 'Land', 'Commercial Space / Shop'],
    'Events': ['Catering', 'Decoration', 'Tent House & Seating', 'DJ & Sound', 'Lighting', 'Photography / Video', 'Cakes & Gifts', 'Complete Event Package'],
    'Location': ['Near me', 'Landmarks', 'Hospitals', 'Government Offices', 'Transport'],
  };
  static const emojis = <String, String>{
    'House': '🏠', 'Land': '🌾', 'Commercial Space / Shop': '🏬',
    'Catering': '🍽️', 'Decoration': '🎀', 'Tent House & Seating': '⛺',
    'DJ & Sound': '🔊', 'Lighting': '💡', 'Photography / Video': '📷',
    'Cakes & Gifts': '🎂', 'Complete Event Package': '🎉', 'Near me': '📍',
    'Landmarks': '📌', 'Hospitals': '🏥', 'Government Offices': '🏛️', 'Transport': '🚌',
  };
  static const kn = <String, String>{
    'Property': 'ಆಸ್ತಿ', 'Market': 'ಮಾರುಕಟ್ಟೆ', 'Sale': 'ಮಾರಾಟ', 'Events': 'ಕಾರ್ಯಕ್ರಮಗಳು', 'Location': 'ಸ್ಥಳ',
    'House': 'ಮನೆ', 'Land': 'ಜಮೀನು', 'Commercial Space / Shop': 'ವಾಣಿಜ್ಯ ಸ್ಥಳ / ಅಂಗಡಿ', 'Catering': 'ಕೇಟರಿಂಗ್',
    'Decoration': 'ಅಲಂಕಾರ', 'Tent House & Seating': 'ಟೆಂಟ್ ಹೌಸ್ ಮತ್ತು ಆಸನ', 'DJ & Sound': 'ಡಿಜೆ ಮತ್ತು ಸೌಂಡ್',
    'Lighting': 'ಲೈಟಿಂಗ್', 'Photography / Video': 'ಫೋಟೋಗ್ರಫಿ / ವಿಡಿಯೋ', 'Cakes & Gifts': 'ಕೇಕ್ ಮತ್ತು ಉಡುಗೊರೆ',
    'Complete Event Package': 'ಸಂಪೂರ್ಣ ಕಾರ್ಯಕ್ರಮ ಪ್ಯಾಕೇಜ್', 'Near me': 'ನನ್ನ ಹತ್ತಿರ', 'Landmarks': 'ಪ್ರಮುಖ ಸ್ಥಳಗಳು',
    'Hospitals': 'ಆಸ್ಪತ್ರೆಗಳು', 'Government Offices': 'ಸರ್ಕಾರಿ ಕಚೇರಿಗಳು', 'Transport': 'ಸಾರಿಗೆ',
  };
  String label(String value) => widget.kannada ? kn[value] ?? value : value;

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('posts').where('status', isEqualTo: 'approved').limit(50).snapshots(),
    builder: (_, snapshot) {
      final posts = (snapshot.data?.docs ?? []).where((doc) {
        final data = doc.data();
        final haystack = '${data['title'] ?? ''} ${data['content'] ?? data['body'] ?? ''} ${data['area'] ?? ''}'.toLowerCase();
        final categoryMatch = (data['category'] ?? '').toString() == main;
        final subMatch = sub.isEmpty || (data['subcategory'] ?? '').toString() == sub || haystack.contains(sub.toLowerCase());
        final modeMatch = mode.isEmpty || (data['listingMode'] ?? '').toString() == mode;
        return categoryMatch && subMatch && modeMatch && (search.isEmpty || haystack.contains(search.toLowerCase()));
      }).toList();
      return ListView(padding: const EdgeInsets.fromLTRB(14, 16, 14, 100), children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xfff45b22), Color(0xffff8a45)]), borderRadius: BorderRadius.circular(18)), child: Row(children: [const Icon(Icons.manage_search_rounded, color: Colors.white, size: 48), const SizedBox(width: 12), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.kannada ? 'ಸ್ಥಳೀಯ ಹುಡುಕಾಟ + ಅವಶ್ಯಕತೆಗಳು' : 'LOCAL SEARCH + REQUIREMENTS', style: const TextStyle(color: Colors.white70, fontSize: 10)), Text(widget.kannada ? 'ನನಗಾಗಿ ಹುಡುಕಿ' : 'Find For Me', style: GoogleFonts.poppins(color: Colors.white, fontSize: 25, fontWeight: FontWeight.w800)), Text(widget.kannada ? 'ನಿಮ್ಮ ಸಂಖ್ಯೆಯನ್ನು ಬಹಿರಂಗಪಡಿಸದೆ ಹುಡುಕಿ ಅಥವಾ ಬೇಡಿಕೆ ಪೋಸ್ಟ್ ಮಾಡಿ.' : 'Find it, request it or compare local options without exposing your number.', style: const TextStyle(color: Colors.white70, fontSize: 11))]))])),
        const SizedBox(height: 12),
        TextField(onChanged: (value) => setState(() => search = value.trim()), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), hintText: widget.kannada ? 'ಆಸ್ತಿ, ಉತ್ಪನ್ನ, ಕೇಟರಿಂಗ್ ಹುಡುಕಿ…' : 'Search property, product, catering, event…', border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)))),
        const SizedBox(height: 12),
        Row(children: <(String, String)>[('Property', '🏠'), ('Market', '🛒'), ('Sale', '🏷️'), ('Events', '🎉'), ('Location', '📍')].map((item) => Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 2), child: InkWell(borderRadius: BorderRadius.circular(12), onTap: () {
          if (item.$1 == 'Market' || item.$1 == 'Sale') { widget.openFind(item.$1); return; }
          setState(() { main = item.$1; sub = ''; mode = ''; });
        }, child: Container(padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2), decoration: BoxDecoration(color: main == item.$1 ? const Color(0xffffe3d5) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: main == item.$1 ? orange : Colors.black12)), child: Column(children: [Text(item.$2, style: const TextStyle(fontSize: 23)), const SizedBox(height: 4), Text(label(item.$1), maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700))])))))).toList()),
        const SizedBox(height: 15),
        Text(widget.kannada ? '${label(main)} ಪ್ರಕಾರ ಆಯ್ಕೆ ಮಾಡಿ' : 'Choose ${main.toLowerCase()} type', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 17)),
        Text(widget.kannada ? 'ನಿಮಗೆ ಬೇಕಾದ ಚಿತ್ರವನ್ನು ಟ್ಯಾಪ್ ಮಾಡಿ' : 'Tap the option you need', style: const TextStyle(color: Colors.black54)),
        const SizedBox(height: 10),
        GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: groups[main]?.length ?? 0, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 8, mainAxisSpacing: 8, childAspectRatio: 1.7), itemBuilder: (_, index) {
          final item = groups[main]![index];
          return Material(color: sub == item ? const Color(0xffffe3d5) : Colors.white, borderRadius: BorderRadius.circular(14), child: InkWell(borderRadius: BorderRadius.circular(14), onTap: () {
            if (main == 'Events' && item == 'Catering') { widget.openFind('Catering'); return; }
            setState(() => sub = sub == item ? '' : item);
          }, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Expanded(child: MasterFindSprite(main: main, index: index, fallback: emojis[item] ?? '📌')),
            Padding(padding: const EdgeInsets.fromLTRB(9, 5, 7, 8), child: Row(children: [Text(emojis[item] ?? '📌', style: const TextStyle(fontSize: 18)), const SizedBox(width: 6), Expanded(child: Text(label(item), maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 10))), const Icon(Icons.chevron_right_rounded, color: orange, size: 17)])),
          ])));
        }),
        if (main == 'Property') Padding(padding: const EdgeInsets.only(top: 10), child: Wrap(spacing: 8, children: ['To-Let', 'Sell', 'Lease'].map((item) => ChoiceChip(label: Text(item), selected: mode == item, onSelected: (_) => setState(() => mode = mode == item ? '' : item))).toList())),
        const SizedBox(height: 14),
        Material(color: const Color(0xff3f2b21), borderRadius: BorderRadius.circular(16), child: ListTile(onTap: () => widget.openFind('Requirements'), textColor: Colors.white, iconColor: Colors.white, leading: const Icon(Icons.campaign_rounded), title: Text(widget.kannada ? 'ನನ್ನ ಅವಶ್ಯಕತೆ ಪೋಸ್ಟ್ ಮಾಡಿ' : 'Post My Requirement', style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text(widget.kannada ? 'ಪರಿಶೀಲಿತ ಸೇವಾದಾರರು ನಮ್ಮ ಮೂಲಕ ಉತ್ತರಿಸುತ್ತಾರೆ.' : 'Verified providers respond through Namma Ranebennur.'), trailing: const Icon(Icons.chevron_right))),
        const SizedBox(height: 10),
        Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xffedf7ef), borderRadius: BorderRadius.circular(14)), child: Row(children: [const Icon(Icons.verified_user_rounded, color: Colors.green), const SizedBox(width: 9), Expanded(child: Text(widget.kannada ? 'ಕೊಟೇಶನ್ ಮತ್ತು ಆಯ್ಕೆ ನಮ್ಮ ವೇದಿಕೆಯಲ್ಲೇ ಇರುತ್ತದೆ. ನಿಮ್ಮ ಸಂಪರ್ಕ ಸುರಕ್ಷಿತ.' : 'Quotes and selection stay inside the platform. Your contact remains protected.', style: const TextStyle(fontSize: 11)))])),
        const SizedBox(height: 15),
        Text(sub.isEmpty ? (widget.kannada ? '${label(main)} ಆಯ್ಕೆಗಳನ್ನು ನೋಡಿ' : 'Browse $main options') : '${label(sub)}${mode.isEmpty ? '' : ' · $mode'}', style: GoogleFonts.poppins(fontSize: 19, fontWeight: FontWeight.w800)),
        if (posts.isEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 25), child: Text(widget.kannada ? 'ಈ ಫಿಲ್ಟರ್‌ಗೆ ಪರಿಶೀಲಿತ ಪೋಸ್ಟ್‌ಗಳು ಇನ್ನೂ ಇಲ್ಲ.' : 'No verified posts match this filter yet.', textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)))
        else ...posts.map((doc) { final data = doc.data(); return Card(child: ListTile(leading: const CircleAvatar(backgroundColor: Color(0xffffeadf), child: Icon(Icons.location_city_rounded, color: orange)), title: Text((data['title'] ?? 'Local listing').toString()), subtitle: Text('${data['area'] ?? 'Ranebennur'}${data['price'] == null ? '' : ' · ₹${data['price']}'}'), trailing: TextButton(onPressed: () => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(widget.kannada ? 'ವಿಚಾರಣೆಯನ್ನು ನಮ್ಮ ಮೂಲಕ ಕಳುಹಿಸಲಾಗಿದೆ.' : 'Enquiry sent through Namma Ranebennur.'))), child: Text(widget.kannada ? 'ವಿಚಾರಿಸಿ' : 'Enquire')))); }),
      ]);
    },
  );
}

class MasterFindSprite extends StatelessWidget {
  const MasterFindSprite({super.key, required this.main, required this.index, required this.fallback});
  final String main;
  final int index;
  final String fallback;

  @override
  Widget build(BuildContext context) {
    if (main == 'Property') {
      return sprite('assets/images/find-property.png', columns: 3, rows: 1, spriteIndex: index);
    }
    if (main == 'Events') {
      const masterOrder = [1, 3, 2, 0, 4, 5, 6, 7];
      return sprite('assets/images/find-events-grid.png', columns: 4, rows: 2, spriteIndex: masterOrder[index]);
    }
    return Container(
      color: const Color(0xfff4e8df),
      alignment: Alignment.center,
      child: Text(fallback, style: const TextStyle(fontSize: 34)),
    );
  }

  Widget sprite(String path, {required int columns, required int rows, required int spriteIndex}) => ClipRect(
    child: LayoutBuilder(builder: (_, constraints) {
      final width = constraints.maxWidth;
      final height = constraints.maxHeight;
      final column = spriteIndex % columns;
      final row = spriteIndex ~/ columns;
      return Transform.translate(
        offset: Offset(-width * column, -height * row),
        child: OverflowBox(
          alignment: Alignment.topLeft,
          minWidth: width * columns,
          maxWidth: width * columns,
          minHeight: height * rows,
          maxHeight: height * rows,
          child: Image.asset(path, width: width * columns, height: height * rows, fit: BoxFit.fill),
        ),
      );
    }),
  );
}

class SosTab extends StatelessWidget {
  const SosTab({super.key, required this.kannada});
  final bool kannada;
  @override
  Widget build(BuildContext context) {
    final contacts = <(IconData, String, String)>[
      (Icons.local_police_rounded, kannada ? 'ತುರ್ತು ಸಹಾಯ' : 'Emergency', '112'),
      (Icons.emergency_rounded, kannada ? 'ಆಂಬುಲೆನ್ಸ್' : 'Ambulance', '108'),
      (Icons.local_fire_department_rounded, kannada ? 'ಅಗ್ನಿಶಾಮಕ' : 'Fire', '101'),
      (Icons.woman_rounded, kannada ? 'ಮಹಿಳಾ ಸುರಕ್ಷತೆ' : 'Women Safety', '112'),
      (Icons.child_care_rounded, kannada ? 'ಮಕ್ಕಳ ಸಹಾಯ' : 'Child Help', '1098'),
      (Icons.local_hospital_rounded, kannada ? 'ಹತ್ತಿರದ ಆಸ್ಪತ್ರೆ' : 'Nearby Hospital', ''),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 18, 16, 100), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xffb91c1c), Color(0xffef4444)]), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.sos_rounded, color: Colors.white, size: 55), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kannada ? 'ತುರ್ತು & ಸುರಕ್ಷತೆ' : 'EMERGENCY & SAFETY', style: const TextStyle(color: Colors.white70, fontSize: 10)), Text(kannada ? 'ಪ್ರತಿ ಕ್ಷಣ ಮುಖ್ಯವಾದಾಗ ಸಹಾಯ' : 'Help when every second matters', style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)), Text(kannada ? 'ಅಧಿಕೃತ ಸಹಾಯಕ್ಕೆ ಒಂದು ಟ್ಯಾಪ್.' : 'One-tap access to official help.', style: const TextStyle(color: Colors.white70))]))])),
      const SizedBox(height: 13),
      SizedBox(width: double.infinity, child: FilledButton.icon(style: FilledButton.styleFrom(backgroundColor: const Color(0xffdc2626), padding: const EdgeInsets.all(17)), onPressed: () => confirmCall(context, 'Emergency', '112'), icon: const Icon(Icons.call), label: Text(kannada ? '112 ತುರ್ತು ಕರೆ' : 'CALL 112 EMERGENCY', style: const TextStyle(fontWeight: FontWeight.w800)))),
      const SizedBox(height: 14),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: contacts.length, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, crossAxisSpacing: 9, mainAxisSpacing: 9, childAspectRatio: 1.55), itemBuilder: (_, index) { final item = contacts[index]; return Material(color: Colors.white, borderRadius: BorderRadius.circular(16), child: InkWell(borderRadius: BorderRadius.circular(16), onTap: () => item.$3.isEmpty ? nearbyHospital(context) : confirmCall(context, item.$2, item.$3), child: Padding(padding: const EdgeInsets.all(12), child: Row(children: [Icon(item.$1, color: Colors.red, size: 30), const SizedBox(width: 9), Expanded(child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [Text(item.$2, maxLines: 2, style: const TextStyle(fontWeight: FontWeight.w700)), Text(item.$3.isEmpty ? (kannada ? 'ಈಗ ಹುಡುಕಿ' : 'Find now') : item.$3, style: const TextStyle(color: Colors.red))]))])))); }),
      const SizedBox(height: 14),
      Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(kannada ? '🛡️ ಮಹಿಳೆ & ಹೆಣ್ಣುಮಕ್ಕಳ ಸುರಕ್ಷತೆ' : '🛡️ Women & Girls Safety', style: GoogleFonts.poppins(fontWeight: FontWeight.w800, fontSize: 16)),
        const SizedBox(height: 5), Text(kannada ? 'ಗರಿಷ್ಠ 5 ವಿಶ್ವಾಸಾರ್ಹ ಸಂಪರ್ಕಗಳನ್ನು ಉಳಿಸಿ ಮತ್ತು ಅಗತ್ಯವಿದ್ದಾಗ ಸ್ಥಳ ಹಂಚಿಕೊಳ್ಳಿ.' : 'Save up to five trusted contacts and share your location when help is needed.'), const SizedBox(height: 12),
        Row(children: [Expanded(child: OutlinedButton.icon(onPressed: () => addContact(context), icon: const Icon(Icons.person_add_alt), label: Text(kannada ? 'ಸಂಪರ್ಕ ಸೇರಿಸಿ' : 'Add Contact'))), const SizedBox(width: 8), Expanded(child: OutlinedButton.icon(onPressed: () => shareLocation(context), icon: const Icon(Icons.location_on), label: Text(kannada ? 'ಸ್ಥಳ ಹಂಚಿ' : 'Share Location')))]),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: FirebaseAuth.instance.currentUser == null ? null : FirebaseFirestore.instance.collection('trustedContacts').where('ownerUid', isEqualTo: FirebaseAuth.instance.currentUser!.uid).limit(5).snapshots(),
          builder: (_, snapshot) {
            final saved = snapshot.data?.docs ?? [];
            if (saved.isEmpty) return const SizedBox.shrink();
            return Column(children: [const Divider(height: 24), ...saved.map((doc) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: const Icon(Icons.shield_rounded, color: Colors.green), title: Text((doc.data()['name'] ?? (kannada ? 'ವಿಶ್ವಾಸಾರ್ಹ ಸಂಪರ್ಕ' : 'Trusted contact')).toString()), subtitle: Text((doc.data()['phone'] ?? '').toString()), trailing: IconButton(tooltip: kannada ? 'ಅಳಿಸಿ' : 'Remove', onPressed: () => doc.reference.delete(), icon: const Icon(Icons.close))))]);
          },
        ),
      ])),
      const SizedBox(height: 12), Text(kannada ? 'ನಮ್ಮ ರಾಣೆಬೆಣ್ಣೂರು ಅಧಿಕೃತ ತುರ್ತು ಸೇವೆಗೆ ಪರ್ಯಾಯವಲ್ಲ.' : 'Namma Ranebennur does not replace official emergency services.', textAlign: TextAlign.center, style: const TextStyle(fontSize: 10, color: Colors.black54)),
    ]);
  }

  void confirmCall(BuildContext context, String service, String number) => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(icon: const Icon(Icons.call, color: Colors.red, size: 42), title: Text('$service · $number'), content: Text(kannada ? '$number ಗೆ ಈಗ ಕರೆ ಮಾಡಬೇಕೆ?' : 'Call $number now?'), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: Text(kannada ? 'ರದ್ದು' : 'Cancel')), FilledButton.icon(onPressed: () { Navigator.pop(dialogContext); LinkService.call(number); }, icon: const Icon(Icons.call), label: Text(kannada ? 'ಕರೆ ಮಾಡಿ' : 'Call'))]));
  void nearbyHospital(BuildContext context) => LinkService.mapSearch('Hospitals near me');
  Future<void> shareLocation(BuildContext context) async {
    final message = await LocationShareService.shareSafetyLocation(kannada: kannada);
    if (message != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    }
  }
  Future<void> addContact(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kannada ? 'ಮೊದಲು ಲಾಗಿನ್ ಮಾಡಿ.' : 'Please sign in first.'))); return; }
    final existing = await FirebaseFirestore.instance.collection('trustedContacts').where('ownerUid', isEqualTo: user.uid).limit(5).get();
    if (existing.docs.length >= 5) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(kannada ? 'ಗರಿಷ್ಠ 5 ಸಂಪರ್ಕಗಳನ್ನು ಮಾತ್ರ ಉಳಿಸಬಹುದು.' : 'You can save a maximum of five contacts.'))); return; }
    final name = TextEditingController();
    final phone = TextEditingController();
    if (!context.mounted) return;
    final result = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(title: Text(kannada ? 'ವಿಶ್ವಾಸಾರ್ಹ ಸಂಪರ್ಕ' : 'Trusted contact'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: InputDecoration(labelText: kannada ? 'ಹೆಸರು' : 'Name')), TextField(controller: phone, keyboardType: TextInputType.phone, maxLength: 10, decoration: InputDecoration(labelText: kannada ? 'ಮೊಬೈಲ್ ಸಂಖ್ಯೆ' : 'Mobile number'))]), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(kannada ? 'ರದ್ದು' : 'Cancel')), FilledButton(onPressed: () { if (name.text.trim().isNotEmpty && RegExp(r'^[6-9]\d{9}$').hasMatch(phone.text.trim())) Navigator.pop(dialogContext, true); }, child: Text(kannada ? 'ಉಳಿಸಿ' : 'Save'))]));
    if (result == true) {
      await FirebaseFirestore.instance.collection('trustedContacts').add({'ownerUid': user.uid, 'name': name.text.trim(), 'phone': phone.text.trim(), 'createdAt': FieldValue.serverTimestamp()});
    }
    name.dispose(); phone.dispose();
  }
}

class AnnouncementsTab extends StatefulWidget {
  const AnnouncementsTab({super.key, required this.kannada});
  final bool kannada;
  @override
  State<AnnouncementsTab> createState() => _AnnouncementsTabState();
}

class _AnnouncementsTabState extends State<AnnouncementsTab> {
  String filter = 'All';
  static const filters = ['All', 'HESCOM', 'Municipality', 'Water Board', 'Police', 'Flash News', 'Government'];
  static const kannadaFilters = <String, String>{'All': 'ಎಲ್ಲ', 'Municipality': 'ನಗರಸಭೆ', 'Water Board': 'ನೀರು ಮಂಡಳಿ', 'Police': 'ಪೊಲೀಸ್', 'Flash News': 'ತಾಜಾ ಸುದ್ದಿ', 'Government': 'ಸರ್ಕಾರ'};

  @override
  Widget build(BuildContext context) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('announcements').where('published', isEqualTo: true).snapshots(),
    builder: (_, snapshot) {
      final allDocs = snapshot.data?.docs ?? [];
      final docs = filter == 'All' ? allDocs : allDocs.where((doc) {
        final data = doc.data();
        final needle = filter.toLowerCase().split(' ').first;
        return '${data['source'] ?? ''} ${data['category'] ?? ''}'.toLowerCase().contains(needle);
      }).toList();
      return ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), children: [
        Row(children: [const Text('📢', style: TextStyle(fontSize: 45)), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(widget.kannada ? 'ಪರಿಶೀಲಿತ ಸ್ಥಳೀಯ ಮಾಹಿತಿ' : 'VERIFIED LOCAL INFORMATION', style: const TextStyle(color: orange, fontSize: 10, fontWeight: FontWeight.w800)), Text(widget.kannada ? 'ಪ್ರಕಟಣೆಗಳು' : 'Announcements', style: GoogleFonts.poppins(fontSize: 27, fontWeight: FontWeight.w800)), Text(widget.kannada ? 'ಒಂದೇ ಫೀಡ್. ನಿಮಗೆ ಬೇಕಾದ ಮೂಲದ ಪ್ರಕಾರ ಫಿಲ್ಟರ್ ಮಾಡಿ.' : 'One feed. Filter by the source you need.', style: const TextStyle(color: Colors.black54))]))]),
        const SizedBox(height: 14),
        SingleChildScrollView(scrollDirection: Axis.horizontal, child: Row(children: filters.map((item) => Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(widget.kannada ? kannadaFilters[item] ?? item : item), selected: filter == item, onSelected: (_) => setState(() => filter = item)))).toList())),
        const SizedBox(height: 12),
        if (docs.isEmpty)
          Container(padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 50), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)), child: Column(children: [const Text('✅', style: TextStyle(fontSize: 50)), const SizedBox(height: 10), Text(widget.kannada ? 'ಈಗ ಪರಿಶೀಲಿತ ಪ್ರಕಟಣೆ ಇಲ್ಲ' : 'No verified $filter announcement now', textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text(widget.kannada ? 'ಪರಿಶೀಲನೆಯ ನಂತರ ಅಧಿಕೃತ ಸ್ಥಳೀಯ ಮಾಹಿತಿ ಇಲ್ಲಿ ಕಾಣಿಸುತ್ತದೆ.' : 'Official local updates will appear here after verification.', textAlign: TextAlign.center)]))
        else ...docs.map((doc) { final d = doc.data(); return announcementCard((widget.kannada ? d['titleKn'] ?? d['title'] : d['title'] ?? 'Announcement').toString(), (widget.kannada ? d['bodyKn'] ?? d['body'] : d['body'] ?? '').toString(), (d['category'] ?? 'UPDATE').toString(), (d['source'] ?? 'Namma Ranebennur').toString()); }),
      ]);
    },
  );

  Widget announcementCard(String title, String body, String category, String source) => Card(margin: const EdgeInsets.only(bottom: 10), child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(category, style: const TextStyle(color: orange, fontSize: 10, fontWeight: FontWeight.w900)), const SizedBox(height: 5), Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17)), const SizedBox(height: 5), Text(body), const SizedBox(height: 8), Text('✓ ${widget.kannada ? 'ಪರಿಶೀಲಿತ ಮೂಲ' : 'Verified source'}: $source', style: const TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.w700))])));
}

class NewCityTab extends StatelessWidget {
  const NewCityTab({super.key, required this.kannada});
  final bool kannada;
  @override
  Widget build(BuildContext context) {
    final cards = <(String, String, String)>[
      ('🏷️', kannada ? 'ವ್ಯಾಪಾರ ಆಫರ್‌ಗಳು' : 'Business Offers', kannada ? 'ಪರಿಶೀಲಿಸಿದ ಸ್ಥಳೀಯ ವ್ಯಾಪಾರಗಳ ಹೊಸ ಆಫರ್‌ಗಳು' : 'Fresh offers from verified local businesses'),
      ('🎉', kannada ? 'ಕಾರ್ಯಕ್ರಮಗಳು' : 'Events', kannada ? 'ಕಾರ್ಯಕ್ರಮ, ಜಾತ್ರೆ ಮತ್ತು ಸಂಭ್ರಮಗಳು' : 'Programmes, fairs and celebrations'),
      ('🎀', kannada ? 'ಹೊಸ ಆರಂಭಗಳು' : 'New Openings', kannada ? 'ನಗರದ ಹೊಸ ಅಂಗಡಿ ಮತ್ತು ಸೇವೆಗಳು' : 'New shops and services in the city'),
      ('🎬', kannada ? 'ಹೊಸ ಸಿನಿಮಾಗಳು' : 'New Movies', kannada ? 'ನಗರದಲ್ಲಿ ಬಿಡುಗಡೆಯಾದ ಹೊಸ ಸಿನಿಮಾಗಳು' : 'New movie releases in the city'),
      ('🎂', 'Vibe Town Events', kannada ? 'ಗ್ರಾಹಕರ ಅನುಮತಿಯೊಂದಿಗೆ ಹುಟ್ಟುಹಬ್ಬ, ವಾರ್ಷಿಕೋತ್ಸವ ಮತ್ತು ಸಂಭ್ರಮದ ಶುಭಾಶಯಗಳು' : 'Birthday wishes, anniversaries and celebrations at Vibe Town (with customer permission)'),
    ];
    return ListView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), children: [
      Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xff7c3aed), Color(0xffec4899)]), borderRadius: BorderRadius.circular(20)), child: Row(children: [const Icon(Icons.auto_awesome, color: Colors.white, size: 48), const SizedBox(width: 13), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(kannada ? 'ಇಂದು ಹೊಸದೇನು' : "WHAT'S NEW TODAY", style: const TextStyle(color: Colors.white70, fontSize: 10)), Text(kannada ? 'ನಗರದಲ್ಲಿ ಹೊಸದು' : 'New in City', style: GoogleFonts.poppins(color: Colors.white, fontSize: 23, fontWeight: FontWeight.w800)), Text(kannada ? 'ಆಫರ್‌ಗಳು, ಕಾರ್ಯಕ್ರಮಗಳು, ಹೊಸ ಆರಂಭಗಳು ಮತ್ತು ಸಿನಿಮಾಗಳು.' : 'Offers, events, openings, movies and Vibe Town celebrations.', style: const TextStyle(color: Colors.white70))]))])),
      const SizedBox(height: 15),
      ...cards.map((item) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          child: ListTile(
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${item.$2} ${kannada ? 'ಪರಿಶೀಲನೆಯ ನಂತರ ಇಲ್ಲಿ ತೆರೆಯುತ್ತದೆ' : 'feed opens here after verification'}')),
            ),
            leading: Text(item.$1, style: const TextStyle(fontSize: 30)),
            title: Text(item.$2, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(item.$3),
            trailing: Text(kannada ? 'ನೋಡಿ →' : 'Explore →', style: const TextStyle(color: orange, fontWeight: FontWeight.w700, fontSize: 10)),
          ),
        ),
      )),
    ]);
  }
}
