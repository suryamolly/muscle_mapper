import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:xml/xml.dart';
import 'package:path_drawing/path_drawing.dart';
import '../models/anatomy_models.dart';
import '../models/anatomy_asset_provider.dart';

// ─────────────────────────── Cache Data Class ───────────────────────────

/// Holds all pre-parsed data for a single gender+view SVG.
/// Stored in the global cache so the expensive XML parsing only happens once.
class _ParsedSvgData {
  final String baseSource;
  final Map<Muscle, String> muscleSources;
  final Map<Muscle, Path> musclePaths;
  final Rect viewBox;

  const _ParsedSvgData({
    required this.baseSource,
    required this.muscleSources,
    required this.musclePaths,
    required this.viewBox,
  });
}

/// A widget that displays a 2D human anatomy model with interactive muscle highlighting.
class MuscleMapper extends StatefulWidget {
  /// The gender of the anatomy model.
  final AnatomyGender gender;

  /// The viewing angle of the anatomy model.
  final AnatomyView view;

  /// The provider that supplies the SVG assets.
  final AnatomyAssetProvider assetProvider;

  /// The set of muscles that should be highlighted.
  final Set<Muscle> activeMuscles;

  /// Callback when a muscle is tapped.
  /// If null, muscles are not interactive for single taps.
  final void Function(Muscle)? onMuscleTapped;

  /// Callback when a muscle is double-tapped.
  /// If null, muscles are not interactive for double taps.
  final void Function(Muscle)? onMuscleDoubleTapped;

  /// The color used to highlight active muscles.
  final Color highlightColor;

  /// The color used for the base anatomy model.
  final Color baseColor;

  /// The duration of the fade animation when a muscle is highlighted.
  final Duration animationDuration;

  /// The animation curve for the highlight fade transition.
  /// Defaults to [Curves.easeInOut].
  final Curve animationCurve;

  /// A custom widget to show while the anatomy SVG is loading.
  /// Defaults to a [CircularProgressIndicator] if null.
  final Widget? loadingWidget;

  /// Callback fired if the SVG fails to load or parse.
  /// Use this to show custom error UI or log errors.
  final void Function(Object error)? onError;

  /// If true, prints parsing and hit-test debug information to the console.
  /// Useful during development. Defaults to false.
  final bool verbose;

  const MuscleMapper({
    super.key,
    this.gender = AnatomyGender.male,
    this.view = AnatomyView.front,
    required this.assetProvider,
    this.activeMuscles = const {},
    this.onMuscleTapped,
    this.onMuscleDoubleTapped,
    this.highlightColor = Colors.red,
    this.baseColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 300),
    this.animationCurve = Curves.easeInOut,
    this.loadingWidget,
    this.onError,
    this.verbose = false,
  });

  @override
  State<MuscleMapper> createState() => _MuscleMapperState();

  /// Global cache keyed by "gender_view" (e.g. "male_front").
  /// Cleared when [clearCache] is called.
  static final Map<String, _ParsedSvgData> _cache = {};

  /// Clears the global SVG parse cache.
  ///
  /// Call this if you use a custom [AnatomyAssetProvider] that fetches
  /// SVGs from a network and the remote content has changed.
  static void clearCache() => _cache.clear();
}

class _MuscleMapperState extends State<MuscleMapper> {
  String? _baseAnatomySource;

  /// For rendering: each muscle's isolated SVG string.
  final Map<Muscle, String> _muscleSources = {};

  /// For hit-testing: each muscle's combined Flutter Path.
  final Map<Muscle, Path> _musclePaths = {};

