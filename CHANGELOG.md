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
