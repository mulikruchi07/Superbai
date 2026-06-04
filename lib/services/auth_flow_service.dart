import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:superbai/dashboard_screen.dart';
import 'package:superbai/mobile_number_screen.dart';
import 'package:superbai/repositories/user_repository.dart';
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
    if (profile != null && profile.shouldSkipProfileSetup) {
      return const DashboardScreen();
    }
    return const UserDetailsScreen();
  }

  /// After Firebase phone OTP succeeds.
  Future<Widget> screenAfterSignIn(User authUser) async {
    final existing = await _userRepository.getProfileForAuthUser(authUser);
    if (existing != null && existing.shouldSkipProfileSetup) {
      await _userRepository.markOtpVerified(authUser);
      return const DashboardScreen();
    }

    await _userRepository.markOtpVerified(authUser);

    final profile = await _userRepository.getProfileForAuthUser(authUser);
    if (profile != null && profile.shouldSkipProfileSetup) {
      return const DashboardScreen();
    }
    return const UserDetailsScreen();
  }

  void navigateReplace(BuildContext context, Widget screen) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => screen),
      (route) => false,
    );
  }
}

/// Post–profile-setup screen (maid question).
Widget postProfileSetupScreen() => const ToggleScreen();