  /// SVG viewBox rectangle for coordinate mapping.
  Rect _viewBox = const Rect.fromLTWH(0, 0, 676, 1203);

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAssets();
  }

  @override
  void didUpdateWidget(covariant MuscleMapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gender != widget.gender || oldWidget.view != widget.view) {
      _loadAssets();
    }
  }

  // ─────────────────────────── Asset Loading ───────────────────────────

  Future<void> _loadAssets() async {
    if (mounted) setState(() => _isLoading = true);

    final cacheKey = '${widget.gender.name}_${widget.view.name}';

    // ── Cache hit: populate local state instantly from cached data ──
    if (MuscleMapper._cache.containsKey(cacheKey)) {
      final cached = MuscleMapper._cache[cacheKey]!;
      _baseAnatomySource = cached.baseSource;
      _muscleSources
        ..clear()
        ..addAll(cached.muscleSources);
      _musclePaths
        ..clear()
        ..addAll(cached.musclePaths);
      _viewBox = cached.viewBox;
      if (widget.verbose) {
        debugPrint('MuscleMapper: cache HIT for $cacheKey');
      }
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // ── Cache miss: parse the SVG and populate the cache ──
    try {
      final rawSvg = await widget.assetProvider
          .getAnatomySvgRawString(widget.gender, widget.view);
      final document = XmlDocument.parse(rawSvg);
      final root = document.rootElement;

      // Parse viewBox for hit-test coordinate mapping
      final vb = root.getAttribute('viewBox');
      if (vb != null) {
        final parts = vb.trim().split(RegExp(r'[\s,]+'));
        if (parts.length == 4) {
          _viewBox = Rect.fromLTWH(
            double.parse(parts[0]),
            double.parse(parts[1]),
            double.parse(parts[2]),
            double.parse(parts[3]),
          );
        }
      }

      // Base layer: combine <g id="body"> with any un-ID'd orphaned paths (e.g. the head)
      final baseElements = <XmlElement>[];
      final bodyEl = _findElementById(root, 'body');
      if (bodyEl != null) baseElements.add(bodyEl);

      // Collect any top-level elements without an ID (which the SVG editor might have left orphaned)
      for (final child in root.children.whereType<XmlElement>()) {
        if (child.getAttribute('id') == null) {
          baseElements.add(child);
        }
      }

      _baseAnatomySource = baseElements.isNotEmpty
          ? _buildSvgString(root, baseElements)
          : rawSvg;

      _muscleSources.clear();
      _musclePaths.clear();

      // For each muscle, accumulate ALL matching components (e.g. upper + lower chest)
      for (final muscle in Muscle.values) {
        final List<XmlElement> matchedElements = [];

        for (final id in muscle.svgIds) {
          // Strategy 1: find a <g> or <path> with matching id attribute
          final el = _findElementById(root, id);
          if (el != null) {
            matchedElements.add(el);
            continue; // Move to next ID in the list
          }

          // Strategy 2: collect <path> elements with data-muscle-region="id"
          final regionPaths = _findByRegion(root, id);
          if (regionPaths.isNotEmpty) {
            matchedElements.addAll(regionPaths);
          }
        }

        if (matchedElements.isNotEmpty) {
          _muscleSources[muscle] = _buildSvgString(root, matchedElements);
          _musclePaths[muscle] = _parsePaths(matchedElements);
        }
      }

      if (widget.verbose) {
        debugPrint(
            'MuscleMapper: cache MISS for $cacheKey — parsed ${_muscleSources.length} muscles, viewBox=$_viewBox');
      }

      // Store parsed results in the global cache for future use
      MuscleMapper._cache[cacheKey] = _ParsedSvgData(
        baseSource: _baseAnatomySource!,
        muscleSources: Map.unmodifiable(_muscleSources),
        musclePaths: Map.unmodifiable(_musclePaths),
        viewBox: _viewBox,
      );
    } catch (e) {
      if (widget.verbose) debugPrint('MuscleMapper error: $e');
      widget.onError?.call(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─────────────────────────── XML Helpers ───────────────────────────

  /// Recursively searches for ANY element with a matching [id] attribute.
  XmlElement? _findElementById(XmlElement node, String id) {
    if (node.getAttribute('id') == id) return node;
    for (final child in node.children.whereType<XmlElement>()) {
      final found = _findElementById(child, id);
      if (found != null) return found;
    }
    return null;
  }

  /// Finds all `<path>` elements whose `data-muscle-region` equals [region].
  List<XmlElement> _findByRegion(XmlElement node, String region) {
    final results = <XmlElement>[];
    if (node.name.local == 'path' &&
        node.getAttribute('data-muscle-region') == region) {
      results.add(node);
    }
    for (final child in node.children.whereType<XmlElement>()) {
      results.addAll(_findByRegion(child, region));
    }
    return results;
  }

  /// Builds a standalone SVG string from a list of elements.
  /// Preserves the original `<svg>` attributes and `<defs>` block.
  String _buildSvgString(XmlElement root, List<XmlElement> elements) {
    final newRoot = XmlElement(
      XmlName('svg'),
      root.attributes
          .map((a) =>
              XmlAttribute(XmlName(a.name.local, a.name.prefix), a.value))
          .toList(),
      [],
    );

    // Copy over <defs> (gradients, clip paths, etc.)
    final defs = root.children
        .whereType<XmlElement>()
        .where((e) => e.name.local == 'defs')
        .firstOrNull;
    if (defs != null) newRoot.children.add(defs.copy());

    if (elements.length == 1) {
      newRoot.children.add(elements.first.copy());
    } else {
      final wrapper = XmlElement(XmlName('g'), [], []);
      for (final el in elements) {
        wrapper.children.add(el.copy());
      }
      newRoot.children.add(wrapper);
    }

    return newRoot.toXmlString();
  }

  // ─────────────────────────── Path Parsing ───────────────────────────

  /// Combines all `<path d="...">` data from elements and descendants
  /// into a single Flutter [Path] for invisible hit-testing.
  Path _parsePaths(List<XmlElement> elements) {
    final combined = Path();
    for (final el in elements) {
      _addPathsFromElement(el, combined);
    }
    return combined;
  }

  void _addPathsFromElement(XmlElement el, Path combined) {
    if (el.name.local == 'path') {
      final d = el.getAttribute('d');
      if (d != null && d.trim().isNotEmpty) {
        try {
          combined.addPath(parseSvgPathData(d), Offset.zero);
        } catch (e) {
          // Some complex path commands may not be supported; skip gracefully
          debugPrint('path_drawing skipped a path: $e');
        }
      }
    }
    for (final child in el.children.whereType<XmlElement>()) {
      _addPathsFromElement(child, combined);
    }
  }

  // ─────────────────────────── Hit Testing ───────────────────────────

  /// Maps screen coordinates to SVG coordinates and finds the best matching muscle.
  Muscle? _hitTest(Offset localPosition, Size size) {
    // Replicate BoxFit.contain scaling to map screen coords → SVG coords
    final scaleX = size.width / _viewBox.width;
    final scaleY = size.height / _viewBox.height;
    final scale = math.min(scaleX, scaleY);

    final dx = (size.width - _viewBox.width * scale) / 2;
    final dy = (size.height - _viewBox.height * scale) / 2;

    final svgX = (localPosition.dx - dx) / scale;
    final svgY = (localPosition.dy - dy) / scale;
    final mapped = Offset(svgX, svgY);

    // Collect ALL muscles whose path contains the tap point,
    // then pick the one with the smallest bounding box area —
    // this gives priority to the most precise/foreground muscle.
    Muscle? bestMatch;
    double bestArea = double.infinity;

    for (final entry in _musclePaths.entries) {
      if (entry.value.contains(mapped)) {
        final bounds = entry.value.getBounds();
        final area = bounds.width * bounds.height;
        if (area < bestArea) {
          bestArea = area;
          bestMatch = entry.key;
        }
      }
    }

    return bestMatch;
  }

  void _handleTap(TapUpDetails details, Size size) {
    if (widget.onMuscleTapped == null) return;
    final match = _hitTest(details.localPosition, size);
    if (match != null) widget.onMuscleTapped!(match);
  }

  void _handleDoubleTap(TapDownDetails details, Size size) {
    if (widget.onMuscleDoubleTapped == null) return;
    final match = _hitTest(details.localPosition, size);
    if (match != null) widget.onMuscleDoubleTapped!(match);
  }

  // ─────────────────────────── Build ───────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(
        child: widget.loadingWidget ?? const CircularProgressIndicator(),
      );
    }
    if (_baseAnatomySource == null) {
      return const Center(child: Text('Failed to load anatomy model.'));
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onTapUp:
              widget.onMuscleTapped != null ? (d) => _handleTap(d, size) : null,
          onDoubleTapDown: widget.onMuscleDoubleTapped != null
              ? (d) => _handleDoubleTap(d, size)
              : null,
          behavior: HitTestBehavior.translucent,
          child: Stack(
            alignment: Alignment.center,
            fit: StackFit.expand,
            children: [
              // Base anatomy layer (non-interactive)
              IgnorePointer(
                child: widget.assetProvider.buildSvgWidget(_baseAnatomySource!),
              ),

              // Muscle highlight layers — visual only.
              // All taps are handled by the parent GestureDetector.
              ..._muscleSources.entries.map((entry) {
                final isActive = widget.activeMuscles.contains(entry.key);
                return IgnorePointer(
                  child: AnimatedOpacity(
                    duration: widget.animationDuration,
                    curve: widget.animationCurve,
                    opacity: isActive ? 1.0 : 0.0,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                          widget.highlightColor, BlendMode.srcIn),
                      child: widget.assetProvider.buildSvgWidget(entry.value),
                    ),
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
