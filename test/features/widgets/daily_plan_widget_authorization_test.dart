import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/legacy.dart';
import '../../support/test_config.dart';

class DailyPlan {
  const DailyPlan({
    required this.id,
    required this.ownerId,
    required this.title,
  });

  final String id;
  final String ownerId;
  final String title;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    return other is DailyPlan &&
        other.id == id &&
        other.ownerId == ownerId &&
        other.title == title;
  }

  @override
  int get hashCode => Object.hash(id, ownerId, title);

  @override
  String toString() => 'DailyPlan(id: $id, ownerId: $ownerId, title: $title)';
}

class AuthorizationException implements Exception {
  const AuthorizationException(this.message);

  final String message;

  @override
  String toString() => 'AuthorizationException($message)';
}

abstract class DailyPlanRepository {
  Future<List<DailyPlan>> fetchMyDailyPlans();

  Future<DailyPlan> createDailyPlan({required String title});
}

final dailyPlanRepositoryProvider = Provider<DailyPlanRepository>((ref) {
  throw UnimplementedError(
    'dailyPlanRepositoryProvider must be overridden in tests.',
  );
});

final creationStatusProvider =
    StateProvider.autoDispose<String?>((ref) => null);

final userScopedDailyPlansProvider =
    FutureProvider.autoDispose<List<DailyPlan>>((ref) async {
      final repository = ref.watch(dailyPlanRepositoryProvider);
      return repository.fetchMyDailyPlans();
    });

class DailyPlanCreationController {
  DailyPlanCreationController({required DailyPlanRepository repository})
    : _repository = repository;

  final DailyPlanRepository _repository;

  Future<DailyPlan> createPlan({required String title}) {
    return _repository.createDailyPlan(title: title);
  }
}

final dailyPlanCreationControllerProvider =
    Provider.autoDispose<DailyPlanCreationController>((ref) {
      final repository = ref.watch(dailyPlanRepositoryProvider);
      return DailyPlanCreationController(repository: repository);
    });

class DailyPlanAuthorizationHarness extends ConsumerWidget {
  const DailyPlanAuthorizationHarness({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(userScopedDailyPlansProvider);
    final creationStatus = ref.watch(creationStatusProvider);

    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Daily Plans')),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (creationStatus != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text(
                  creationStatus,
                  key: const Key('creation_status'),
                  style: const TextStyle(color: Colors.black87),
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
                error: (error, _) => Center(
                  child: Text('Error: $error', key: const Key('error_message')),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                key: const Key('create_plan_button'),
                onPressed: () async {
                  final controller = ref.read(
                    dailyPlanCreationControllerProvider,
                  );
                  final statusNotifier = ref.read(
                    creationStatusProvider.notifier,
                  );
                  var statusMessage = 'Creation failed';

                  try {
                    final plan = await controller.createPlan(
                      title: 'Morning Routine',
                    );
                    statusMessage = 'Created plan for ${plan.ownerId}';
                  } on AuthorizationException catch (e) {
                    statusMessage = 'Creation blocked: ${e.message}';
                  } on Exception catch (error) {
                    statusMessage = 'Creation failed: $error';
                  } finally {
                    statusNotifier.state = statusMessage;
                  }
                },
                child: const Text('Create Plan'),
              ),
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
  AsyncValue<List<DailyPlan>>? plansOverride,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        dailyPlanRepositoryProvider.overrideWithValue(repository),
        if (plansOverride != null)
          userScopedDailyPlansProvider.overrideWithValue(plansOverride),
      ],
      child: const DailyPlanAuthorizationHarness(),
    ),
  );
}

void main() {
  const userId = 'user-123';

  TestConfig.setup();

  group('Daily Plan Authorization Widget Tests', () {
    late MockDailyPlanRepository repository;

    setUp(() {
      repository = MockDailyPlanRepository();
    });

    testWidgets('renders plans scoped to the authenticated user', (
      tester,
    ) async {
      when(repository.fetchMyDailyPlans).thenAnswer(
        (invocation) async => [
          const DailyPlan(
            id: 'plan-1',
            ownerId: userId,
            title: 'Morning Meditation',
          ),
        ],
      );

      await pumpHarness(tester, repository: repository);

      expect(find.text('Loading...'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('Morning Meditation'), findsOneWidget);
      expect(find.text('owner: $userId'), findsOneWidget);
      expect(find.text('No plans available'), findsNothing);

      verify(repository.fetchMyDailyPlans).called(1);
    });

    testWidgets('renders empty state when repository returns no plans', (
      tester,
    ) async {
      when(
        repository.fetchMyDailyPlans,
      ).thenAnswer((invocation) async => const <DailyPlan>[]);

      await pumpHarness(tester, repository: repository);

      expect(find.text('Loading...'), findsOneWidget);

      await tester.pumpAndSettle();

      expect(find.text('No plans available'), findsOneWidget);

      verify(repository.fetchMyDailyPlans).called(1);
    });

    testWidgets('surfaces authorization errors from repository', (
      tester,
    ) async {
      await pumpHarness(
        tester,
        repository: repository,
        plansOverride: const AsyncValue.error(
          AuthorizationException('RLS policy enforced'),
          StackTrace.empty,
        ),
      );
      await tester.pumpAndSettle();

      final finder = find.byKey(const Key('error_message'));
      expect(finder, findsOneWidget);

      final txt = tester.widget<Text>(finder);
      expect(
        txt.data,
        contains('Error: AuthorizationException(RLS policy enforced)'),
      );
    });

    testWidgets('create plan button calls repository without owner override', (
      tester,
    ) async {
      when(
        repository.fetchMyDailyPlans,
      ).thenAnswer((invocation) async => const <DailyPlan>[]);

      when(
        () => repository.createDailyPlan(
          title: any(named: 'title'),
        ),
      ).thenAnswer((invocation) async {
        final title = invocation.namedArguments[#title] as String;
        return DailyPlan(id: 'created-$title', ownerId: userId, title: title);
      });

      await pumpHarness(tester, repository: repository);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('create_plan_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Created plan for $userId'), findsOneWidget);

      verify(
        () => repository.createDailyPlan(title: 'Morning Routine'),
      ).called(1);
    });

    testWidgets('creation errors surface in status banner', (tester) async {
      when(
        repository.fetchMyDailyPlans,
      ).thenAnswer((invocation) async => const <DailyPlan>[]);

      when(
        () => repository.createDailyPlan(title: any(named: 'title')),
      ).thenThrow(const AuthorizationException('RLS policy enforced'));

      await pumpHarness(tester, repository: repository);
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key('create_plan_button')));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(
        find.text('Creation blocked: RLS policy enforced'),
        findsOneWidget,
      );

      verify(
        () => repository.createDailyPlan(title: 'Morning Routine'),
      ).called(1);
    });
  });
}
