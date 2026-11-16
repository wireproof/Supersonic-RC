# Supersonic RC restoration

An in-progress reconstruction of the original LEGO Supersonic RC Free Driving experience for iPhone and iPad, with additional platforms planned. The original warehouse, car, textures, audio and Lingo scripts were recovered from the supplied game files. The current development work focuses on reproducing the original experience before remastering its graphics.

## Current state

The recovered warehouse and textured car have rendered together in an iPhone Duo simulator. Experimental floor and wall contact use geometry recovered from the original scene. Four-point terrain support, approximate ramp motion, and driving dynamics are under development; these do not reproduce the original physics yet. Touch controls and preliminary keyboard and controller mappings are implemented, but the external controls still need hands-on testing. Mouse support is planned. Suspension, ramp and jump behavior, full collisions, camera behavior, sound mixing and gameplay still need work and comparison against the original.

The experimental warehouse build 0.2.1 (build 4) is installed for testing on the iPhone and iPad. Its touch steering and faster speed tuning await physical-device feedback. The original handling, collisions, camera, audio and gameplay are not yet fully reproduced; this is not a finished remaster.

## Project layout

- `App/`: iOS application source and current recovered game resources.
- `Assets/`: approved icon source and early artwork experiments.
- `research/`: preserved supplied files, recovered assets, scripts and investigation notes.
- `tools/`: utilities used to prepare recovered game geometry.
- `delivery/`: device delivery records.

The iOS project is generated from `project.yml` using XcodeGen. Simulator and device builds require Xcode; device distribution additionally requires suitable signing. The application bundle identifier is `com.wireproof.legosr`.

See [research/RECOVERY.md](research/RECOVERY.md) for the recovery methods, evidence, and known limitations.
