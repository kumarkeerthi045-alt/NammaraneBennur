import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

typedef DemoItem = ({String emoji, String title, String flow});

class DemoModeScreen extends StatefulWidget {
  const DemoModeScreen({super.key});
  @override
  State<DemoModeScreen> createState() => _DemoModeScreenState();
}

class _DemoModeScreenState extends State<DemoModeScreen> {
  static const sections = <String, List<DemoItem>>{
    'Booking': [
      (emoji: '🏨', title: 'Hotel', flow: 'Choose hotel → room/photos/rate → date → pending admin check → advance → confirmed'),
      (emoji: '🎭', title: 'Vibe Town', flow: 'Choose package → date → live slot → guests/add-ons → booking reference'),
      (emoji: '🎊', title: 'Function Hall', flow: 'Choose hall/photos/rate → occasion/date/guests → admin availability → advance'),
      (emoji: '🩺', title: 'Clinic', flow: 'Choose doctor → patient details → reception slot → booking'),
      (emoji: '🛺', title: 'Travel', flow: 'Pickup/destination map → passenger or goods → vehicle → Now/Later → driver match'),
      (emoji: '🔧', title: 'Home Services', flow: 'Choose worker by picture → problem details → date/time → protected request'),
      (emoji: '🛵', title: 'Nimma Sevaka', flow: 'Parcel or Purchase for Me → map distance → weight/size → automatic charge'),
      (emoji: '🚜', title: 'Machinery', flow: 'Choose machine → work details → quotation request'),
    ],
    'Find For Me': [
      (emoji: '🏠', title: 'Property', flow: 'House · Land · Commercial Space/Shop; To-Let · Sell · Lease'),
      (emoji: '👷', title: 'Workers', flow: 'Electrician · Plumber · Carpenter · Maid · Painter · Civil · Mechanic · AC/Fridge'),
      (emoji: '🛒', title: 'Market', flow: 'Groceries · Vehicles · Electronics · Furniture · Appliances · Fashion · Tools · General'),
      (emoji: '🎪', title: 'Event Accessories', flow: 'DJ · Catering · Tent · Decoration · Lighting · Photo/Video · Stage · Chairs/Tables'),
      (emoji: '📍', title: 'Location', flow: 'Near me · Landmarks · Hospitals · Government Offices · Transport'),
    ],
    'Profile & Partner': [
      (emoji: '👤', title: 'My Profile', flow: 'Bookings · wallet · ads · requirements · plans'),
      (emoji: '🚖', title: 'Partner Service', flow: 'Auto, cab, delivery and worker registration with photo and document verification'),
      (emoji: '📢', title: 'Post Advertisement', flow: 'Customer submits → admin review → price/payment → publish'),
      (emoji: '💼', title: 'Do Business With Us', flow: 'Choose profession → dynamic experience/rate fields → verification'),
    ],
    'Admin Control': [
      (emoji: '✅', title: 'Approvals', flow: 'Verify drivers, delivery boys, workers and booking counters'),
      (emoji: '📅', title: 'Bookings', flow: 'Confirm availability, request advance, confirm or decline'),
      (emoji: '📣', title: 'Ads & Content', flow: 'Review advertisements and publish announcements'),
      (emoji: '🛡️', title: 'Safety', flow: 'Complaints, protected contact and operational controls'),
    ],
  };
  static const steps = ['Option opened', 'Details entered', 'Availability checked', 'Admin/partner notified', 'Demo confirmation shown'];
  String section = 'Booking';
  DemoItem selected = sections['Booking']!.first;
  int step = 0;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xfffffaf5),
    appBar: AppBar(title: const Text('Namma Ranebennur Demo Mode'), actions: [Container(margin: const EdgeInsets.only(right: 12), padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xffffeadf), borderRadius: BorderRadius.circular(20)), child: const Center(child: Text('DEMO ONLY', style: TextStyle(color: Color(0xfff45b22), fontSize: 9, fontWeight: FontWeight.w900))))]),
    body: ListView(padding: const EdgeInsets.fromLTRB(14, 12, 14, 30), children: [
      const Text('SAFE TEST AREA', style: TextStyle(color: Color(0xfff45b22), fontWeight: FontWeight.w900, fontSize: 10)),
      Text('Check every option without creating a real booking, payment or provider request.', style: GoogleFonts.poppins(fontSize: 12)),
      const SizedBox(height: 12),
      Wrap(spacing: 7, runSpacing: 7, children: sections.keys.map((name) => ChoiceChip(label: Text(name), selected: section == name, onSelected: (_) => setState(() { section = name; selected = sections[name]!.first; step = 0; }))).toList()),
      const SizedBox(height: 12),
      ...sections[section]!.map((item) => Card(child: ListTile(onTap: () => setState(() { selected = item; step = 0; }), selected: selected.title == item.title, leading: Text(item.emoji, style: const TextStyle(fontSize: 28)), title: Text(item.title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: const Text('Tap to test'), trailing: const Icon(Icons.chevron_right)))),
      const SizedBox(height: 10),
      Card(color: const Color(0xff30251f), child: Padding(padding: const EdgeInsets.all(17), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(selected.emoji, style: const TextStyle(fontSize: 48)),
        Text('${section.toUpperCase()} · DEMONSTRATION', style: const TextStyle(color: Color(0xffffa36d), fontSize: 9, fontWeight: FontWeight.w900)),
        Text(selected.title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
        Text(selected.flow, style: const TextStyle(color: Colors.white70)),
        const SizedBox(height: 14),
        ...List.generate(steps.length, (i) => ListTile(dense: true, contentPadding: EdgeInsets.zero, leading: CircleAvatar(radius: 14, backgroundColor: i <= step ? const Color(0xfff45b22) : Colors.white24, child: Text(i < step ? '✓' : '${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11))), title: Text(steps[i], style: TextStyle(color: Colors.white, fontWeight: i == step ? FontWeight.w800 : FontWeight.normal)))),
        const SizedBox(height: 8),
        SizedBox(width: double.infinity, child: FilledButton(onPressed: step == steps.length - 1 ? null : () => setState(() => step++), child: Text(step == steps.length - 1 ? '✓ Demo completed' : 'Continue demo →'))),
        SizedBox(width: double.infinity, child: TextButton(onPressed: () => setState(() => step = 0), child: const Text('Restart this option'))),
        const Text('No real request is sent. This page is only for checking menus and flow.', style: TextStyle(color: Colors.amber, fontSize: 10)),
      ]))),
    ]),
  );
}
