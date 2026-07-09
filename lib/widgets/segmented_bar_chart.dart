import 'package:flutter/cupertino.dart';
import '../models/dashboard_models.dart';

/// Week / Month / Year segmented control (native Cupertino sliding-pill
/// control) paired with an animated bar chart below it that re-grows
/// its bars whenever the selected range changes.
class SegmentedBarChart extends StatefulWidget {
  final String chartLabel;
  final String chartSub;
  final Map<String, ChartDataset> datasets;
  final Color accent;
  final Color accentDark;

  const SegmentedBarChart({
    super.key,
    required this.chartLabel,
    required this.chartSub,
    required this.datasets,
    required this.accent,
    required this.accentDark,
  });

  @override
  State<SegmentedBarChart> createState() => _SegmentedBarChartState();
}

class _SegmentedBarChartState extends State<SegmentedBarChart> {
  String _range = 'week';

  @override
  void didUpdateWidget(covariant SegmentedBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    // reset range when switching to a role/config that doesn't share the same datasets
    if (oldWidget.datasets != widget.datasets) {
      _range = 'week';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dataset = widget.datasets[_range] ?? widget.datasets.values.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text(
            widget.chartLabel,
            style: const TextStyle(
              fontSize: 16.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0B1E5B),
              letterSpacing: -0.3,
            ),
          ),
        ),
        CupertinoSlidingSegmentedControl<String>(
          groupValue: _range,
          backgroundColor: const Color(0xFFE7EAF0),
          thumbColor: CupertinoColors.white,
          padding: const EdgeInsets.all(3),
          children: const {
            'week': Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Week',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
            'month': Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Month',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
            'year': Padding(
              padding: EdgeInsets.symmetric(vertical: 6),
              child: Text(
                'Year',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
          },
          onValueChanged: (v) => setState(() => _range = v ?? 'week'),
        ),
        const SizedBox(height: 14),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
          decoration: BoxDecoration(
            color: CupertinoColors.white,
            borderRadius: BorderRadius.circular(22),
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
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.chartSub,
                    style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF98A2B3),
                    ),
                  ),
                  Text(
                    dataset.total,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0B1E5B),
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 100,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: List.generate(dataset.values.length, (i) {
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _AnimatedBar(
                          heightPct: dataset.values[i],
                          label: dataset.labels[i],
                          accent: widget.accent,
                          accentDark: widget.accentDark,
                          delay: Duration(milliseconds: i * 45),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnimatedBar extends StatefulWidget {
  final double heightPct; // 0-100
  final String label;
  final Color accent;
  final Color accentDark;
  final Duration delay;

  const _AnimatedBar({
    required this.heightPct,
    required this.label,
    required this.accent,
    required this.accentDark,
    required this.delay,
  });

  @override
  State<_AnimatedBar> createState() => _AnimatedBarState();
}

class _AnimatedBarState extends State<_AnimatedBar> {
  double _height = 0;

  @override
  void initState() {
    super.initState();
    Future.delayed(widget.delay, () {
      if (mounted) setState(() => _height = widget.heightPct);
    });
  }

  @override
  void didUpdateWidget(covariant _AnimatedBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.heightPct != widget.heightPct) {
      setState(() => _height = 0);
      Future.delayed(widget.delay, () {
        if (mounted) setState(() => _height = widget.heightPct);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: const Color(0xFFF5F6F9),
                width: double.infinity,
                child: FractionallySizedBox(
                  alignment: Alignment.bottomCenter,
                  heightFactor: _height / 100,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 600),
                    curve: Curves.easeOutCubic,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [widget.accent, widget.accentDark],
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          widget.label,
          style: const TextStyle(
            fontSize: 9.5,
            color: Color(0xFF98A2B3),
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
