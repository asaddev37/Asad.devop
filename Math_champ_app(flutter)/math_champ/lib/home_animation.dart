import 'package:flutter/material.dart';
import 'dart:math';

// Math symbol class, used for light mode animations
class MathSymbol {
  Offset position;
  Offset velocity;
  String symbol;
  double size;
  double opacity;
  double rotation;

  MathSymbol({
    required this.position,
    required this.velocity,
    required this.symbol,
    required this.size,
    required this.opacity,
    required this.rotation,
  });
}

// Bubble class, used for dark mode animations
class Bubble {
  Offset position;
  Offset velocity;
  String symbol;
  double lifetime;

  Bubble({
    required this.position,
    required this.velocity,
    required this.symbol,
    required this.lifetime,
  });
}

// Particle class, used for burst effects
class Particle {
  Offset position;
  Offset velocity;
  String symbol;
  double lifetime;

  Particle({
    required this.position,
    required this.velocity,
    required this.symbol,
    required this.lifetime,
  });
}

// Light mode painter, draws math symbols
class LightModePainter extends CustomPainter {
  final List<MathSymbol> symbols;
  final List<Particle> particles;
  double timer;

  LightModePainter({
    required this.symbols,
    required this.particles,
    required this.timer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();

    // Add new symbols occasionally
    if (timer > 0.3 && random.nextDouble() < 0.3) {
      timer = 0;
      symbols.add(MathSymbol(
        position: Offset(random.nextDouble() * size.width, -30),
        velocity: Offset(
          random.nextDouble() * 1.5 - 0.75,
          random.nextDouble() * 1.2 + 0.8,
        ),
        symbol: ['+', '-', '×', '÷', '=', '1', '2', '3', '4', '5'][random.nextInt(10)],
        size: random.nextDouble() * 12 + 18,
        opacity: random.nextDouble() * 0.6 + 0.2,
        rotation: random.nextDouble() * 0.2 - 0.1,
      ));
    }

    // Draw symbols
    for (var symbol in symbols.toList()) {
      symbol.position += symbol.velocity;

      // Fade out as they reach bottom
      if (symbol.position.dy > size.height * 0.7) {
        symbol.opacity -= 0.005;
      }

      if (symbol.opacity <= 0 || symbol.position.dy > size.height + 50) {
        symbols.remove(symbol);
        continue;
      }

      canvas.save();
      canvas.translate(symbol.position.dx, symbol.position.dy);
      canvas.rotate(symbol.rotation);

      // Draw subtle shadow
      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(symbol.opacity * 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);
      canvas.drawCircle(const Offset(2, 2), symbol.size * 0.4, shadowPaint);

      // Draw symbol
      TextPainter(
        text: TextSpan(
          text: symbol.symbol,
          style: TextStyle(
            fontSize: symbol.size,
            color: _getSymbolColor(symbol.symbol).withOpacity(symbol.opacity),
            fontFamily: 'Comic Sans MS',
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(-symbol.size / 2, -symbol.size / 2));

      canvas.restore();
    }

    // Limit symbols count for clean look
    if (symbols.length > 40) {
      symbols.removeRange(0, symbols.length - 40);
    }
  }

  // Get color for math symbol based on type
  Color _getSymbolColor(String symbol) {
    switch (symbol) {
      case '+':
        return Colors.blue.shade600;
      case '-':
        return Colors.red.shade600;
      case '×':
        return Colors.green.shade600;
      case '÷':
        return Colors.purple.shade600;
      case '=':
        return Colors.orange.shade600;
      default:
        return Colors.pink.shade600; // Numbers
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Bubble painter, draws bubbles for dark mode
class BubblePainter extends CustomPainter {
  final List<Bubble> bubbles;
  final List<Particle> particles;
  double bubblePopTimer;

  BubblePainter({
    required this.bubbles,
    required this.particles,
    required this.bubblePopTimer,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    if (bubblePopTimer > 2 && random.nextDouble() < 0.1) {
      bubblePopTimer = 0;
      bubbles.add(Bubble(
        position: Offset(random.nextDouble() * size.width, size.height + 50),
        velocity: Offset(random.nextDouble() * 2 - 1, -random.nextDouble() * 3 - 1),
        symbol: ['➕', '➖', '✖️', '➗', '1', '2', '3'][random.nextInt(7)],
        lifetime: random.nextDouble() * 5 + 5,
      ));
    }

    // Draw bubbles, ensure opacity is clamped
    for (var bubble in bubbles.toList()) {
      bubble.position += bubble.velocity;
      bubble.lifetime -= 0.02;

      if (bubble.lifetime <= 0 || bubble.position.dy < -50) {
        for (int i = 0; i < 8; i++) {
          particles.add(Particle(
            position: bubble.position,
            velocity: Offset(
              cos(random.nextDouble() * 2 * pi) * 3,
              sin(random.nextDouble() * 2 * pi) * 3,
            ),
            symbol: ['1', '2', '3'][random.nextInt(3)],
            lifetime: 1.0,
          ));
        }
        bubbles.remove(bubble);
        continue;
      }

      // Ensure opacity is clamped between 0.0 and 1.0
      final bubbleOpacity = bubble.lifetime.clamp(0.0, 1.0);

      canvas.save();
      canvas.translate(bubble.position.dx, bubble.position.dy);
      canvas.rotate(sin(bubble.lifetime * pi) * 0.2);

      final bubblePaint = Paint()
        ..color = Colors.teal[800]!.withOpacity(bubbleOpacity * 0.5)
        ..style = PaintingStyle.fill;

      final outlinePaint = Paint()
        ..color = Colors.indigo[900]!.withOpacity(bubbleOpacity * 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      canvas.drawCircle(Offset.zero, 20, bubblePaint);
      canvas.drawCircle(Offset.zero, 20, outlinePaint);

      TextPainter(
        text: TextSpan(
          text: bubble.symbol,
          style: TextStyle(
            fontSize: 25,
            color: Colors.cyan.withOpacity(bubbleOpacity * 0.8),
            fontFamily: 'Comic Sans MS',
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(-12, -12));

      canvas.restore();
    }

    // Draw swirl particles
    for (var particle in particles.toList()) {
      particle.position += particle.velocity;
      particle.lifetime -= 0.02;
      if (particle.lifetime <= 0 ||
          particle.position.dx < 0 ||
          particle.position.dx > size.width ||
          particle.position.dy < 0 ||
          particle.position.dy > size.height) {
        particles.remove(particle);
        continue;
      }
      canvas.save();
      canvas.translate(particle.position.dx, particle.position.dy);
      TextPainter(
        text: TextSpan(
          text: particle.symbol,
          style: TextStyle(
            fontSize: 15 * particle.lifetime,
            color: Colors.cyan.withOpacity(particle.lifetime),
            fontFamily: 'Comic Sans MS',
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(-7, -7));
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// AppBar star painter, adds animated stars to app bar
class AppBarStarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final random = Random();
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;

    for (int i = 0; i < 15; i++) {
      final x = (time * 50 + i * 100) % size.width;
      final y = size.height / 2 + sin(x * 0.05 + time) * 10;

      // Draw glow first
      final glowPaint = Paint()
        ..color = Colors.yellow.withOpacity(0.3)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(Offset(x, y), 8, glowPaint);

      // Then draw the star symbol
      TextPainter(
        text: TextSpan(
          text: ['★', '☆', '✩', '✧', '✦'][random.nextInt(5)],
          style: TextStyle(
            fontSize: 12,
            color: Colors.pink.shade600.withOpacity(0.7),
            fontFamily: 'Comic Sans MS',
          ),
        ),
        textDirection: TextDirection.ltr,
      )
        ..layout()
        ..paint(canvas, Offset(x - 6, y - 6));
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// AppBar bubble painter, adds animated bubbles to app bar
class AppBarBubblePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.teal[800]!.withOpacity(0.3)
      ..style = PaintingStyle.fill;
    final outlinePaint = Paint()
      ..color = Colors.indigo[900]!.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final time = DateTime.now().millisecondsSinceEpoch / 1000.0;
    for (int i = 0; i < 5; i++) {
      final angle = time + i * 2 * pi / 5;
      final x = size.width / 2 + cos(angle) * 30;
      final y = size.height / 2 + sin(angle) * 15;
      canvas.drawCircle(Offset(x, y), 5, paint);
      canvas.drawCircle(Offset(x, y), 5, outlinePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Initialize animations for symbols and bubbles
void initAnimations(BuildContext context, List<MathSymbol> symbols, List<Bubble> bubbles) {
  final random = Random();
  final size = MediaQuery.of(context).size;

  symbols.clear(); // Clear existing symbols
  // Initialize with a smaller number of symbols for cleaner look
  for (int i = 0; i < 25; i++) {
    symbols.add(MathSymbol(
      position: Offset(
        random.nextDouble() * size.width,
        random.nextDouble() * size.height,
      ),
      velocity: Offset(
        random.nextDouble() * 1.5 - 0.75, // Gentle horizontal movement
        random.nextDouble() * 1.2 + 0.8, // Slow downward drift
      ),
      symbol: ['+', '-', '×', '÷', '=', '1', '2', '3', '4', '5'][random.nextInt(10)],
      size: random.nextDouble() * 12 + 18, // Varied sizes
      opacity: random.nextDouble() * 0.6 + 0.2, // Subtle visibility
      rotation: random.nextDouble() * 0.2 - 0.1, // Slight rotation
    ));
  }

  bubbles.clear(); // Clear existing bubbles
  // Bubbles initialization remains the same for dark mode
  for (int i = 0; i < 12; i++) {
    bubbles.add(Bubble(
      position: Offset(random.nextDouble() * size.width, size.height + random.nextDouble() * 100),
      velocity: Offset(random.nextDouble() * 2 - 1, -random.nextDouble() * 3 - 1),
      symbol: ['➕', '➖', '✖️', '➗', '1', '2', '3'][random.nextInt(7)],
      lifetime: random.nextDouble() * 5 + 5, // Random bubble duration
    ));
  }
}

// Add burst effect at specified position, varies by theme
void addBurst(
    Offset position,
    bool isDarkMode,
    List<MathSymbol> symbols,
    List<Bubble> bubbles,
    VoidCallback playSound,
    ) {
  playSound(); // Play burst sound
  final random = Random();
  if (isDarkMode) {
    // Add bubble cluster
    for (int i = 0; i < 8; i++) {
      bubbles.add(Bubble(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 600,
        ),
        velocity: Offset(random.nextDouble() * 2 - 1, -random.nextDouble() * 3 - 1),
        symbol: ['➕', '➖', '✖️', '➗'][random.nextInt(4)],
        lifetime: random.nextDouble() * 3 + 2, // Short-lived bubbles
      ));
    }
  } else {
    // Add symbol cluster for light mode
    for (int i = 0; i < 15; i++) {
      symbols.add(MathSymbol(
        position: Offset(
          random.nextDouble() * 400,
          random.nextDouble() * 600,
        ),
        velocity: Offset(
          random.nextDouble() * 1.5 - 0.75,
          random.nextDouble() * 1.5 + 1,
        ),
        symbol: ['+', '-', '×', '÷', '1', '2', '3', '4', '5'][random.nextInt(9)],
        size: random.nextDouble() * 15 + 20, // Larger symbols
        opacity: random.nextDouble() * 0.7 + 0.3, // More visible
        rotation: random.nextDouble() * 0.3 - 0.15, // Dynamic rotation
      ));
    }
  }
}