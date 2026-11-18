# Repository Guidelines

## Project Structure & Module Organization

This repository is a Unity 6 project (Editor 6000.3.27f1). `Assets/` contains project content: `Scenes/` holds scenes, `Settings/` holds render pipeline and volume assets, and `TutorialInfo/` contains Unity-generated tutorial examples. Put new scripts and art under clearly named folders in `Assets/`, alongside Unity `.meta` files. `Packages/manifest.json` declares dependencies; `ProjectSettings/` stores editor and project configuration. Do not commit generated `Library/`, `Temp/`, or `Logs/` content.

## Build, Test, and Development Commands

Open the project folder in Unity Hub using the editor version in `ProjectSettings/ProjectVersion.txt`. Run the game from the Editor with **Play**; the starter scene is `Assets/Scenes/SampleScene.unity`. Build through **File > Build Profiles** after selecting the target platform. The Unity Test Framework is installed; open **Window > General > Test Runner** to run EditMode or PlayMode tests. No standalone build or test scripts are currently configured.

## Coding Style & Naming Conventions

Use C# conventions consistent with the existing Unity scripts: four spaces for indentation, PascalCase for classes and public members, and camelCase for local variables and private fields. Keep each `MonoBehaviour` in a same-named `.cs` file. Use descriptive, focused folder and asset names. Create and preserve Unity `.meta` files; move or rename assets inside Unity when possible so references remain intact.

## Testing Guidelines

There is no dedicated test directory yet. Add tests under a clearly named test folder with an assembly definition when the feature warrants them. Name test files and methods for the behavior they cover, and run the relevant EditMode or PlayMode suite in Test Runner. For scene, input, or rendering changes, also verify the affected scene in Play mode and check the Console for errors.

## Commit & Pull Request Guidelines

Git history is unavailable in this checkout, so no established commit convention could be confirmed. Use short imperative commit subjects (for example, `Add pause menu controls`). Pull requests should describe the player-visible change, list important assets or settings changed, link related issues, and include screenshots or a short recording for visual changes. Mention Unity version and test coverage.

## Configuration & Generated Files

Keep package changes in `Packages/manifest.json` and review the lockfile update together. Avoid hand-editing generated project files or committing editor caches and local user settings.

## Ponytail skill
Use the ponytail skill when coding, for its what must be used
