import 'package:flutter/material.dart';

/// Defines the gender of the anatomy model.
enum AnatomyGender {
  male,
  female,
}

/// Defines the viewing angle of the anatomy model.
enum AnatomyView {
  front,
  back,
}

/// Defines the style of the SVG anatomy model.
enum AnatomyStyle {
  minimal,
  advanced,
}

/// Represents the most granular level of interactivity. Each [Muscle] matches
/// EXACTLY one `<g id="...">` group in the SVG files.
enum Muscle {
  // ── Chest ──
  upperPectoralis,
  midLowerPectoralis,

  // ── Core & Abs ──
  upperAbdominals,
  lowerAbdominals,
  obliques,
  groin,

  // ── Arms ──
  longHeadBicep,
  shortHeadBicep,
  longHeadTriceps,
  lateralHeadTriceps,
  medialHeadTriceps,
  wristFlexors,
  wristExtensors,
  hands,

  // ── Shoulders ──
  anteriorDeltoid,
  lateralDeltoid,
  posteriorDeltoid,

  // ── Legs ──
  outerQuadricep,
  rectusFemoris,
  innerQuadricep,
  innerThigh,
  lateralHamstrings,
  medialHamstrings,
  gluteusMaximus,
  gluteusMedius,
  gastrocnemius,
  soleus,
  tibialis,
  feet,

  // ── Back ──
  upperTrapezius,
  trapsMiddle,
  lowerTrapezius,
  lats,
  lowerBack,

  // ── Head & Neck ──
  neck,
}

