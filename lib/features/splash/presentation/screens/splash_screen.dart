import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/config/app_colors.dart';
import '../../../../routes/app_routes.dart';

// ═══════════════════════════════════════════════════════════════
//  ZOOVANA CMS — PREMIUM SPLASH SCREEN
//  Colors: AppColors palette (Royal Blue + Teal + Navy)
//  Transition: cinematic fade-dissolve into home screen
// ═══════════════════════════════════════════════════════════════

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {

  // ── Controllers ──────────────────────────────────────────────
  late final AnimationController _stageCtrl;   // entrance sequence
  late final AnimationController _loopCtrl;    // ambient loops
  late final AnimationController _progressCtrl; // loading bar
  late final AnimationController _exitCtrl;    // exit dissolve

  // ── Stage animations ─────────────────────────────────────────
  late final Animation<double> _logoOpacity;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotate;
  late final Animation<double> _textOpacity;
  late final Animation<Offset> _textSlide;
  late final Animation<double> _ruleScale;
  late final Animation<double> _tagsOpacity;
  late final Animation<double> _loaderOpacity;
  late final Animation<double> _bottomOpacity;

  // ── Loop animations ──────────────────────────────────────────
  late final Animation<double> _breathe;

  // ── Exit animations ──────────────────────────────────────────
  late final Animation<double> _exitFade;   // content fades out
  late final Animation<double> _veilOpacity; // white veil fades in

  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _stageCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _loopCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    );

    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _buildStageAnimations();
    _buildLoopAnimations();
    _buildExitAnimations();

    _stageCtrl.forward();

    // Start progress bar slightly after entrance
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) {
        _progressCtrl.forward().then((_) {
          // Dwell for 200ms so the bar visibly completes before exit
          Future.delayed(const Duration(milliseconds: 200), _triggerExit);
        });
      }
    });
  }

  // ── Animation builders ───────────────────────────────────────

  Animation<double> _interval(double s, double e, Curve c) =>
      Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _stageCtrl, curve: Interval(s, e, curve: c)),
      );

  void _buildStageAnimations() {
    _logoOpacity = _interval(0.0, 0.28, Curves.easeOut);
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.0, 0.40, curve: Curves.elasticOut),
      ),
    );
    _logoRotate = Tween<double>(begin: -(math.pi / 2), end: 0.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.0, 0.36, curve: Curves.easeOutCubic),
      ),
    );
    _textOpacity = _interval(0.28, 0.62, Curves.easeOut);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.30),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _stageCtrl,
      curve: const Interval(0.28, 0.62, curve: Curves.easeOutCubic),
    ));
    _ruleScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _stageCtrl,
        curve: const Interval(0.40, 0.66, curve: Curves.easeOut),
      ),
    );
    _tagsOpacity = _interval(0.50, 0.78, Curves.easeOut);
    _loaderOpacity = _interval(0.65, 0.90, Curves.easeOut);
    _bottomOpacity = _interval(0.75, 1.00, Curves.easeOut);
  }

  void _buildLoopAnimations() {
    _breathe = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _loopCtrl, curve: Curves.easeInOut),
    );
  }

  void _buildExitAnimations() {
    // Content fades out in first 50% of exit
    _exitFade = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );
    // White veil fades in from 30% to 100%
    _veilOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _exitCtrl,
        curve: const Interval(0.30, 1.0, curve: Curves.easeInOut),
      ),
    );
  }

  // ── Exit sequence ────────────────────────────────────────────

  void _triggerExit() {
    if (!mounted || _navigated) return;
    // Run the exit dissolve, then let GoRouter's redirect logic decide
    // the destination (home if authenticated, login if not).
    // We navigate to /home — the redirect guard will intercept and send
    // to /login if the user is unauthenticated. Either way the splash
    // has finished its own animation before handing off.
    _exitCtrl.forward().then((_) {
      if (!mounted || _navigated) return;
      _navigated = true;
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      // Use replace so splash is removed from the stack entirely
      context.go(AppRoutes.home);
    });
  }

  @override
  void dispose() {
    _stageCtrl.dispose();
    _loopCtrl.dispose();
    _progressCtrl.dispose();
    _exitCtrl.dispose();
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      _loopCtrl.stop();
    } else if (state == AppLifecycleState.resumed) {
      _loopCtrl.repeat();
    }
  }

  // ── Build ────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDarkMode;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedBuilder(
        animation: Listenable.merge([_exitFade, _veilOpacity]),
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              // ── Main content (fades out on exit) ──
              Opacity(
                opacity: _exitFade.value.clamp(0.0, 1.0),
                child: child,
              ),
              // ── Exit veil — matches home screen bg for seamless dissolve ──
              if (_exitCtrl.value > 0)
                Opacity(
                  opacity: _veilOpacity.value.clamp(0.0, 1.0),
                  child: Container(color: AppColors.background),
                ),
            ],
          );
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Layer 0: gradient background
            _buildBackground(isDark),
            // Layer 1: ambient dust
            _DustLayer(isDark: isDark),
            // Layer 2: background rings
            AnimatedBuilder(
              animation: Listenable.merge([_loopCtrl, _breathe]),
              builder: (context, _) => CustomPaint(
                painter: _BgRingsPainter(
                  loopValue: _loopCtrl.value,
                  breathe: _breathe.value,
                  isDark: isDark,
                ),
              ),
            ),
            // Layer 3: main content
            _buildContent(),
            // Layer 4: bottom bar
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0.0, -0.25),
          radius: 1.3,
          colors: isDark
              ? [
                  AppColors.secondary.withValues(alpha: 0.55),
                  AppColors.background,
                  AppColors.backgroundAlt,
                ]
              : [
                  AppColors.primaryGlow.withValues(alpha: 0.6),
                  AppColors.background,
                  AppColors.backgroundAlt,
                ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
    );
  }

  // ── Content column ───────────────────────────────────────────

  Widget _buildContent() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo
          AnimatedBuilder(
            animation: Listenable.merge([_logoScale, _logoOpacity, _logoRotate]),
            builder: (_, __) => Opacity(
              opacity: _logoOpacity.value.clamp(0.0, 1.0),
              child: Transform.rotate(
                angle: _logoRotate.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: _LogoMark(loopCtrl: _loopCtrl),
                ),
              ),
            ),
          ),

          const SizedBox(height: 52),

          // Brand name + tagline
          FadeTransition(
            opacity: _textOpacity,
            child: SlideTransition(
              position: _textSlide,
              child: _buildBrandName(),
            ),
          ),

          const SizedBox(height: 20),

          // Divider rule
          AnimatedBuilder(
            animation: _ruleScale,
            builder: (_, __) => Transform.scale(
              scaleX: _ruleScale.value,
              child: Container(
                width: 32,
                height: 1,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.0),
                      AppColors.primary.withValues(alpha: 0.5),
                      AppColors.accent.withValues(alpha: 0.5),
                      AppColors.primary.withValues(alpha: 0.0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
            ),
          ),

          const SizedBox(height: 18),

          // Tagline
          FadeTransition(
            opacity: _textOpacity,
            child: SlideTransition(
              position: _textSlide,
              child: Text(
                'PET CARE MANAGEMENT',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 3.5,
                  color: AppColors.textSecondary.withValues(alpha: 0.75),
                ),
              ),
            ),
          ),

          const SizedBox(height: 28),

          // Audience tags
          FadeTransition(
            opacity: _tagsOpacity,
            child: _buildTags(),
          ),

          const SizedBox(height: 72),

          // Progress loader
          FadeTransition(
            opacity: _loaderOpacity,
            child: _buildLoader(),
          ),
        ],
      ),
    );
  }

  Widget _buildBrandName() {
    // Soft shadow gives the thin serif letters depth without harsh edges
    final softShadow = [
      Shadow(
        color: AppColors.primary.withValues(alpha: 0.12),
        blurRadius: 12,
        offset: const Offset(0, 2),
      ),
      Shadow(
        color: AppColors.textPrimary.withValues(alpha: 0.06),
        blurRadius: 24,
        offset: const Offset(0, 4),
      ),
    ];

    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: GoogleFonts.cormorantGaramond(
          fontSize: 52,
          fontWeight: FontWeight.w400,
          letterSpacing: 8,
          color: AppColors.textPrimary,
          height: 1.0,
          shadows: softShadow,
        ),
        children: [
          const TextSpan(text: 'ZOOV'),
          TextSpan(
            text: 'A',
            style: TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w500,
              shadows: [
                Shadow(
                  color: AppColors.primary.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const TextSpan(text: 'NA'),
        ],
      ),
    );
  }

  Widget _buildTags() {
    const labels = ['PET SHOPS', 'VETS', 'GROOMING'];
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: labels.asMap().entries.map((e) {
        return Padding(
          padding: EdgeInsets.only(left: e.key == 0 ? 0 : 8),
          child: _TagPill(label: e.value, isAccent: e.key == 1),
        );
      }).toList(),
    );
  }

  Widget _buildLoader() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Progress bar — uses LayoutBuilder so FractionallySizedBox
        // always has a concrete parent width to work against
        SizedBox(
          width: 120,
          height: 2,
          child: AnimatedBuilder(
            animation: _progressCtrl,
            builder: (_, __) {
              return Stack(
                children: [
                  // Track
                  Container(
                    width: double.infinity,
                    height: 2,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Fill
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return Container(
                        width: constraints.maxWidth * _progressCtrl.value,
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [AppColors.primary, AppColors.accent],
                          ),
                          borderRadius: BorderRadius.circular(2),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.4),
                              blurRadius: 6,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        _PulsingText(
          text: 'INITIALISING',
          style: GoogleFonts.dmSans(
            fontSize: 9,
            fontWeight: FontWeight.w400,
            letterSpacing: 3.0,
            color: AppColors.textTertiary,
          ),
          loopCtrl: _loopCtrl,
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _bottomOpacity,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 28),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _dot(),
              const SizedBox(width: 12),
              Text(
                'CMS  v2.0',
                style: GoogleFonts.dmSans(
                  fontSize: 9,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 2.5,
                  color: AppColors.textTertiary,
                ),
              ),
              const SizedBox(width: 12),
              _dot(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _dot() => Container(
        width: 3,
        height: 3,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.accent.withValues(alpha: 0.55),
        ),
      );
}

// ═══════════════════════════════════════════════════════════════
// LOGO MARK
// ═══════════════════════════════════════════════════════════════

class _LogoMark extends StatelessWidget {
  final AnimationController loopCtrl;
  const _LogoMark({required this.loopCtrl});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        // Outer glow halo
        Container(
          width: 148,
          height: 148,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppColors.primary.withValues(alpha: 0.14),
                Colors.transparent,
              ],
            ),
          ),
        ),

        // Outer slowly rotating ring with traveling dot
        AnimatedBuilder(
          animation: loopCtrl,
          builder: (_, __) => Transform.rotate(
            angle: loopCtrl.value * math.pi * 2,
            child: SizedBox(
              width: 122,
              height: 122,
              child: CustomPaint(
                painter: _OrbitRingPainter(
                  ringColor: AppColors.primary.withValues(alpha: 0.18),
                  dotColor: AppColors.accent,
                  strokeWidth: 1,
                ),
              ),
            ),
          ),
        ),

        // Inner counter-rotating dashed ring
        AnimatedBuilder(
          animation: loopCtrl,
          builder: (_, __) => Transform.rotate(
            angle: -(loopCtrl.value * math.pi * 2 * 0.65),
            child: CustomPaint(
              size: const Size(94, 94),
              painter: _DashedCirclePainter(
                color: AppColors.primaryLight.withValues(alpha: 0.20),
                dashCount: 24,
                strokeWidth: 0.8,
              ),
            ),
          ),
        ),

        // Logo circle with real logo.png
        Container(
          width: 92,
          height: 92,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.isDarkMode
                ? AppColors.secondaryLight.withValues(alpha: 0.85)
                : AppColors.surface,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.18),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.22),
                blurRadius: 28,
                spreadRadius: 2,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
              ),
            ),
          ),
        ),

        // Pulsing accent dot — top-right
        Positioned(
          top: 6,
          right: 4,
          child: _GoldDot(color: AppColors.accent),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// REUSABLE WIDGETS
// ═══════════════════════════════════════════════════════════════

class _TagPill extends StatelessWidget {
  final String label;
  final bool isAccent;
  const _TagPill({required this.label, required this.isAccent});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isAccent
              ? AppColors.accent.withValues(alpha: 0.55)
              : AppColors.border,
          width: 1,
        ),
        color: isAccent
            ? AppColors.accent.withValues(alpha: 0.08)
            : Colors.transparent,
      ),
      child: Text(
        label,
        style: GoogleFonts.dmSans(
          fontSize: 9,
          fontWeight: FontWeight.w400,
          letterSpacing: 2.5,
          color: isAccent ? AppColors.accent : AppColors.textSecondary,
        ),
      ),
    );
  }
}

