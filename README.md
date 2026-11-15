# Supersonic RC restoration

An in-progress reconstruction of the original LEGO Supersonic RC Free Driving experience for iPhone and iPad, with additional platforms planned. The original warehouse, car, textures, audio and Lingo scripts were recovered from the supplied game files. The current development work focuses on reproducing the original experience before remastering its graphics.

## Current state

The recovered warehouse and textured car have rendered together in an iPhone Duo simulator. Experimental floor and wall contact use geometry recovered from the original scene. The original four-wheel suspension, ramp and jump behavior, full collisions, camera behavior, sound mixing and gameplay still need work and comparison against the original. Keyboard, mouse and controller support are planned.

The separately packaged iOS version 0.1.1 (build 2) is an early placeholder playground, not the recovered warehouse build. It has been installed on the owner's iPhone Duo and iPad Pro. The owner observed the prototype running on the Duo; the iPad installation has not been launched or visually tested. The newer warehouse integration has only been built and tested experimentally in the simulator and is not ready for release.

## Project layout

- `App/`: iOS application source and current recovered game resources.
- `Assets/`: approved icon source and early artwork experiments.
- `research/`: preserved supplied files, recovered assets, scripts and investigation notes.
- `tools/`: utilities used to prepare recovered game geometry.
- `delivery/`: device delivery records.

The iOS project is generated from `project.yml` using XcodeGen. Simulator and device builds require Xcode; device distribution additionally requires suitable signing. The application bundle identifier is `com.wireproof.legosr`.

See [research/RECOVERY.md](research/RECOVERY.md) for the recovery methods, evidence, and known limitations.
