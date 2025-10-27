import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';

class DailyPlan {
  const DailyPlan({
    required this.id,
    required this.ownerId,
    required this.title,
  });

  final String id;
  final String ownerId;
  final String title;
}

class AuthorizationException implements Exception {
  const AuthorizationException(this.message);

  final String message;

  @override
  String toString() => 'AuthorizationException($message)';
}

abstract class DailyPlanRepository {
  Future<List<DailyPlan>> fetchDailyPlans();

  Future<List<DailyPlan>> fetchDailyPlansForOwner(
    String ownerId, {
    required String actingUserId,
  });

  Future<DailyPlan> createDailyPlan({
    required String title,
    required String ownerId,
  });
}

final currentUserIdProvider = Provider<String>((ref) {
  throw UnimplementedError('currentUserIdProvider must be overridden in tests.');
});

final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  throw UnimplementedError('dailyPlanRepositoryProvider must be overridden in tests.');
});

final unauthorizedErrorProvider = StateProvider<String?>((ref) => null);
final creationStatusProvider = StateProvider<String?>((ref) => null);

final userScopedDailyPlansProvider = FutureProvider<List<DailyPlan>>((ref) async {
  final repository = ref.watch(dailyPlanRepositoryProvider);
  final userId = ref.watch(currentUserIdProvider);
  final plans = await repository.fetchDailyPlans();
  return plans.where((plan) => plan.ownerId == userId).toList();
});

class DailyPlanCreationController {
  DailyPlanCreationController({
    required DailyPlanRepository repository,
    required String currentUserId,
  })  : _repository = repository,
        _currentUserId = currentUserId;

  final DailyPlanRepository _repository;
  final String _currentUserId;

  Future<DailyPlan> createPlan({
    required String title,
    String? overrideOwnerId,
  }) async {
    if (overrideOwnerId != null && overrideOwnerId != _currentUserId) {
      throw const AuthorizationException('user_id is enforced by RLS');
    }

    return _repository.createDailyPlan(
      title: title,
      ownerId: _currentUserId,
    );
  }
}

final dailyPlanCreationControllerProvider = Provider<DailyPlanCreationController>((ref) {
  final repository = ref.watch(dailyPlanRepositoryProvider);
  final currentUserId = ref.watch(currentUserIdProvider);
  return DailyPlanCreationController(
    repository: repository,
    currentUserId: currentUserId,
  );
});

