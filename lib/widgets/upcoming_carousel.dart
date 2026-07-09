import 'package:flutter/cupertino.dart';
import '../models/dashboard_models.dart';

/// Horizontal snap-scrolling carousel of "upcoming" cards. Long-pressing a
/// card uses Flutter's built-in [CupertinoContextMenu] for the native
/// peek-and-pop interaction (scale up + blurred background + quick actions)
/// instead of hand-rolling gesture timers.
class UpcomingCarousel extends StatelessWidget {
  final List<UpcomingCardData> cards;
  final Color accent;
  final Color accentDark;
  final Color accentGlow;
  final void Function(UpcomingCardData card)? onReschedule;
  final void Function(UpcomingCardData card)? onCancel;

  const UpcomingCarousel({
    super.key,
    required this.cards,
    required this.accent,
    required this.accentDark,
    required this.accentGlow,
    this.onReschedule,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final card = cards[i];
          return SizedBox(
            width: MediaQuery.of(context).size.width * 0.72,
            child: CupertinoContextMenu(
              actions: [
                CupertinoContextMenuAction(
                  trailingIcon: CupertinoIcons.calendar,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onReschedule?.call(card);
                  },
                  child: const Text('Reschedule'),
                ),
                CupertinoContextMenuAction(
                  isDestructiveAction: true,
                  trailingIcon: CupertinoIcons.xmark_circle,
                  onPressed: () {
                    Navigator.of(context).pop();
                    onCancel?.call(card);
                  },
                  child: const Text('Cancel'),
                ),
              ],
              child: _UpcomingCard(
                card: card,
                accent: accent,
                accentDark: accentDark,
                accentGlow: accentGlow,
              ),
            ),
          );
        },
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  final UpcomingCardData card;
  final Color accent;
  final Color accentDark;
  final Color accentGlow;

  const _UpcomingCard({
    required this.card,
    required this.accent,
    required this.accentDark,
    required this.accentGlow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0x0F0B1E5B)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0B1E5B),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
          BoxShadow(
            color: Color(0x1F0B1E5B),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: accentGlow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Text(
                  card.tag,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: accentDark,
                  ),
                ),
              ),
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accentGlow,
                  borderRadius: BorderRadius.circular(11),
                ),
                alignment: Alignment.center,
                child: Text(card.icon, style: const TextStyle(fontSize: 15)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            card.title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1E5B),
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            card.subtitle,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF98A2B3),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
