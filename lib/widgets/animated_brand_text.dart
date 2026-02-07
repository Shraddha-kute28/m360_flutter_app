import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedBrandText extends StatefulWidget {
  const AnimatedBrandText({super.key});

  @override
  State<AnimatedBrandText> createState() => _AnimatedBrandTextState();
}

class _AnimatedBrandTextState extends State<AnimatedBrandText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.25),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Text(
          "Maintenance 360",
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}
