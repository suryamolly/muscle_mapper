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
        final groupMuscles = tappedMuscle.group.subMuscles;
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
            padding: const EdgeInsets.all(16.0),
            child: Wrap(
              spacing: 16.0,
              runSpacing: 16.0,
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
                    ButtonSegment(value: true, label: Text('Intensity Mode')),
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
                      label: Text('Group Mode'),
                    ),
                    ButtonSegment(
                      value: InteractionMode.subMuscle,
                      label: Text('Sub-Muscle Mode'),
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
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () {
              setState(() {
                _gender = AnatomyGender.male;
                _view = AnatomyView.front;
                _selectedMuscles.addAll(MuscleGroup.chest.subMuscles);
              });
            },
            icon: const Icon(Icons.fitness_center),
            label: const Text('Programmatic Highlight: Chest'),
          ),
          Expanded(
            child: Center(
              child: SizedBox(
                width: 300,
                height: 500,
                child: MuscleMapper(
                  gender: _gender,
                  view: _view,
                  assetProvider: DefaultAnatomyProvider(style: _style),
                  activeMuscles: _intensityMode ? const {} : _selectedMuscles,
                  muscleIntensities: _intensityMode 
                      ? {
                          Muscle.rectus_femoris_l: MuscleIntensity.high.value,
                          Muscle.rectus_femoris_r: MuscleIntensity.low.value,
                          Muscle.upperPectoralis: MuscleIntensity.medium.value,
                          Muscle.midLowerPectoralis: MuscleIntensity.high.value,
                          Muscle.anterior_deltoid_l: MuscleIntensity.medium.value,
                          Muscle.anterior_deltoid_r: MuscleIntensity.medium.value,
                          Muscle.rectusAbdominis: MuscleIntensity.low.value,
                        } 
                      : null,
                  muscleColors: _intensityMode
                      ? {
                          Muscle.rectus_femoris_l: MajorMuscleGroup.legs.defaultColor,
                          Muscle.rectus_femoris_r: MajorMuscleGroup.legs.defaultColor,
                          Muscle.upperPectoralis: MajorMuscleGroup.chest.defaultColor,
                          Muscle.midLowerPectoralis: MajorMuscleGroup.chest.defaultColor,
                          Muscle.anterior_deltoid_l: MajorMuscleGroup.shoulders.defaultColor,
                          Muscle.anterior_deltoid_r: MajorMuscleGroup.shoulders.defaultColor,
                          Muscle.rectusAbdominis: MajorMuscleGroup.core.defaultColor,
                        }
                      : null,
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