class _PulsingText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final AnimationController loopCtrl;
  const _PulsingText({
    required this.text,
    required this.style,
    required this.loopCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: loopCtrl,
      builder: (_, __) {
        final pulse =
            (math.sin(loopCtrl.value * math.pi * 2) * 0.35 + 0.65)
                .clamp(0.3, 1.0);
        return Opacity(opacity: pulse, child: Text(text, style: style));
      },
    );
  }
}

class _GoldDot extends StatefulWidget {
  final Color color;
  const _GoldDot({required this.color});

  @override
  State<_GoldDot> createState() => _GoldDotState();
}

class _GoldDotState extends State<_GoldDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
    _s = Tween<double>(begin: 1.0, end: 1.65).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _s,
      builder: (_, __) => Transform.scale(
        scale: _s.value,
        child: Container(
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: widget.color,
            boxShadow: [
              BoxShadow(
                color: widget.color.withValues(alpha: 0.5),
                blurRadius: 6,
                spreadRadius: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// FLOATING DUST PARTICLES
// ═══════════════════════════════════════════════════════════════

class _DustLayer extends StatefulWidget {
  final bool isDark;
  const _DustLayer({required this.isDark});

  @override
  State<_DustLayer> createState() => _DustLayerState();
}

class _DustLayerState extends State<_DustLayer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final List<_Dust> _pts;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 60),
    )..repeat();
    _pts = List.generate(22, _Dust.new);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (ctx, _) => CustomPaint(
        painter: _DustPainter(t: _c.value, pts: _pts, isDark: widget.isDark),
        size: MediaQuery.sizeOf(ctx),
      ),
    );
  }
}

