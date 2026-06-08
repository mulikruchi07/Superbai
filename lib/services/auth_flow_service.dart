import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/mobile_number_screen.dart';
import 'package:superbai/models/user_profile.dart';
import 'package:superbai/repositories/user_repository.dart';
import 'package:superbai/terms_conditions_screen.dart';
import 'package:superbai/toggle_screen.dart';
import 'package:superbai/user_details_screen.dart';

/// Routes users after splash / phone OTP based on auth + [User] profile state.
class AuthFlowService {
  AuthFlowService({UserRepository? userRepository})
    : _userRepository = userRepository ?? UserRepository();

  final UserRepository _userRepository;

  /// Signed out → login; signed in without profile → setup; else main app.
  Future<Widget> destinationScreen() async {
    final authUser = FirebaseAuth.instance.currentUser;
    if (authUser == null) {
      return const MobileNumberScreen();
    }

    final profile = await _userRepository.getProfileForAuthUser(authUser);
    return _screenForProfile(profile);
  }

  /// After Firebase phone OTP succeeds.
  Future<Widget> screenAfterSignIn(User authUser) async {
    final existing = await _userRepository.getProfileForAuthUser(authUser);
    if (existing != null && existing.shouldSkipProfileSetup) {
      await _userRepository.markOtpVerified(authUser);
      return _screenForProfile(existing);
    }

    await _userRepository.markOtpVerified(authUser);

    final profile = await _userRepository.getProfileForAuthUser(authUser);
    return _screenForProfile(profile);
  }

  Widget _screenForProfile(UserProfile? profile) {
    if (profile == null || !profile.shouldSkipProfileSetup) {
      return const UserDetailsScreen();
    }
    if (!profile.hasAcceptedTerms) {
      return const TermsConditionsScreen();
    }
    return const DashboardScreen();
  }

  void navigateReplace(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}

/// After address / profile details are saved.
Widget screenAfterProfileDetails() => const TermsConditionsScreen();

/// Post–terms acceptance screen (maid question).
Widget postProfileSetupScreen() => const ToggleScreen();