extension MuscleSvgId on Muscle {
  /// Returns the specific SVG IDs to search for. Multiple IDs handle typos.
  List<String> get svgIds {
    switch (this) {
      case Muscle.upperPectoralis:
        return ['upper-pectoralis', 'pectoralis_major_l', 'pectoralis_major_r'];
      case Muscle.midLowerPectoralis:
        return ['mid-lower-pectoralis', 'pectoralis_major_l', 'pectoralis_major_r'];
      case Muscle.upperAbdominals:
        return ['upper-abdominals', 'rectus_abdominis_4_l', 'rectus_abdominis_4_r', 'rectus_abdominis_2_l', 'rectus_abdominis_2_r'];
      case Muscle.lowerAbdominals:
        return ['lower-abdominals', 'rectus_abdominis_3_l', 'rectus_abdominis_3_r', 'rectus_abdominis_1'];
      case Muscle.obliques:
        return ['obliques', 'external_oblique_1_l', 'external_oblique_2_l', 'external_oblique_3_l', 'external_oblique_4_l', 'external_oblique_5_l', 'external_oblique_6_l', 'external_oblique_7_l', 'external_oblique_8_l', 'external_oblique_1_r', 'external_oblique_2_r', 'external_oblique_3_r', 'external_oblique_4_r', 'external_oblique_5_r', 'external_oblique_6_r', 'external_oblique_7_r', 'external_oblique_8_r'];
      case Muscle.groin:
        return ['groin', 'adductor_longus_l', 'adductor_longus_r', 'pectineus_l', 'pectineus_r', 'gracilis_l', 'gracilis_r', 'adductor_magnus_l', 'adductor_magnus_r'];
      case Muscle.longHeadBicep:
        return ['long-head-bicep', 'biceps_brachii_caput_longum_l', 'biceps_brachii_caput_longum_r'];
      case Muscle.shortHeadBicep:
        return ['short-head-bicep', 'biceps_brachii_caput_breve_l', 'biceps_brachii_caput_breve_r'];
      case Muscle.longHeadTriceps:
        return ['long-head-triceps', 'triceps_brachii_caput_longum_l', 'triceps_brachii_caput_longum_r'];
      case Muscle.lateralHeadTriceps:
        return ['lateral-head-triceps', 'later-head-triceps', 'triceps_brachii_caput_laterale_l', 'triceps_brachii_caput_laterale_r'];
      case Muscle.medialHeadTriceps:
        return ['medial-head-triceps', 'triceps_brachii_caput_mediale_l', 'triceps_brachii_caput_mediale_r'];
      case Muscle.wristFlexors:
        return ['wrist-flexors', 'flexor_carpi_radialis_l', 'flexor_carpi_radialis_r', 'flexor_carpi_ulnaris_l', 'flexor_carpi_ulnaris_r', 'palmaris_longus_l', 'palmaris_longus_r', 'flexor_digitorum_superficialis_l', 'flexor_digitorum_superficialis_r', 'pronator_teres_l', 'pronator_teres_r', 'pronator_quadratus_l', 'pronator_quadratus_r'];
      case Muscle.wristExtensors:
        return ['wrist-extensors', 'extensor_carpi_radialis_longus_l', 'extensor_carpi_radialis_longus_r', 'extensor_digitorum_l', 'extensor_digitorum_r', 'extensor_carpi_ulnaris_l', 'extensor_carpi_ulnaris_r', 'brachioradialis_l', 'brachioradialis_r', 'anconeus_l', 'anconeus_r'];
      case Muscle.hands:
        return ['hands', 'hand_l', 'hand_r', 'wrist_l', 'wrist_r', 'palm_l', 'palm_r'];
      case Muscle.anteriorDeltoid:
        return ['anterior-deltoid', 'anterior_deltoid_l', 'anterior_deltoid_r'];
      case Muscle.lateralDeltoid:
        return ['lateral-deltoid', 'lateral_deltoid_l', 'lateral_deltoid_r'];
      case Muscle.posteriorDeltoid:
        return ['posterior-deltoid', 'posterior_deltoid_l', 'posterior_deltoid_r'];
      case Muscle.outerQuadricep:
        return ['outer-quadricep', 'vastus_lateralis_l', 'vastus_lateralis_r', 'iliotibial_tract_l', 'iliotibial_tract_r'];
      case Muscle.rectusFemoris:
        return ['rectus-femoris', 'rectus_femoris_l', 'rectus_femoris_r'];
      case Muscle.innerQuadricep:
        return ['inner-quadricep', 'vastus_medialis_l', 'vastus_medialis_r'];
      case Muscle.innerThigh:
        return ['inner-thigh', 'sartoris_l', 'sartoris_r'];
      case Muscle.lateralHamstrings:
        return ['lateral-hamstrings', 'biceps_femoris_l', 'biceps_femoris_r'];
      case Muscle.medialHamstrings:
        return ['medial-hamstrings', 'semitendinosus_l', 'semitendinosus_r', 'semimembranosus_1_l', 'semimembranosus_1_r', 'semimembranosus_2_l', 'semimembranosus_2_r'];
      case Muscle.gluteusMaximus:
        return ['gluteus-maximus', 'gluteus_maximus_l', 'gluteus_maximus_r'];
      case Muscle.gluteusMedius:
        return ['gluteus-medius', 'gluteus_medius_1_l', 'gluteus_medius_1_r', 'gluteus_medius_2_l', 'gluteus_medius_2_r'];
      case Muscle.gastrocnemius:
        return ['gastrocnemius', 'gastrocnemius_l', 'gastrocnemius_r'];
      case Muscle.soleus:
        return ['soleus', 'soleus_l', 'soleus_r'];
      case Muscle.tibialis:
        return ['tibialis', 'tibialis_anterior_l', 'tibialis_anterior_r', 'extensor_digitorum_longus_l', 'extensor_digitorum_longus_r', 'fibularis_longus_l', 'fibularis_longus_r', 'extensor_hallucis_longus_l', 'extensor_hallucis_longus_r'];
      case Muscle.feet:
        return ['feet', 'foot_l', 'foot_r', 'ankle_l', 'ankle_r'];
      case Muscle.upperTrapezius:
        return ['upper-trapezius', 'upper-trapzeius', 'trapezius_upper_l', 'trapezius_upper_r'];
      case Muscle.trapsMiddle:
        return ['traps-middle', 'trapezius_middle_l', 'trapezius_middle_r', 'infraspinatus_l', 'infraspinatus_r'];
      case Muscle.lowerTrapezius:
        return ['lower-trapezius', 'trapezius_lower_l', 'trapezius_lower_r'];
      case Muscle.lats:
        return ['lats', 'latissimus_dorsi_l', 'latissimus_dorsi_r'];
      case Muscle.lowerBack:
        return ['lowerback'];
      case Muscle.neck:
        return ['neck', 'sternocleidomastoid_l', 'sternocleidomastoid_r', 'platysma', 'sternohyoid'];
    }
  }

  /// Returns the parent component group.
  MuscleGroup get group {
    for (final g in MuscleGroup.values) {
      if (g.subMuscles.contains(this)) return g;
    }
    return MuscleGroup.abs; // Fallback
  }
}

/// Represents the component level (a standard named muscle like "biceps" made of multiple heads).
enum MuscleGroup {
  chest,
  abs,
  obliques,
  groin,
  biceps,
  triceps,
  forearms,
  hands,
  deltoids,
  quads,
  hamstrings,
  glutes,
  calves,
  tibialis,
  innerThigh,
  feet,
  traps,
  lats,
  lowerBack,
  neck,
}