class _Dust {
  final double bx, by, speed, r, opacity, off, drift;
  final bool isAccent;
  _Dust(int s)
      : bx = _rd(s, 1),
        by = _rd(s, 2),
        speed = 0.006 + _rd(s, 3) * 0.015,
        r = 0.7 + _rd(s, 4) * 1.5,
        opacity = 0.06 + _rd(s, 5) * 0.12,
        off = _rd(s, 6),
        drift = 8 + _rd(s, 7) * 18,
        isAccent = _rd(s, 8) > 0.82;

  static double _rd(int s, int m) =>
      math.Random(s * m + m * 97).nextDouble();
}

class _DustPainter extends CustomPainter {
  final double t;
  final List<_Dust> pts;
  final bool isDark;
  _DustPainter({required this.t, required this.pts, required this.isDark});

  @override
  void paint(Canvas canvas, Size sz) {
    for (final p in pts) {
      final phase = (t * p.speed * 12 + p.off) % 1.0;
      final x = p.bx * sz.width + math.sin(phase * math.pi * 2) * p.drift;
      final y = (p.by + phase * p.speed * 20) % 1.0 * sz.height;
      final pulse = math.sin(phase * math.pi) * 0.5 + 0.5;
      final op = p.opacity * pulse;
      final col = p.isAccent
          ? AppColors.accent.withValues(alpha: op)
          : AppColors.primary.withValues(alpha: op * 0.5);
      canvas.drawCircle(Offset(x, y), p.r, Paint()..color = col);
    }
  }

