import 'package:flutter/cupertino.dart';
import 'data/role_configs.dart';
import 'screens/role_dashboard_screen.dart';

void main() => runApp(const ZoovanaApp());

class ZoovanaApp extends StatelessWidget {
  const ZoovanaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const CupertinoApp(
      debugShowCheckedModeBanner: false,
      theme: CupertinoThemeData(primaryColor: Color(0xFF3B82F6)),
      home: RoleSwitcherDemo(),
    );
  }
}

/// Demo scaffold only — in your real app, `role` comes from the logged-in
/// user's account type instead of a switcher.
class RoleSwitcherDemo extends StatefulWidget {
  const RoleSwitcherDemo({super.key});

  @override
  State<RoleSwitcherDemo> createState() => _RoleSwitcherDemoState();
}

class _RoleSwitcherDemoState extends State<RoleSwitcherDemo> {
  String _role = 'owner';

  @override
  Widget build(BuildContext context) {
    final config = roleConfigs[_role]!;
    return CupertinoPageScaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      navigationBar: CupertinoNavigationBar(
        middle: CupertinoSlidingSegmentedControl<String>(
          groupValue: _role,
          padding: const EdgeInsets.all(3),
          children: const {
            'owner': Text('Owner', style: TextStyle(fontSize: 11)),
            'volunteer': Text('Volunteer', style: TextStyle(fontSize: 11)),
            'shelter': Text('Shelter', style: TextStyle(fontSize: 11)),
            'shop': Text('Shop', style: TextStyle(fontSize: 11)),
            'provider': Text('Provider', style: TextStyle(fontSize: 11)),
          },
          onValueChanged: (v) => setState(() => _role = v ?? 'owner'),
        ),
      ),
      child: RoleDashboardScreen(config: config),
    );
  }
}
