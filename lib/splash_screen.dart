import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/mobile_number_screen.dart'; // Navigate to MobileNumberScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  // Animation for the "SUPER BA" text sliding from right
  late AnimationController _textSlideController;
  late Animation<Offset> _textSlideAnimation;

  // Animation for the "strike" effect on the text
  late AnimationController _textStrikeController;
  late Animation<double> _textStrikeAnimation;

  // Animation for the logo popping/zooming to regular size
  late AnimationController _logoPopController;
  late Animation<double> _logoPopAnimation;

  // Animation for the final full-screen zoom of the logo
  late AnimationController _logoZoomOutController;
  late Animation<double> _logoZoomOutAnimation;

  @override
  void initState() {
    super.initState();

    // 1. Text Slide Animation (from right to middle)
    _textSlideController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0), // Start from right (off-screen)
      end: Offset.zero, // End at its natural position (middle)
    ).animate(CurvedAnimation(
      parent: _textSlideController,
      curve: Curves.easeOut,
    ));

    // 2. Text "Strike" Animation (quick scale pulse)
    _textStrikeController = AnimationController(
      duration: const Duration(milliseconds: 200), // Quick pulse duration
      vsync: this,
    );
    _textStrikeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.1), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.1, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _textStrikeController,
      curve: Curves.easeInOut,
    ));

    // 3. Logo Pop/Zoom Animation (to regular size)
    _logoPopController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _logoPopAnimation = Tween<double>(
      begin: 0.0, // Start from zero size (pop in)
      end: 1.0, // Zoom to its normal size
    ).animate(CurvedAnimation(
      parent: _logoPopController,
      curve: Curves.elasticOut, // A bouncy elastic effect for "pop"
    ));

    // 4. Final Logo Zoom Out Animation (to cover screen)
    _logoZoomOutController = AnimationController(
      duration: const Duration(milliseconds: 800), // Fast zoom out
      vsync: this,
    );
    _logoZoomOutAnimation = Tween<double>(
      begin: 1.0, // Start from normal size
      end: 300.0, // Increased to ensure it covers the entire screen more aggressively
    ).animate(CurvedAnimation(
      parent: _logoZoomOutController,
      curve: Curves.easeInQuad, // Accelerate towards the end
    ));

    _playAnimationSequence();
  }

  Future<void> _playAnimationSequence() async {
    // Initial delay before animations start
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Slide Text from Right to Middle
    await _textSlideController.forward();

    // 2. Play "Strike" effect on text
    _textStrikeController.forward().then((_) => _textStrikeController.reverse());
    await Future.delayed(const Duration(milliseconds: 300)); // Small delay after strike completes

    // 3. Logo Pop (after text is in place and strike animation starts/completes)
    await _logoPopController.forward(); // Logo pops from middle and zooms to regular size

    // 4. Wait for 2 seconds with the fully popped logo
    await Future.delayed(const Duration(seconds: 2));

    // 5. Logo zooms completely, covering the entire screen
    // This also implicitly hides the text as it expands over it.
    await _logoZoomOutController.forward();

    // 6. Wait for another 2 seconds after the logo covers the screen
    await Future.delayed(const Duration(seconds: 2));

    // 7. Navigate to Mobile Number Page
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MobileNumberScreen(),
        ),
      );
    }
  }

  @override
  void dispose() {
    _textSlideController.dispose();
    _textStrikeController.dispose();
    _logoPopController.dispose();
    _logoZoomOutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.neutralWhite, // Initial background
      body: Stack(
        children: [
          // This ensures the logo is always on top when zooming,
          // covering the text effectively.
          Positioned.fill(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo (initial pop and then final zoom)
                  AnimatedBuilder(
                    animation: Listenable.merge([_logoPopAnimation, _logoZoomOutAnimation]),
                    builder: (context, child) {
                      double currentScale = _logoPopAnimation.value;
                      // If the zoom-out animation has started or completed, use its scale value
                      if (_logoZoomOutController.isAnimating || _logoZoomOutController.isCompleted) {
                        currentScale = _logoZoomOutAnimation.value;
                      }
                      return Transform.scale(
                        scale: currentScale,
                        // Align the transform to the center to allow the skirt's purple to cover the screen.
                        // Experiment with Alignment(0.0, 0.1) or similar if pure center isn't enough.
                        alignment: Alignment.center, // Changed to center
                        child: Image.asset(
                          'assets/logo.png', // Your diamond logo image
                          // Initial size, will be scaled up by animations
                          width: 150,
                          height: 150,
                          // BoxFit.cover ensures the image fills its new scaled bounds,
                          // making it cover the entire screen when scaled very large.
                          fit: BoxFit.cover,
                          // Use high filter quality for potentially better scaling
                          filterQuality: FilterQuality.high, // Added filterQuality
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error_outline, size: 150, color: Colors.red);
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  // Text (slides from right and has strike effect)
                  // This will be hidden by animating its opacity down to 0
                  // when the logo starts its full screen zoom.
                  AnimatedBuilder(
                    animation: _logoZoomOutController,
                    builder: (context, child) {
                      // Hide the text when the zoom-out animation begins
                      // Adjust threshold if needed for a smoother disappear
                      final opacity = _logoZoomOutController.value > 0.0 ? 0.0 : 1.0;
                      return Opacity(
                        opacity: opacity,
                        child: SlideTransition(
                          position: _textSlideAnimation,
                          child: ScaleTransition(
                            scale: _textStrikeAnimation,
                            child: Image.asset(
                              'assets/superbai_text.png', // Your "SUPER BA" text image
                              width: 200,
                              height: 50,
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  '',
                                  style: AppTextStyles.heading1.copyWith(color: AppColors.primaryLightPurple),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