  @override
  bool shouldRepaint(covariant _DustPainter old) => old.t != t;
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTERS
// ═══════════════════════════════════════════════════════════════

class _BgRingsPainter extends CustomPainter {
  final double loopValue;
  final double breathe;
  final bool isDark;
  _BgRingsPainter({
    required this.loopValue,
    required this.breathe,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size sz) {
    final cx = sz.width / 2;
    final cy = sz.height / 2;

    final radii = [sz.width * 0.66, sz.width * 0.49, sz.width * 0.32];
    final alphas = [0.04, 0.055, 0.035];
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.5;

    for (int i = 0; i < radii.length; i++) {
      paint.color = AppColors.primary.withValues(alpha: alphas[i]);
      canvas.drawCircle(
        Offset(cx, cy),
        radii[i] * (i == 1 ? breathe : 1.0),
        paint,
      );
    }

    // Accent dashed ring
    _drawDashed(
      canvas,
      Offset(cx, cy),
      sz.width * 0.49 * breathe,
      AppColors.accent.withValues(alpha: 0.07),
      0.6,
      48,
    );

    // Subtle crosshair
    paint
      ..color = AppColors.primary.withValues(alpha: 0.03)
      ..strokeWidth = 0.5;
    canvas.drawLine(Offset(cx, 0), Offset(cx, sz.height), paint);
    canvas.drawLine(Offset(0, cy), Offset(sz.width, cy), paint);
  }

  void _drawDashed(
      Canvas canvas, Offset c, double r, Color col, double sw, int count) {
    final p = Paint()
      ..color = col
      ..strokeWidth = sw
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final step = (math.pi * 2) / count;
    const len = 0.07;
    for (int i = 0; i < count; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: c, radius: r),
        i * step,
        len,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BgRingsPainter old) =>
      old.breathe != breathe || old.loopValue != loopValue;
}

class _OrbitRingPainter extends CustomPainter {
  final Color ringColor;
  final Color dotColor;
  final double strokeWidth;
  const _OrbitRingPainter({
    required this.ringColor,
    required this.dotColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size sz) {
    final cx = sz.width / 2;
    final cy = sz.height / 2;
    final r = sz.width / 2 - strokeWidth;

    canvas.drawCircle(
      Offset(cx, cy),
      r,
      Paint()
        ..color = ringColor
        ..strokeWidth = strokeWidth
        ..style = PaintingStyle.stroke,
    );

    // Traveling dot at top (rotation handled by parent Transform)
    canvas.drawCircle(
      Offset(cx, cy - r),
      3,
      Paint()
        ..color = dotColor
        ..style = PaintingStyle.fill,
    );
    // Glow around dot
    canvas.drawCircle(
      Offset(cx, cy - r),
      6,
      Paint()
        ..color = dotColor.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double strokeWidth;
  const _DashedCirclePainter({
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size sz) {
    final cx = sz.width / 2;
    final cy = sz.height / 2;
    final r = sz.width / 2 - strokeWidth;
    final p = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final step = (math.pi * 2) / dashCount;
    const len = 0.09;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        i * step,
        len,
        false,
        p,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter _) => false;
}

