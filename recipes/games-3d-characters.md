# Games, 3D and characters (Unity, Unreal, Godot, Blender, Character Creator / iClone)

## What it's for in this workflow

Game and 3D work mixes code (scripts, shaders, build pipelines) with large binary assets made in desktop apps. The
agents are most useful on the code, the build and test pipeline, asset validation and the glue between tools
(export → import → build); the creative apps stay the user's.

## Way in

| Tool | Way in |
|---|---|
| Unity | Editor on the computer; **batch mode** from the command line for builds and tests: `Unity -batchmode -quit -projectPath <path> -executeMethod <BuildScript.Method> -logFile <file>`, tests with `-runTests -testPlatform EditMode` (check Unity's command-line docs for your version) |
| Unreal Engine | Editor on the computer; `UnrealEditor-Cmd` and `RunUAT BuildCookRun` for builds and automation tests |
| Godot | Very scriptable: `godot --headless --export-release "<preset>" <output>`; runs in Docker for builds and tests |
| Blender | `blender -b <file.blend> -P <script.py>` runs Python headless; renders with `-f <frame>`; runs in Docker for CPU work |
| Character Creator / iClone (Reallusion) | Windows desktop apps. Recent versions include a Python scripting API inside the app (check Reallusion's docs for your version); exports (FBX, USD and others) to a folder; Reallusion's engine plugins (Auto Setup for Unity/Unreal) on the engine side |
| Asset stores, launchers | The user's accounts; agents don't buy or download paid assets |

**A pipeline that works for character tools:** the user (or an in-app Python script the agent writes and the user
runs) exports characters and animations into the project's `Assets/Import/` (or equivalent) folder → the engine
imports them (batch mode, or the engine's auto-import) → an agent-run validation checks the export (file present,
expected bone names, polygon and texture budgets, scale) with Blender headless or a small Python script → the build
runs → results recorded. Computer use (screen control) can drive the desktop app for short, repeatable steps when
there's truly no other way in; it's the last resort.

## Install

- Engines and creative apps on the computer from the vendors' own launchers (Unity Hub, Epic Games Launcher,
  Reallusion Hub, blender.org). The user signs in and activates licences.
- Godot and Blender can also run in Docker (official downloads into the runner image). Unity and Unreal in containers
  are possible (community images such as GameCI for Unity) but involve licence activation: the user decides, and you
  read the current licence terms before setting it up.
- GPU rendering in Docker needs the NVIDIA container runtime (`--gpus all`) and an NVIDIA card; CPU rendering works
  everywhere.

## Git for game projects

- **Git LFS** for large binaries (textures, models, audio, video): `git lfs install`, then `git lfs track "*.fbx"
  "*.png" "*.wav" ...` in `.gitattributes`. GitHub's LFS has storage and bandwidth quotas: check the current limits
  before pushing gigabytes.
- **Ignore generated folders:** Unity `Library/`, `Temp/`, `Logs/`, `Obj/`, `Build/`; Unreal `Binaries/`,
  `Intermediate/`, `Saved/`, `DerivedDataCache/`; Godot `.godot/`. Use the engine's standard `.gitignore`.
- Unity: Version Control mode "Visible Meta Files" and Asset Serialization "Force Text", so scenes and prefabs diff
  and merge.
- Very large teams or repositories sometimes use Perforce or Unity Version Control instead of Git; this kit's
  workflow assumes Git.

## Guardrails worth setting

- The agents don't edit scenes, prefabs or binary assets by hand-editing files unless the format is text and the user
  agrees; they change code and pipeline scripts, and the user works in the editor.
- Asset licences: what the user may ship (exported characters, marketplace assets, motion packs) depends on their
  licences. The agents note where an asset came from; the user checks the licence.
- One agent drives a desktop app at a time; nobody edits a scene while a batch build runs on the same project.

## Prove it

A headless build or test run from the command line, its log saved to the evidence folder. For a character pipeline:
one exported character goes through validation and appears in a test scene of the build.

## Checks to add

Compile/batch build, the engine's test runner (EditMode/PlayMode, Unreal automation, GUT for Godot), asset validation
(names, budgets, missing references), and a build-size report so growth is visible.

## Traps

- Engine logs are huge: write them to files, print summaries.
- The editor holds locks on project files: close it (or don't run batch mode on the same project) during builds.
- Long paths on Windows: engines nest deeply; keep projects near the drive root of the projects folder and set
  `core.longpaths`.
- Exports saved to the app's default folder instead of the project: check where the file actually landed before
  assuming the export failed or succeeded.

## Checked against

Unity Manual (command-line arguments), Unreal Engine docs (BuildCookRun, automation), Godot docs (exporting from the
command line), Blender manual (command line), Reallusion's documentation for Character Creator/iClone Python and
export. Versions differ a lot: record the versions used.
