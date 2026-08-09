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
        return ['upper-pectoralis'];
      case Muscle.midLowerPectoralis:
        return ['mid-lower-pectoralis'];
      case Muscle.upperAbdominals:
        return ['upper-abdominals'];
      case Muscle.lowerAbdominals:
        return ['lower-abdominals'];
      case Muscle.obliques:
        return ['obliques'];
      case Muscle.groin:
        return ['groin'];
      case Muscle.longHeadBicep:
        return ['long-head-bicep'];
      case Muscle.shortHeadBicep:
        return ['short-head-bicep'];
      case Muscle.longHeadTriceps:
        return ['long-head-triceps'];
      case Muscle.lateralHeadTriceps:
        return ['lateral-head-triceps', 'later-head-triceps'];
      case Muscle.medialHeadTriceps:
        return ['medial-head-triceps'];
      case Muscle.wristFlexors:
        return ['wrist-flexors'];
      case Muscle.wristExtensors:
        return ['wrist-extensors'];
      case Muscle.hands:
        return ['hands'];
      case Muscle.anteriorDeltoid:
        return ['anterior-deltoid'];
      case Muscle.lateralDeltoid:
        return ['lateral-deltoid'];
      case Muscle.posteriorDeltoid:
        return ['posterior-deltoid'];
      case Muscle.outerQuadricep:
        return ['outer-quadricep'];
      case Muscle.rectusFemoris:
        return ['rectus-femoris'];
      case Muscle.innerQuadricep:
        return ['inner-quadricep'];
      case Muscle.innerThigh:
        return ['inner-thigh'];
      case Muscle.lateralHamstrings:
        return ['lateral-hamstrings'];
      case Muscle.medialHamstrings:
        return ['medial-hamstrings'];
      case Muscle.gluteusMaximus:
        return ['gluteus-maximus'];
      case Muscle.gluteusMedius:
        return ['gluteus-medius'];
      case Muscle.gastrocnemius:
        return ['gastrocnemius'];
      case Muscle.soleus:
        return ['soleus'];
      case Muscle.tibialis:
        return ['tibialis'];
      case Muscle.feet:
        return ['feet'];
      case Muscle.upperTrapezius:
        return ['upper-trapezius', 'upper-trapzeius'];
      case Muscle.trapsMiddle:
        return ['traps-middle'];
      case Muscle.lowerTrapezius:
        return ['lower-trapezius'];
      case Muscle.lats:
        return ['lats'];
      case Muscle.lowerBack:
        return ['lowerback'];
      case Muscle.neck:
        return ['neck'];
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
