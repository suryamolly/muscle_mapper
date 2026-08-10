import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/anatomy_models.dart';
import '../models/anatomy_asset_provider.dart';

/// A default implementation of [AnatomyAssetProvider] that uses bundled SVG assets.
class DefaultAnatomyProvider implements AnatomyAssetProvider {
  final AnatomyStyle style;

  const DefaultAnatomyProvider({
    this.style = AnatomyStyle.minimal,
  });

  @override
  Future<String> getAnatomySvgRawString(
      AnatomyGender gender, AnatomyView view) async {
    // Advanced style only has male assets right now; fallback to male.
    final effectiveGender = style == AnatomyStyle.advanced ? AnatomyGender.male : gender;
    
    final genderStr = effectiveGender == AnatomyGender.male ? 'male' : 'female';
    final viewStr = view == AnatomyView.front ? 'front' : 'back';

    // Maps to the specific filenames the user provided:
    // male_front_muscle_anatomy.svg
    // male_back_muscle_anatomy.svg
    // female_front_muscles_anatomy.svg
    // female_back_muscles_anatomy.svg
    final fileName = effectiveGender == AnatomyGender.female
        ? '${genderStr}_${viewStr}_muscles_anatomy.svg'
        : '${genderStr}_${viewStr}_muscle_anatomy.svg';

    final styleFolder = style == AnatomyStyle.advanced ? 'advanced' : 'minimal';
    final path = 'lib/src/assets/$styleFolder/$fileName';

    return await rootBundle.loadString('packages/muscle_mapper/$path');
  }

  @override
  Widget buildSvgWidget(String svgString, {BoxFit fit = BoxFit.contain}) {
    return SvgPicture.string(
      svgString,
      fit: fit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DefaultAnatomyProvider && other.style == style;
  }

  @override
  int get hashCode => style.hashCode;
}