extension MuscleGroupHelper on MuscleGroup {
  Set<Muscle> get subMuscles {
    switch (this) {
      case MuscleGroup.chest:
        return {Muscle.upperPectoralis, Muscle.midLowerPectoralis};
      case MuscleGroup.abs:
        return {Muscle.upperAbdominals, Muscle.lowerAbdominals};
      case MuscleGroup.obliques:
        return {Muscle.obliques};
      case MuscleGroup.groin:
        return {Muscle.groin};
      case MuscleGroup.biceps:
        return {Muscle.longHeadBicep, Muscle.shortHeadBicep};
      case MuscleGroup.triceps:
        return {
          Muscle.longHeadTriceps,
          Muscle.lateralHeadTriceps,
          Muscle.medialHeadTriceps
        };
      case MuscleGroup.forearms:
        return {Muscle.wristFlexors, Muscle.wristExtensors};
      case MuscleGroup.hands:
        return {Muscle.hands};
      case MuscleGroup.deltoids:
        return {
          Muscle.anteriorDeltoid,
          Muscle.lateralDeltoid,
          Muscle.posteriorDeltoid
        };
      case MuscleGroup.quads:
        return {
          Muscle.outerQuadricep,
          Muscle.rectusFemoris,
          Muscle.innerQuadricep
        };
      case MuscleGroup.hamstrings:
        return {Muscle.lateralHamstrings, Muscle.medialHamstrings};
      case MuscleGroup.glutes:
        return {Muscle.gluteusMaximus, Muscle.gluteusMedius};
      case MuscleGroup.calves:
        return {Muscle.gastrocnemius, Muscle.soleus};
      case MuscleGroup.tibialis:
        return {Muscle.tibialis};
      case MuscleGroup.innerThigh:
        return {Muscle.innerThigh};
      case MuscleGroup.feet:
        return {Muscle.feet};
      case MuscleGroup.traps:
        return {
          Muscle.upperTrapezius,
          Muscle.trapsMiddle,
          Muscle.lowerTrapezius
        };
      case MuscleGroup.lats:
        return {Muscle.lats};
      case MuscleGroup.lowerBack:
        return {Muscle.lowerBack};
      case MuscleGroup.neck:
        return {Muscle.neck};
    }
  }

  /// Returns the major body region this component belongs to.
  MajorMuscleGroup get majorGroup {
    for (final mg in MajorMuscleGroup.values) {
      if (mg.groups.contains(this)) return mg;
    }
    return MajorMuscleGroup.core;
  }
}

/// Represents the highest level body sections.
enum MajorMuscleGroup {
  arms,
  legs,
  core,
  chest,
  back,
  shoulders,
  headAndNeck,
}

extension MajorMuscleGroupHelper on MajorMuscleGroup {
  Set<MuscleGroup> get groups {
    switch (this) {
      case MajorMuscleGroup.arms:
        return {
          MuscleGroup.biceps,
          MuscleGroup.triceps,
          MuscleGroup.forearms,
          MuscleGroup.hands
        };
      case MajorMuscleGroup.legs:
        return {
          MuscleGroup.quads,
          MuscleGroup.hamstrings,
          MuscleGroup.glutes,
          MuscleGroup.calves,
          MuscleGroup.tibialis,
          MuscleGroup.innerThigh,
          MuscleGroup.feet
        };
      case MajorMuscleGroup.core:
        return {MuscleGroup.abs, MuscleGroup.obliques, MuscleGroup.groin};
      case MajorMuscleGroup.chest:
        return {MuscleGroup.chest};
      case MajorMuscleGroup.back:
        return {MuscleGroup.lats, MuscleGroup.lowerBack, MuscleGroup.traps};
      case MajorMuscleGroup.shoulders:
        return {MuscleGroup.deltoids};
      case MajorMuscleGroup.headAndNeck:
        return {MuscleGroup.neck};
    }
  }

  /// Helper to get all individual sub-muscles in this major region.
  Set<Muscle> get subMuscles => groups.expand((g) => g.subMuscles).toSet();
}

/// Provides default harmonious colors for each major muscle group.
extension MajorMuscleGroupColors on MajorMuscleGroup {
  Color get defaultColor {
    switch (this) {
      case MajorMuscleGroup.arms:
        return Colors.blue;
      case MajorMuscleGroup.legs:
        return Colors.green;
      case MajorMuscleGroup.core:
        return Colors.orange;
      case MajorMuscleGroup.chest:
        return Colors.red;
      case MajorMuscleGroup.back:
        return Colors.purple;
      case MajorMuscleGroup.shoulders:
        return Colors.teal;
      case MajorMuscleGroup.headAndNeck:
        return Colors.brown;
    }
  }
}

/// A convenience enum for semantic intensity levels. 
/// These map directly to double values for opacity.
enum MuscleIntensity {
  low(0.33),
  medium(0.66),
  high(1.0);

  final double value;
  const MuscleIntensity(this.value);
}
