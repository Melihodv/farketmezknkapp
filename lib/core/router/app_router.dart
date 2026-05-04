import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/recommendation/recommendation_screen.dart';
import '../../features/feedback/feedback_screen.dart';
import '../../features/memory/memory_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/profile/privacy_policy_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/recommendation',
      builder: (context, state) => const RecommendationScreen(),
    ),
    GoRoute(
      path: '/feedback',
      builder: (context, state) => const FeedbackScreen(),
    ),
    GoRoute(
      path: '/memory',
      builder: (context, state) => const MemoryScreen(),
    ),
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);
