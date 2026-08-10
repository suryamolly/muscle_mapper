## 1.2.0

* **Bug Fix — Advanced Mode Abs Mapping**: Corrected the SVG ID assignments for `Muscle.upperAbdominals` and `Muscle.lowerAbdominals` in the `MuscleSvgId` extension. The IDs were previously inverted relative to the advanced SVG's coordinate space, causing taps on the upper abs to register on the lower abs and vice versa.
* **Behaviour Change — Group Mode Tap**: The default example and documented interaction pattern for "Group Mode" now highlights the full **`MajorMuscleGroup`** (e.g., all of `Legs`) when tapping any sub-muscle, instead of just the narrower `MuscleGroup` (e.g., only `Quads`). Updated via `tappedMuscle.group.majorGroup.subMuscles`.
* **Example App — Default Colors on Tap**: In the example app's Group Mode, tapped muscles are now coloured with their `MajorMuscleGroup.defaultColor` automatically, giving each body region a distinct harmonious colour without any additional configuration.
* **Docs — Enum Corrections**: Fixed stale `Muscle` enum references (`pectoralis_major_l`, `anterior_deltoid_l/r`, `rectusAbdominis`) throughout the README and example app to use the correct unified enum values (`upperPectoralis`, `anteriorDeltoid`, etc.).

---

## 1.1.0

* **Intensity Heatmaps**: `MuscleMapper` now natively supports mapping exercise intensities!
  * **`muscleIntensities`**: Pass a `Map<Muscle, double>` to control the exact opacity/intensity of a muscle's highlight.
  * **`muscleColors`**: Pass a `Map<Muscle, Color>` to give individual muscles custom hues, overriding the global `highlightColor`.
  * **`MuscleIntensity` Enum**: A convenience enum providing `low`, `medium`, and `high` values that map to optimal `double` opacities.
  * **`MajorMuscleGroup.defaultColor`**: A new extension providing harmonious default color palettes (e.g. Arms = Blue, Chest = Red).

## 1.0.0

🎉 **Major Stable Release!** `muscle_mapper` is now production-ready with comprehensive test coverage, robust performance, and extensive developer API enhancements.

**Performance & Architecture**
* **Global SVG Cache**: The expensive SVG XML parsing now only happens once per gender+view combination per app session. Subsequent view switches load from an in-memory cache for an instant, flash-free experience.
* **`MuscleMapper.clearCache()`**: Added a static method to manually clear the global cache. Useful for custom `AnatomyAssetProvider` implementations that fetch SVGs from a network.
* **Smarter Hit Testing**: Tapping in an overlapping region no longer just picks the first match. The widget now finds ALL muscles whose paths contain the tap point and returns the one with the **smallest bounding box** — giving priority to the most precise, foreground muscle.

**Developer Experience (API Additions)**
* **`onMuscleDoubleTapped`**: Added callback for double-tap interactions, enabling complex flows (e.g., tap to select, double-tap to view details).
* **`verbose` flag**: Added `verbose: bool` parameter. When `true`, debug parsing logs are printed to the console. Defaults to `false` to keep production logs clean.
* **`animationCurve` parameter**: Added `animationCurve: Curve` for the highlight fade transition. Defaults to `Curves.easeInOut`.
* **`loadingWidget` parameter**: Added `loadingWidget: Widget?` to provide a custom loading state UI. Defaults to `CircularProgressIndicator`.
* **`onError` callback**: Added `onError: void Function(Object)?` that fires when the SVG fails to load or parse, enabling graceful error handling.

**Testing & Reliability**
* Added comprehensive unit and widget test suite covering the full 3-tier hierarchy (`Muscle`, `MuscleGroup`, `MajorMuscleGroup`), orphan detection, disjoint coverage, and widget smoke tests.


## 0.0.6

* **Maintenance**: Bumped `flutter_svg` to `^2.3.0` and `xml` to `^7.0.1` to support the latest up-to-date dependencies for pub.dev scoring.

## 0.0.5

* **Documentation**: Added demo GIF to README and added programmatic highlighting instructions.

## 0.0.4

* **Documentation**: Updated `homepage` in `pubspec.yaml` to point to the correct GitHub repository URL.

## 0.0.3

* **3-Tier Anatomical Hierarchy**: Redesigned the `Muscle` enum from 18 broad regions to 35 highly granular sub-muscles, directly matching individual SVG group IDs (e.g. `shortHeadBicep`, `longHeadBicep`).
* **Group Interaction Modes**: Introduced `MuscleGroup` (components) and `MajorMuscleGroup` (body sections) with extension getters (`.group`, `.subMuscles`) allowing developers to easily toggle between tapping precise sub-muscles or highlighting entire components.
* **Component Parsing Fix**: Fixed a bug where muscles composed of multiple SVG `<g>` groups (like the chest or quads) would only parse the first group. The parser now accurately combines all relevant groups.
* **Base Layer Fix**: Updated the rendering logic to include orphaned/un-IDed paths in the base silhouette, ensuring parts of the anatomy (like the head on the female back SVG) are not accidentally omitted.
* **Example App Update**: Added toggles for Gender, View, and Interaction Mode (Sub-Muscle vs Group).

## 0.0.2

* **Hybrid Architecture**: Render visuals natively using SVG strings while mathematically parsing invisible paths for hit-testing. This completely resolves the tap-stealing bug without sacrificing `flutter_svg`'s pixel-perfect visual rendering.
* **ColorFilter Optimization**: Removed deeply nested colored widgets in favor of direct SVG color filtering for performance.

## 0.0.1

* Initial release.
* Introduced `MuscleMapper` widget for interactive 2D human anatomy mapping.
* Support for Male/Female and Front/Back views.
* Interactive muscle highlighting with multi-select support (`activeMuscles`).
* Smooth fade animations for muscle state changes.
* Added `MuscleGroup` enum for easily selecting major muscle groups (Arms, Legs, Core, Chest, Back, Shoulders, Head & Neck).
* Built on a BYOA (Bring Your Own Asset) architecture: uses single-file SVGs and dynamically parses XML groups (`<g id="...">`) to render individual muscles independently.
* Added `AnatomyAssetProvider` interface for custom asset loading.
* Included a default implementation (`DefaultAnatomyProvider`) out of the box.
* Complete example app demonstrating features.
