import 'package:flutter/widgets.dart';
import 'anatomy_models.dart';

/// Provides SVG assets for the [MuscleMapper] widget.
///
/// Implementing classes should provide either a network URL, a local asset path,
/// or a raw SVG string for the base anatomy and individual muscle layers.
abstract class AnatomyAssetProvider {
  /// Returns the raw SVG string containing the entire anatomy model for a given gender and view.
  /// The SVG must contain group elements `<g>` with IDs matching the values in [MuscleSvgId.svgId].
  Future<String> getAnatomySvgRawString(AnatomyGender gender, AnatomyView view);

  /// Builds a widget from the raw SVG string.
  Widget buildSvgWidget(String svgString, {BoxFit fit = BoxFit.contain});
}