class DailyPlanRlsHarness extends ConsumerWidget {
  const DailyPlanRlsHarness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(userScopedDailyPlansProvider);
    final errorMessage = ref.watch(unauthorizedErrorProvider);
    final creationStatus = ref.watch(creationStatusProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Daily Plans')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  errorMessage,
                  key: const Key('error_message'),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            if (creationStatus != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  creationStatus,
                  key: const Key('creation_status'),
                ),
              ),
            Expanded(
              child: plansAsync.when(
                data: (plans) {
                  if (plans.isEmpty) {
                    return const Center(child: Text('No plans available'));
                  }

                  return ListView(
                    children: [
                      for (final plan in plans)
                        ListTile(
                          title: Text(plan.title),
                          subtitle: Text('owner: ${plan.ownerId}'),
                        ),
                    ],
                  );
                },
                loading: () => const Center(child: Text('Loading...')),
                error: (error, _) => Center(child: Text('Error: $error')),
              ),
            ),
            OverflowBar(
              alignment: MainAxisAlignment.start,
              spacing: 8,
              overflowSpacing: 8,
              children: [
                ElevatedButton(
                  key: const Key('unauthorized_button'),
                  onPressed: () async {
                    final repository = ref.read(dailyPlanRepositoryProvider);
                    final userId = ref.read(currentUserIdProvider);

                    try {
                      await repository.fetchDailyPlansForOwner(
                        'other-user',
                        actingUserId: userId,
                      );
                      ref.read(unauthorizedErrorProvider.notifier).state = null;
                    } on AuthorizationException catch (e) {
                      ref.read(unauthorizedErrorProvider.notifier).state =
                          'Access denied: ${e.message}';
                    }
                  },
                  child: const Text('Try Access Other User Data'),
                ),
                ElevatedButton(
                  key: const Key('create_plan_button'),
                  onPressed: () async {
                    final controller = ref.read(dailyPlanCreationControllerProvider);

                    try {
                      final plan = await controller.createPlan(title: 'Morning Routine');
                      ref.read(creationStatusProvider.notifier).state =
                          'Created plan for ${plan.ownerId}';
                    } on AuthorizationException catch (e) {
                      ref.read(creationStatusProvider.notifier).state =
                          'Creation blocked: ${e.message}';
                    }
                  },
                  child: const Text('Create Plan'),
                ),
                ElevatedButton(
                  key: const Key('create_override_button'),
                  onPressed: () async {
                    final controller = ref.read(dailyPlanCreationControllerProvider);

                    try {
                      final plan = await controller.createPlan(
                        title: 'Override Attempt',
                        overrideOwnerId: 'malicious-user',
                      );
                      ref.read(creationStatusProvider.notifier).state =
                          'Created plan for ${plan.ownerId}';
                    } on AuthorizationException catch (e) {
                      ref.read(creationStatusProvider.notifier).state =
                          'Creation blocked: ${e.message}';
                    }
                  },
                  child: const Text('Create Plan With Override'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class MockDailyPlanRepository extends Mock implements DailyPlanRepository {}

Future<void> pumpHarness(
  WidgetTester tester, {
  required DailyPlanRepository repository,
  required String userId,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        currentUserIdProvider.overrideWithValue(userId),
        dailyPlanRepositoryProvider.overrideWithValue(repository),
      ],
      child: const DailyPlanRlsHarness(),
    ),
  );
}

void main() {
  const userId = 'user-123';

  group('Daily Plan RLS Widget Tests', () {
    late MockDailyPlanRepository repository;

    setUp(() {
      repository = MockDailyPlanRepository();
    });

    testWidgets('shows only items owned by the authenticated user', (tester) async {
      when(() => repository.fetchDailyPlans()).thenAnswer(
        (invocation) async => [
          const DailyPlan(id: 'plan-1', ownerId: userId, title: 'Morning Meditation'),
          const DailyPlan(id: 'plan-2', ownerId: 'someone-else', title: 'Other User Plan'),
        ],
      );

      when(
        () => repository.fetchDailyPlansForOwner(
          any(),
          actingUserId: any(named: 'actingUserId'),
        ),
      ).thenThrow(const AuthorizationException('RLS policy enforced'));

      when(
        () => repository.createDailyPlan(
          title: any(named: 'title'),
          ownerId: any(named: 'ownerId'),
        ),
      ).thenAnswer((invocation) async {
        final title = invocation.namedArguments[#title] as String;
        final owner = invocation.namedArguments[#ownerId] as String;
        return DailyPlan(id: 'created-$title', ownerId: owner, title: title);
      });

      await pumpHarness(tester, repository: repository, userId: userId);

      expect(find.text('Loading...'), findsOneWidget);

      await tester.pump();

      expect(find.text('Morning Meditation'), findsOneWidget);
      expect(find.text('owner: $userId'), findsOneWidget);
      expect(find.text('Other User Plan'), findsNothing);
      expect(find.text('No plans available'), findsNothing);

      verify(() => repository.fetchDailyPlans()).called(1);
    });

    testWidgets(
      'does not render plans when repository only returns other owners',
      (tester) async {
        when(() => repository.fetchDailyPlans()).thenAnswer(
          (invocation) async => [
            const DailyPlan(id: 'plan-3', ownerId: 'other-1', title: 'Other User Plan'),
          ],
        );

        when(
          () => repository.fetchDailyPlansForOwner(
            any(),
            actingUserId: any(named: 'actingUserId'),
          ),
        ).thenThrow(const AuthorizationException('RLS policy enforced'));

        when(
          () => repository.createDailyPlan(
            title: any(named: 'title'),
            ownerId: any(named: 'ownerId'),
          ),
        ).thenAnswer((invocation) async {
          final title = invocation.namedArguments[#title] as String;
          final owner = invocation.namedArguments[#ownerId] as String;
          return DailyPlan(id: 'created-$title', ownerId: owner, title: title);
        });

        await pumpHarness(tester, repository: repository, userId: userId);

        expect(find.text('Loading...'), findsOneWidget);

        await tester.pump();

        expect(find.text('No plans available'), findsOneWidget);
        expect(find.text('Other User Plan'), findsNothing);

        verify(() => repository.fetchDailyPlans()).called(1);
      },
    );

    testWidgets('surfaces authorization errors on cross-user access', (tester) async {
      when(() => repository.fetchDailyPlans()).thenAnswer(
        (invocation) async => [
          const DailyPlan(id: 'plan-1', ownerId: userId, title: 'Morning Meditation'),
        ],
      );

      when(
        () => repository.fetchDailyPlansForOwner(
          'other-user',
          actingUserId: userId,
        ),
      ).thenThrow(const AuthorizationException('RLS policy enforced'));

      when(
        () => repository.createDailyPlan(
          title: any(named: 'title'),
          ownerId: any(named: 'ownerId'),
        ),
      ).thenAnswer((invocation) async {
        final title = invocation.namedArguments[#title] as String;
        final owner = invocation.namedArguments[#ownerId] as String;
        return DailyPlan(id: 'created-$title', ownerId: owner, title: title);
      });

      await pumpHarness(tester, repository: repository, userId: userId);
      await tester.pump();

      await tester.tap(find.byKey(const Key('unauthorized_button')));
      await tester.pump();

      expect(find.byKey(const Key('error_message')), findsOneWidget);
      expect(find.text('Access denied: RLS policy enforced'), findsOneWidget);
      expect(find.text('Morning Meditation'), findsOneWidget);
      expect(find.text('Other User Plan'), findsNothing);

      verify(() => repository.fetchDailyPlans()).called(1);
      verify(
        () => repository.fetchDailyPlansForOwner(
          'other-user',
          actingUserId: userId,
        ),
      ).called(1);
    });

    testWidgets('auto-populates user_id and rejects manual overrides', (tester) async {
      when(() => repository.fetchDailyPlans()).thenAnswer(
        (invocation) async => const <DailyPlan>[],
      );

      when(
        () => repository.fetchDailyPlansForOwner(
          any(),
          actingUserId: any(named: 'actingUserId'),
        ),
      ).thenThrow(const AuthorizationException('RLS policy enforced'));

      when(
        () => repository.createDailyPlan(
          title: any(named: 'title'),
          ownerId: any(named: 'ownerId'),
        ),
      ).thenAnswer((invocation) async {
        final title = invocation.namedArguments[#title] as String;
        final owner = invocation.namedArguments[#ownerId] as String;
        return DailyPlan(id: 'created-$title', ownerId: owner, title: title);
      });

      await pumpHarness(tester, repository: repository, userId: userId);

      await tester.pump();

      await tester.tap(find.byKey(const Key('create_plan_button')));
      await tester.pump();

      expect(find.text('Created plan for $userId'), findsOneWidget);
      verify(
        () => repository.createDailyPlan(
          title: 'Morning Routine',
          ownerId: userId,
        ),
      ).called(1);

      await tester.tap(find.byKey(const Key('create_override_button')));
      await tester.pump();

      expect(
        find.text('Creation blocked: user_id is enforced by RLS'),
        findsOneWidget,
      );

      verifyNever(
        () => repository.createDailyPlan(
          title: 'Override Attempt',
          ownerId: any(named: 'ownerId'),
        ),
      );
    });
  });
}
