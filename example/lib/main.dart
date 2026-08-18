import 'package:flutter/material.dart';
import 'package:muscle_mapper/muscle_mapper.dart';

void main() {
  runApp(const MuscleMapperExampleApp());
}

class MuscleMapperExampleApp extends StatelessWidget {
  const MuscleMapperExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Muscle Mapper Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MuscleMapperExamplePage(),
    );
  }
}

class MuscleMapperExamplePage extends StatefulWidget {
  const MuscleMapperExamplePage({super.key});

  @override
  State<MuscleMapperExamplePage> createState() =>
      _MuscleMapperExamplePageState();
}

enum InteractionMode { subMuscle, group }

class _MuscleMapperExamplePageState extends State<MuscleMapperExamplePage> {
  final Set<Muscle> _selectedMuscles = {};
  InteractionMode _mode = InteractionMode.group;
  AnatomyGender _gender = AnatomyGender.male;
  AnatomyView _view = AnatomyView.front;
  AnatomyStyle _style = AnatomyStyle.minimal;
  bool _intensityMode = false;

  void _onMuscleTapped(Muscle tappedMuscle) {
    setState(() {
      if (_mode == InteractionMode.subMuscle) {
        if (_selectedMuscles.contains(tappedMuscle)) {
          _selectedMuscles.remove(tappedMuscle);
        } else {
          _selectedMuscles.add(tappedMuscle);
        }
      } else {
        final groupMuscles = tappedMuscle.group.majorGroup.subMuscles;
        if (_selectedMuscles.containsAll(groupMuscles)) {
          _selectedMuscles.removeAll(groupMuscles);
        } else {
          _selectedMuscles.addAll(groupMuscles);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Muscle Mapper Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SegmentedButtonTheme(
              data: SegmentedButtonThemeData(
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  textStyle: const TextStyle(fontSize: 12),
                ),
              ),
              child: Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.center,
                children: [
                  SegmentedButton<AnatomyStyle>(
                    segments: const [
                      ButtonSegment(
                          value: AnatomyStyle.minimal, label: Text('Minimal')),
                      ButtonSegment(
                          value: AnatomyStyle.advanced, label: Text('Advanced')),
                    ],
                    selected: {_style},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _style = selection.first;
                        if (_style == AnatomyStyle.advanced) {
                          _gender = AnatomyGender.male; // Enforce male for advanced
                        }
                      });
                    },
                  ),
                  if (_style == AnatomyStyle.minimal)
                    SegmentedButton<AnatomyGender>(
                      segments: const [
                        ButtonSegment(
                            value: AnatomyGender.male, label: Text('Male')),
                        ButtonSegment(
                            value: AnatomyGender.female, label: Text('Female')),
                      ],
                      selected: {_gender},
                      onSelectionChanged: (selection) =>
                          setState(() => _gender = selection.first),
                    ),
                  SegmentedButton<AnatomyView>(
                    segments: const [
                      ButtonSegment(
                          value: AnatomyView.front, label: Text('Front')),
                      ButtonSegment(value: AnatomyView.back, label: Text('Back')),
                    ],
                    selected: {_view},
                    onSelectionChanged: (selection) {
                      setState(() => _view = selection.first);
                    },
                  ),
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: false, label: Text('Normal')),
                      ButtonSegment(value: true, label: Text('Intensity')),
                    ],
                    selected: {_intensityMode},
                    onSelectionChanged: (selection) {
                      setState(() => _intensityMode = selection.first);
                    },
                  ),
                  SegmentedButton<InteractionMode>(
                    segments: const [
                      ButtonSegment(
                        value: InteractionMode.group,
                        label: Text('Group'),
                      ),
                      ButtonSegment(
                        value: InteractionMode.subMuscle,
                        label: Text('Sub-Muscle'),
                      ),
                    ],
                    selected: {_mode},
                    onSelectionChanged: (newSelection) {
                      setState(() {
                        _mode = newSelection.first;
                        _selectedMuscles.clear();
                      });
                    },
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      textStyle: const TextStyle(fontSize: 12),
                    ),
                    onPressed: () {
                      setState(() {
                        _gender = AnatomyGender.male;
                        _view = AnatomyView.front;
                        _selectedMuscles.addAll(MuscleGroup.chest.subMuscles);
                      });
                    },
                    icon: const Icon(Icons.fitness_center, size: 16),
                    label: const Text('Programmatic Highlight: Chest'),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: MuscleMapper(
                  gender: _gender,
                  view: _view,
                  assetProvider: DefaultAnatomyProvider(style: _style),
                  activeMuscles: _intensityMode ? const {} : _selectedMuscles,
                  muscleIntensities: _intensityMode 
                      ? {
                          Muscle.rectusFemoris: MuscleIntensity.high.value,
                          Muscle.upperPectoralis: MuscleIntensity.medium.value,
                          Muscle.midLowerPectoralis: MuscleIntensity.high.value,
                          Muscle.anteriorDeltoid: MuscleIntensity.medium.value,
                          Muscle.upperAbdominals: MuscleIntensity.low.value,
                          Muscle.lowerAbdominals: MuscleIntensity.low.value,
                        } 
                      : null,
                  muscleColors: _intensityMode
                      ? {
                          Muscle.rectusFemoris: MajorMuscleGroup.legs.defaultColor,
                          Muscle.upperPectoralis: MajorMuscleGroup.chest.defaultColor,
                          Muscle.midLowerPectoralis: MajorMuscleGroup.chest.defaultColor,
                          Muscle.anteriorDeltoid: MajorMuscleGroup.shoulders.defaultColor,
                          Muscle.upperAbdominals: MajorMuscleGroup.core.defaultColor,
                          Muscle.lowerAbdominals: MajorMuscleGroup.core.defaultColor,
                        }
                      : {
                          for (final m in _selectedMuscles)
                            m: m.group.majorGroup.defaultColor
                        },
                  onMuscleTapped: _onMuscleTapped,
                  highlightColor: Colors.redAccent,
                  baseColor: Colors.grey.shade300,
                  onError: (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error loading SVG: $e')),
                    );
                  },
                ),
              ),
          ),
          SizedBox(
            height: 120, // Fixes height to exactly 2 rows of Chips
            width: double.infinity,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16.0),
              child: Wrap(
                direction: Axis
                    .vertical, // Forces chips to fill columns vertically first
                spacing: 8.0,
                runSpacing: 8.0,
                children: _selectedMuscles.map((m) {
                  return Chip(
                    label: Text(m.name),
                    onDeleted: () {
                      setState(() => _selectedMuscles.remove(m));
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
