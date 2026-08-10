import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muscle_mapper/muscle_mapper.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Mock providers for widget tests
// ─────────────────────────────────────────────────────────────────────────────

class _MockAnatomyProvider implements AnatomyAssetProvider {
  static const String _mockSvg = '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 676 1203">
  <g id="body"><rect width="676" height="1203" fill="grey"/></g>
  <g id="upper-pectoralis"><rect x="200" y="200" width="100" height="50" fill="currentColor"/></g>
  <g id="mid-lower-pectoralis"><rect x="200" y="260" width="100" height="50" fill="currentColor"/></g>
</svg>''';

  @override
  Future<String> getAnatomySvgRawString(
      AnatomyGender gender, AnatomyView view) async {
    return _mockSvg;
  }

  @override
  Widget buildSvgWidget(String svgString, {BoxFit fit = BoxFit.contain}) {
    return const SizedBox.expand();
  }
}

/// A provider that always throws, used to test the onError callback.
class _ThrowingProvider implements AnatomyAssetProvider {
  @override
  Future<String> getAnatomySvgRawString(
      AnatomyGender gender, AnatomyView view) async {
    throw Exception('Network error: could not fetch SVG');
  }

  @override
  Widget buildSvgWidget(String svgString, {BoxFit fit = BoxFit.contain}) {
    return const SizedBox.shrink();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  // ── 1. Muscle → MuscleGroup ──────────────────────────────────────────────

  group('Muscle.group extension', () {
    test('chest muscles resolve to MuscleGroup.chest', () {
      expect(Muscle.upperPectoralis.group, equals(MuscleGroup.chest));
      expect(Muscle.midLowerPectoralis.group, equals(MuscleGroup.chest));
    });

    test('bicep muscles resolve to MuscleGroup.biceps', () {
      expect(Muscle.longHeadBicep.group, equals(MuscleGroup.biceps));
      expect(Muscle.shortHeadBicep.group, equals(MuscleGroup.biceps));
    });

    test('tricep muscles resolve to MuscleGroup.triceps', () {
      expect(Muscle.longHeadTriceps.group, equals(MuscleGroup.triceps));
      expect(Muscle.lateralHeadTriceps.group, equals(MuscleGroup.triceps));
      expect(Muscle.medialHeadTriceps.group, equals(MuscleGroup.triceps));
    });

    test('quad muscles resolve to MuscleGroup.quads', () {
      expect(Muscle.outerQuadricep.group, equals(MuscleGroup.quads));
      expect(Muscle.rectusFemoris.group, equals(MuscleGroup.quads));
      expect(Muscle.innerQuadricep.group, equals(MuscleGroup.quads));
    });

    test('glute muscles resolve to MuscleGroup.glutes', () {
      expect(Muscle.gluteusMaximus.group, equals(MuscleGroup.glutes));
      expect(Muscle.gluteusMedius.group, equals(MuscleGroup.glutes));
    });

    test('every Muscle value has a valid group (no orphans)', () {
      for (final muscle in Muscle.values) {
        final group = muscle.group;
        expect(
          group.subMuscles.contains(muscle),
          isTrue,
          reason:
              '${muscle.name} returned group ${group.name}, but that group does not contain it back.',
        );
      }
    });
  });

  // ── 2. MuscleGroup.subMuscles ────────────────────────────────────────────

  group('MuscleGroup.subMuscles extension', () {
    test('chest subMuscles contains both pectoralis heads', () {
      final muscles = MuscleGroup.chest.subMuscles;
      expect(muscles,
          containsAll([Muscle.upperPectoralis, Muscle.midLowerPectoralis]));
      expect(muscles.length, equals(2));
    });

    test('biceps subMuscles contains both heads', () {
      final muscles = MuscleGroup.biceps.subMuscles;
      expect(muscles,
          containsAll([Muscle.longHeadBicep, Muscle.shortHeadBicep]));
      expect(muscles.length, equals(2));
    });

    test('triceps subMuscles contains all three heads', () {
      final muscles = MuscleGroup.triceps.subMuscles;
      expect(muscles, containsAll([
        Muscle.longHeadTriceps,
        Muscle.lateralHeadTriceps,
        Muscle.medialHeadTriceps,
      ]));
      expect(muscles.length, equals(3));
    });

    test('no MuscleGroup has an empty subMuscles set', () {
      for (final group in MuscleGroup.values) {
        expect(
          group.subMuscles.isNotEmpty,
          isTrue,
          reason: '${group.name}.subMuscles is empty!',
        );
      }
    });

    test('subMuscles sets are disjoint across groups (no duplicate muscles)', () {
      final seen = <Muscle>{};
      for (final group in MuscleGroup.values) {
        for (final muscle in group.subMuscles) {
          expect(
            seen.contains(muscle),
            isFalse,
            reason: '${muscle.name} appears in more than one MuscleGroup!',
          );
          seen.add(muscle);
        }
      }
    });

    test('all Muscle values are covered by exactly one MuscleGroup', () {
      final covered =
          MuscleGroup.values.expand((g) => g.subMuscles).toSet();
      expect(covered, containsAll(Muscle.values),
          reason: 'Some Muscle values are not in any MuscleGroup!');
      expect(covered.length, equals(Muscle.values.length),
          reason:
              'Total covered muscles does not match total Muscle enum values.');
    });
  });

  // ── 3. MuscleGroup → MajorMuscleGroup ───────────────────────────────────

  group('MuscleGroup.majorGroup extension', () {
    test('chest resolves to MajorMuscleGroup.chest', () {
      expect(MuscleGroup.chest.majorGroup, equals(MajorMuscleGroup.chest));
    });

    test('biceps resolves to MajorMuscleGroup.arms', () {
      expect(MuscleGroup.biceps.majorGroup, equals(MajorMuscleGroup.arms));
    });

    test('triceps resolves to MajorMuscleGroup.arms', () {
      expect(MuscleGroup.triceps.majorGroup, equals(MajorMuscleGroup.arms));
    });

    test('quads resolves to MajorMuscleGroup.legs', () {
      expect(MuscleGroup.quads.majorGroup, equals(MajorMuscleGroup.legs));
    });

    test('abs resolves to MajorMuscleGroup.core', () {
      expect(MuscleGroup.abs.majorGroup, equals(MajorMuscleGroup.core));
    });

    test('lats resolves to MajorMuscleGroup.back', () {
      expect(MuscleGroup.lats.majorGroup, equals(MajorMuscleGroup.back));
    });

    test('deltoids resolves to MajorMuscleGroup.shoulders', () {
      expect(
          MuscleGroup.deltoids.majorGroup, equals(MajorMuscleGroup.shoulders));
    });

    test('neck resolves to MajorMuscleGroup.headAndNeck', () {
      expect(
          MuscleGroup.neck.majorGroup, equals(MajorMuscleGroup.headAndNeck));
    });

    test('every MuscleGroup has a valid majorGroup (no orphans)', () {
      for (final group in MuscleGroup.values) {
        final major = group.majorGroup;
        expect(
          major.groups.contains(group),
          isTrue,
          reason:
              '${group.name} returned majorGroup ${major.name}, but that major group does not contain it back.',
        );
      }
    });
  });

  // ── 4. MajorMuscleGroup.subMuscles ──────────────────────────────────────

  group('MajorMuscleGroup.subMuscles', () {
    test('arms subMuscles includes bicep and tricep muscles', () {
      final muscles = MajorMuscleGroup.arms.subMuscles;
      expect(muscles, containsAll([
        Muscle.longHeadBicep,
        Muscle.shortHeadBicep,
        Muscle.longHeadTriceps,
      ]));
    });

    test('legs subMuscles includes quads and glutes', () {
      final muscles = MajorMuscleGroup.legs.subMuscles;
      expect(muscles, containsAll([
        Muscle.outerQuadricep,
        Muscle.gluteusMaximus,
        Muscle.gastrocnemius,
      ]));
    });

    test('core subMuscles includes abs and obliques', () {
      final muscles = MajorMuscleGroup.core.subMuscles;
      expect(muscles,
          containsAll([Muscle.upperAbdominals, Muscle.obliques]));
    });

    test('no MajorMuscleGroup has an empty subMuscles set', () {
      for (final major in MajorMuscleGroup.values) {
        expect(
          major.subMuscles.isNotEmpty,
          isTrue,
          reason: '${major.name}.subMuscles is empty!',
        );
      }
    });
  });

  // ── 5. Widget Smoke Tests ────────────────────────────────────────────────

  group('MuscleMapper widget', () {
    testWidgets('renders loading indicator by default while loading',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 500,
              child: MuscleMapper(
                gender: AnatomyGender.male,
                view: AnatomyView.front,
                assetProvider: _MockAnatomyProvider(),
                activeMuscles: const {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.byType(MuscleMapper), findsOneWidget);
    });

    testWidgets('shows custom loadingWidget while loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 500,
              child: MuscleMapper(
                gender: AnatomyGender.male,
                view: AnatomyView.front,
                assetProvider: _MockAnatomyProvider(),
                activeMuscles: const {},
                loadingWidget: const Text('Loading anatomy...'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Loading anatomy...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('rebuilds when activeMuscles changes', (tester) async {
      var activeMuscles = <Muscle>{};

      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return Scaffold(
                body: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => setState(
                          () => activeMuscles = {Muscle.upperPectoralis}),
                      child: const Text('Select Chest'),
                    ),
                    SizedBox(
                      width: 300,
                      height: 500,
                      child: MuscleMapper(
                        gender: AnatomyGender.male,
                        view: AnatomyView.front,
                        assetProvider: _MockAnatomyProvider(),
                        activeMuscles: activeMuscles,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );

      await tester.pumpAndSettle();
      await tester.tap(find.text('Select Chest'));
      await tester.pumpAndSettle();
      expect(find.byType(MuscleMapper), findsOneWidget);
    });

    testWidgets('fires onError when assetProvider throws', (tester) async {
      Object? capturedError;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              height: 500,
              child: MuscleMapper(
                gender: AnatomyGender.male,
                view: AnatomyView.front,
                assetProvider: _ThrowingProvider(),
                activeMuscles: const {},
                onError: (e) => capturedError = e,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(capturedError, isNotNull);
    });
  });
}
