import 'package:flutter/material.dart';
import 'package:superbai/theme.dart';
import 'package:superbai/mobile_number_screen.dart'; // Navigate to MobileNumberScreen

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Animation for the "SUPER BA" text sliding from right
  late AnimationController _textSlideController;
  late Animation<Offset> _textSlideAnimation;

  // Re-added: Animation for the "strike" effect on the text (zoom in/out)
  late AnimationController _textStrikeController;
  late Animation<double> _textStrikeAnimation;

  // Animation for the logo popping/zooming to regular size
  late AnimationController _logoPopController;
  late Animation<double> _logoPopAnimation;

  // Animation for the logo "strike" effect
  late AnimationController _logoStrikeController;
  late Animation<double> _logoStrikeAnimation;

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
    _textSlideAnimation =
        Tween<Offset>(
          begin: const Offset(1.0, 0.0), // Start from right (off-screen)
          end: Offset
              .zero, // End at its natural position (relative to its parent)
        ).animate(
          CurvedAnimation(parent: _textSlideController, curve: Curves.easeOut),
        );

    // Re-added: Text "Strike" Animation (zoom in/out pulse)
    _textStrikeController = AnimationController(
      duration: const Duration(
        milliseconds: 300,
      ), // Duration for the zoom in/out strike
      vsync: this,
    );
    _textStrikeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.0, end: 1.1), // Zoom in
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.1, end: 1.0), // Zoom out
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _textStrikeController,
            curve: Curves.easeInOut,
          ),
        );

    // 3. Logo Pop/Zoom Animation (from 0 to regular size)
    _logoPopController = AnimationController(
      duration: const Duration(
        milliseconds: 1000,
      ), // Increased duration for a more noticeable zoom from 0
      vsync: this,
    );
    _logoPopAnimation =
        Tween<double>(
          begin: 0.0, // Start from zero size (pop in)
          end: 1.0, // Zoom to its normal size
        ).animate(
          CurvedAnimation(
            parent: _logoPopController,
            curve: Curves.elasticOut, // A bouncy elastic effect for "pop"
          ),
        );

    // Logo "Strike" Animation (more pronounced and smoother pulse)
    _logoStrikeController = AnimationController(
      duration: const Duration(
        milliseconds: 300,
      ), // Increased duration for smoother pulse
      vsync: this,
    );
    _logoStrikeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(
            tween: Tween<double>(
              begin: 1.0,
              end: 1.2,
            ), // Increased zoom-in for more striking effect
            weight: 50,
          ),
          TweenSequenceItem(
            tween: Tween<double>(begin: 1.2, end: 1.0), // Increased zoom-out
            weight: 50,
          ),
        ]).animate(
          CurvedAnimation(
            parent: _logoStrikeController,
            curve: Curves.easeInOut,
          ),
        );

    // 4. Final Logo Zoom Out Animation (to cover screen)
    _logoZoomOutController = AnimationController(
      duration: const Duration(milliseconds: 800), // Fast zoom out
      vsync: this,
    );
    _logoZoomOutAnimation =
        Tween<double>(
          begin: 1.0, // Start from normal size
          end:
              700.0, // Increased to ensure it covers the entire screen more aggressively
        ).animate(
          CurvedAnimation(
            parent: _logoZoomOutController,
            curve: Curves.easeInQuad, // Accelerate towards the end
          ),
        );

    _playAnimationSequence();
  }

  Future<void> _playAnimationSequence() async {
    // Initial delay before animations start
    await Future.delayed(const Duration(milliseconds: 500));

    // 1. Slide Text from Right to Middle
    await _textSlideController.forward();

    // Play "Strike" effect (zoom in/out) on text
    _textStrikeController.forward().then(
      (_) => _textStrikeController.reverse(),
    );
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Small delay after text strike completes

    // Delay between text and logo appearance
    await Future.delayed(const Duration(milliseconds: 300));

    // 3. Logo Pop (from 0 to regular size)
    await _logoPopController
        .forward(); // Logo pops from middle and zooms from 0 to regular size

    // Added a small delay to ensure the pop animation is visually complete before strike
    await Future.delayed(const Duration(milliseconds: 100));

    // Play "Strike" effect on logo immediately after it pops
    _logoStrikeController.forward().then(
      (_) => _logoStrikeController.reverse(),
    );
    await Future.delayed(
      const Duration(milliseconds: 300),
    ); // Small delay after logo strike completes

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
        MaterialPageRoute(builder: (context) => const MobileNumberScreen()),
      );
    }
  }

  @override
  void dispose() {
    _textSlideController.dispose();
    _textStrikeController.dispose(); // Dispose text strike controller
    _logoPopController.dispose();
    _logoStrikeController.dispose();
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
                  // Logo (initial pop, strike and then final zoom)
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoPopAnimation,
                      _logoStrikeAnimation,
                      _logoZoomOutAnimation,
                    ]),
                    builder: (context, child) {
                      double currentScale = _logoPopAnimation.value;
                      // Apply strike animation scale
                      if (_logoStrikeController.isAnimating ||
                          _logoStrikeController.isCompleted) {
                        currentScale *= _logoStrikeAnimation.value;
                      }

                      // If the zoom-out animation has started or completed, use its scale value
                      if (_logoZoomOutController.isAnimating ||
                          _logoZoomOutController.isCompleted) {
                        currentScale = _logoZoomOutAnimation.value;
                      }
                      return Transform.scale(
                        scale: currentScale,
                        alignment: Alignment.center,
                        child: Image.asset(
                          'assets/logo.png', // Your diamond logo image
                          width: 150, // Increased initial width
                          height: 150, // Increased initial height
                          fit: BoxFit
                              .contain, // Ensures the entire logo is visible and not cut off
                          filterQuality: FilterQuality
                              .high, // Added filterQuality for clarity
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.error_outline,
                              size: 150, // Adjusted size for error icon
                              color: Colors.red,
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20), // Space between logo and text
                  // Text (slides from right and has zoom in/out strike effect)
                  // This will be hidden by animating its opacity down to 0
                  // when the logo starts its full screen zoom.
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoZoomOutController,
                      _textSlideAnimation,
                      _textStrikeAnimation, // Listen to the text zoom in/out strike animation
                    ]),
                    builder: (context, child) {
                      // Hide the text when the zoom-out animation begins
                      // Adjust threshold if needed for a smoother disappear
                      final opacity = _logoZoomOutController.value > 0.0
                          ? 0.0
                          : 1.0;
                      return Opacity(
                        opacity: opacity,
                        child: SlideTransition(
                          position:
                              _textSlideAnimation, // Initial slide from right
                          child: ScaleTransition(
                            // Replaced SlideTransition with ScaleTransition for text strike
                            scale:
                                _textStrikeAnimation, // Apply zoom in/out strike
                            child: Image.asset(
                              'assets/superbai_text.PNG', // Your "SUPER BA" text image
                              width: 800,
                              height: 50,
                              filterQuality: FilterQuality
                                  .high, // Ensure text image also has high quality
                              errorBuilder: (context, error, stackTrace) {
                                return Text(
                                  '',
                                  style: AppTextStyles.heading1.copyWith(
                                    color: AppColors.primaryLightPurple,
                                  ),
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
