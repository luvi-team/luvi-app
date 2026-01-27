/// Dashboard, Cycle, and Profile routes (post-auth protected).
library;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:luvi_app/core/navigation/route_names.dart';
import 'package:luvi_app/core/navigation/route_paths.dart';
import 'package:luvi_app/features/cycle/screens/cycle_overview_stub.dart';
import 'package:luvi_app/features/dashboard/screens/heute_screen.dart';
import 'package:luvi_app/features/dashboard/screens/trainings_overview_stub.dart';
import 'package:luvi_app/features/dashboard/screens/workout_detail_stub.dart';
import 'package:luvi_app/features/profile/screens/profile_stub_screen.dart';
import 'package:luvi_app/l10n/app_localizations.dart';
import 'package:luvi_app/router/route_builders/route_guards.dart';

/// Builds dashboard routes (post-auth protected).
///
/// IMPORTANT: New routes need redirect: postAuthGuard AND must be added
/// to kPostAuthPaths in lib/core/navigation/routes.dart.
List<RouteBase> buildDashboardRoutes() {
  return [
    // Dashboard (Heute)
    GoRoute(
      path: RoutePaths.heute,
      name: RouteNames.heute,
      redirect: postAuthGuard,
      builder: (context, state) => const HeuteScreen(),
    ),
    GoRoute(
      path: RoutePaths.workoutDetail,
      name: RouteNames.workoutDetail,
      redirect: postAuthGuard,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        if (id == null || id.isEmpty) {
          return Scaffold(
            body: Center(
              child: Text(AppLocalizations.of(context)!.errorInvalidWorkoutId),
            ),
          );
        }
        return WorkoutDetailStubScreen(workoutId: id);
      },
    ),
    GoRoute(
      path: RoutePaths.trainingsOverview,
      name: RouteNames.trainingsOverview,
      redirect: postAuthGuard,
      builder: (context, state) => const TrainingsOverviewStubScreen(),
    ),

    // Cycle
    GoRoute(
      path: RoutePaths.cycleOverview,
      name: RouteNames.cycleOverview,
      redirect: postAuthGuard,
      builder: (context, state) => const CycleOverviewStubScreen(),
    ),

    // Profile
    GoRoute(
      path: RoutePaths.profile,
      name: RouteNames.profile,
      redirect: postAuthGuard,
      builder: (context, state) => const ProfileStubScreen(),
    ),
  ];
}
