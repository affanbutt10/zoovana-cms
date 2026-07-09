import 'package:flutter/cupertino.dart';
import '../models/dashboard_models.dart';

/// A "+" FAB that expands into a vertical stack of labeled mini actions
/// with a staggered spring entrance, and rotates into an "x" when open.
/// Re-skin by passing a new [accent]/[accentDark] and [actions] list.
class SpeedDialFab extends StatefulWidget {
  final List<FabActionData> actions;
  final Color accent;
  final Color accentDark;

  const SpeedDialFab({super.key, required this.actions, required this.accent, required this.accentDark});

  @override
  State<SpeedDialFab> createState() => _SpeedDialFabState();
}

class _SpeedDialFabState extends State<SpeedDialFab> with SingleTickerProviderStateMixin {
  bool _open = false;

  void _toggle() => setState(() => _open = !_open);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      clipBehavior: Clip.none,
      children: [
        // dimmed backdrop, tapping it closes the dial
        if (_open)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggle,
              child: AnimatedOpacity(
                opacity: _open ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: Container(color: const Color(0x260B1E5B)),
              ),
            ),
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // mini actions, reversed so the first config item ends up closest to the FAB
            for (var i = widget.actions.length - 1; i >= 0; i--) ...[
              _MiniAction(
                data: widget.actions[i],
                visible: _open,
                delayMs: i * 30,
                onTap: () {
                  _toggle();
                  widget.actions[i].onTap?.call();
                },
              ),
              const SizedBox(height: 12),
            ],
            GestureDetector(
              onTap: _toggle,
              child: AnimatedRotation(
                turns: _open ? 0.125 : 0, // 45°
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [widget.accent, widget.accentDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                    boxShadow: [BoxShadow(color: widget.accentDark.withOpacity(0.45), blurRadius: 20, offset: const Offset(0, 8))],
                  ),
                  child: const Icon(CupertinoIcons.add, color: CupertinoColors.white, size: 26),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MiniAction extends StatelessWidget {
  final FabActionData data;
  final bool visible;
  final int delayMs;
  final VoidCallback onTap;

  const _MiniAction({required this.data, required this.visible, required this.delayMs, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: visible ? Offset.zero : const Offset(0, 0.3),
      duration: Duration(milliseconds: 220 + delayMs),
      curve: Curves.easeOutBack,
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: Duration(milliseconds: 180 + delayMs),
        child: IgnorePointer(
          ignoring: !visible,
          child: GestureDetector(
            onTap: onTap,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                  decoration: BoxDecoration(color: const Color(0xFF0B1E5B), borderRadius: BorderRadius.circular(100)),
                  child: Text(data.label, style: const TextStyle(color: CupertinoColors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    color: CupertinoColors.white,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Color(0x400B1E5B), blurRadius: 16, offset: Offset(0, 6))],
                  ),
                  child: Icon(data.icon, size: 18, color: const Color(0xFF0B1E5B)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
