# Supersonic RC recovery — 2026-11-14

## Source preservation

Original attachments copied to `originals/`; source and copies had matching SHA-256:

- `1-game.dcr`: `0fb6ce24e40c712400a2f1b7015220aba0165dbab9df4e910f144cddf31993af`
- `2-GUILibrary.cct`: `7d1efa3a76666c814b0dfd326ffdac49571bb468f157744e673f1e8c5e14f855`
- `3-SupersonicRC.exe`: `9be63c59de40bc8b781c984a7ac6e3211797f2eb9fc84038b7d247cacb3f7736`

## Methods and boundaries

REA/Ghidra statically inspected the executable: x86 PE, 296 recognized procedures and 249 defined strings (evidence `ev_0173f4170e3050a3f17580bec589559d5267284da7268eccc8e271a857f8f3b7`); PE resources were inventoried (evidence `ev_eb2de7f1cf898767e912436f3582cb5340534f56243802b5c7d07299d2860081`). Those inventories do not prove runtime behavior. Strings identify Director/Shockwave player components. Loaded executable sections are small relative to the file; game logic is evidenced in the Director movie.

Used LibreShockwave source commit `4bc93bf622f498a0296aed5a34d6d28abaa307b2`, built locally with CMake on macOS; its asset extractor required a local namespace fix (`apps::decodeJpeg` to `libreshockwave::apps::decodeJpeg`). No original bytes were altered. Extractor output is in `extracted/`, with manifests, decompiled scripts and resolved bytecode listings. Decompilation may contain errors or incomplete interpretations; compare bytecode and runtime before treating behavior as exact.

## Recovery results

- Game: 118 members; extractor reports 35 PNGs, 4 text outputs, 32 sounds, 110 raw chunks, 41 script outputs, zero reported extraction errors. Movie metadata reports 640 x 480 and tempo 40.
- GUI cast: 71 members; 28 PNGs, 3 text outputs, 37 script outputs, 31 raw chunks, zero reported extraction errors.
- Game scripts include car, wheels, driving manager, Havok manager, camera, stunt detector, timer, checkpoint and pickup handling, and five mode scripts. Script names and conditional logic are evidence of intended behavior, not proof of successful gameplay.
- Selection script lists Free Driving, Checkpoint Chase, Stunt Rally, Scavenger Hunt and Supersonic Challenge. Script text indicates sequential unlocks. Free Driving references two laps under 2:30; later scripts reference stunt and scavenger goals. Check the actual game and decompiler output before accepting all details as final.
- XMED raw media includes `3d` (776 KiB, starts `3DEM` and contains `IFX`), `holypolycrap` (177 KiB, referenced as a source for a car model), and `havok` (141 KiB). These are promising 3D/physics inputs, not yet decoded meshes or verified complete scenes.

## Unresolved and next work

1. Parse 3D and physics chunks and attempt conversion of geometry, materials, textures and world transforms; validate exported results visually and against runtime.
2. Inspect cast linkage and external dependencies; attachments have not been proved complete. Recover original filenames when setting up playback.
3. Run the original in an isolated suitable Windows environment, with networking disabled, and document controls, screens, camera, driving and each mode. No executable has been run in this investigation.
4. Build a one-car, one-environment prototype informed by scripts and observed behavior; test on target devices and browsers before selecting final cross-platform assumptions.

## Recovered 3D scene — 2026-11-15

The unwrapped IFX data was decoded locally with the browser-side W3D parser delivered by Innerscene's W3D-to-OBJ tool (https://www.innerscene.com/tools/w3d-to-obj). The parser and its downloaded site code remain temporary dependencies, not part of this project. The recovered scene JSON and image bytes are under `recovered-3d/` and derived from the supplied game movie. The warehouse contains 102 decoded mesh instances, 5,536 triangles and 46 extracted textures; the car contains five mesh instances, 2,721 triangles and 13 textures. Counts are decoder output, not proof of complete or correct recovery. Materials, transforms, UVs and geometry need comparison to original gameplay.

The first SceneKit integration compiled and rendered recognizable original warehouse geometry and textures in the Duo simulator (`../evidence/recovered-world-first-render.png`). Its camera/car placement is incorrect: the car was not visible; some textures appeared inverted and lighting was overexposed. It is not yet a playable faithful reconstruction. The renderer retains planar placeholder motion, with no working environment collisions or jump physics. No physical-device install was performed for this integration.

## Texture import investigation

The decoder output was checked with Foundation's JSON parser. Casting every numeric array directly to `[Float]` dropped all five car UV arrays, most normal arrays, and three world position arrays; decoding as `[Double]` before conversion fixed that loss. Correcting the UV vertical orientation makes the warehouse banners legible. The resulting simulator render shows the original textured car in the original warehouse (`../evidence/recovered-car-warehouse-uvfix.png`). The model, placement, camera and materials still require comparison to actual original-game execution. A single-ray floor-contact experiment is under development; it is not the original four-wheel suspension, and collision, jumps and handling have not been validated.

## Contact and request-interruption work — 2026-11-15

A first SceneKit segment-ray approach allowed the car to fall below the warehouse; simulator telemetry recorded `ground: null` and negative height. It was replaced with a spatial index generated from recovered triangles by `tools/generate_ground.py`, with runtime calculation in `App/GroundIndex.swift`. An independent spawn-height check returned 2.016427 in scene units. An automated simulator run subsequently recorded movement from z=49.67 to z=31.97, with a detected surface in both samples. This does not prove all slopes, gaps or ramp behavior.

A separate near-vertical triangle index and `App/WallIndex.swift` provide provisional horizontal contact. A synthetic triangle crossing and clear-path check passed; the integrated simulator build compiled and launched, but actual in-game wall response has not yet been verified. The handling is still a single-point approximation without original four-wheel suspension or validated jump physics. Original car-loop and music-loop assets are included experimentally; audible playback and mixing have not been verified.

Repeated Codex interruptions were HTTP 400 responses from the Codex response endpoint with only a generic `Bad Request` body. Relevant request IDs and timestamps are in `../evidence/codex-request-errors.md`; underlying cause is unknown.

In the integrated wall-index simulator run, continuous automated throttle progressed to x=37.9017, z=7.9924 and then two samples 480 frames apart showed speed 0 at the same location while the ground height remained detected. This is consistent with wall contact in that single path; it does not validate collision shape, visual contact, reverse escape, other walls or ramps.
