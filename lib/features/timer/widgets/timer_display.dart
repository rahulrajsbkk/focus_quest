import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:focus_quest/models/focus_session.dart';

class TimerDisplay extends StatelessWidget {
  const TimerDisplay({
    required this.session,
    required this.isRunning,
    required this.isPaused,
    required this.focusDuration,
    required this.sessionColor,
    required this.pulseController,
    this.isPowerSaving = false,
    super.key,
  });

  final FocusSession? session;
  final bool isRunning;
  final bool isPaused;
  final Duration focusDuration;
  final Color sessionColor;
  final AnimationController pulseController;
  final bool isPowerSaving;

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayDuration = session?.remainingDuration ?? focusDuration;
    final progress = session?.progress ?? 0.0;

    return AnimatedBuilder(
      animation: pulseController,
      builder: (context, child) {
        final pulseScale = isRunning
            ? 1.0 + (pulseController.value * 0.02)
            : isPaused
            ? 1.0 + (pulseController.value * 0.01)
            : 1.0;

        return Transform.scale(
          scale: pulseScale,
          child: SizedBox(
            width: 280,
            height: 280,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPowerSaving
                        ? Colors.black
                        : theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: sessionColor.withValues(
                          alpha: isRunning ? 0.3 : 0.1,
                        ),
                        blurRadius: isRunning ? 30 : 15,
                        spreadRadius: isRunning ? 5 : 0,
                      ),
                    ],
                  ),
                ),

                // Progress ring
                SizedBox(
                  width: 240,
                  height: 240,
                  child: CustomPaint(
                    painter: CircularProgressPainter(
                      progress: progress,
                      color: sessionColor,
                      backgroundColor: isPowerSaving
                          ? Colors.transparent
                          : theme.colorScheme.onSurface.withValues(alpha: 0.1),
                      strokeWidth: 8,
                    ),
                  ),
                ),

                // Time display
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatDuration(displayDuration),
                      style: theme.textTheme.displayLarge?.copyWith(
                        fontWeight: FontWeight.w300,
                        fontSize: 64,
                        letterSpacing: 2,
                        color: sessionColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (session != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: sessionColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          isPaused ? 'PAUSED' : 'RUNNING',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: sessionColor,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class CircularProgressPainter extends CustomPainter {
  CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final Color backgroundColor;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // Start from top
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
