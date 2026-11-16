# Mobile apps (Android, iOS, Flutter, React Native / Expo)

## What it's for in this workflow

Builds and tests of the app run the same way every time, signing keys stay with the user, and store submissions
happen only on the user's go.

## Way in

| Platform | Headless (Docker or CLI) | Needs the computer itself |
|---|---|---|
| Android | Gradle builds (APK/AAB), unit tests, lint, in a JDK + Android SDK image | The emulator (needs hardware acceleration), USB devices (`adb`), Android Studio |
| iOS | — (Apple's tools run only on macOS) | Xcode, `xcodebuild`, simulators (`xcrun simctl`), devices; a Mac is required |
| Flutter | `flutter analyze`, `flutter test`, Android builds in Docker | iOS builds (Mac), emulators, devices |
| React Native / Expo | JS tests and lint; Android builds after `npx expo prebuild` with Gradle | Emulators, devices, iOS builds (Mac). Expo's EAS Build is a cloud service with its own plans and limits: the user decides whether to use it |

## Install

- **Android SDK in Docker:** a JDK image at the project's Java version (e.g. Eclipse Temurin 17), plus Google's
  Android command-line tools from developer.android.com; `sdkmanager` installs exactly the platform and build-tools
  versions in the project's `build.gradle`. Accepting the SDK licences is the user's agreement: show them
  `sdkmanager --licenses` output and let them confirm. Cache Gradle and the SDK in a Docker volume, not the image, so
  rebuilds are fast.
- **On the computer:** Android Studio (includes the emulator) if the user wants to run the app; on macOS, Xcode from
  Apple, then `xcode-select --install` and `sudo xcodebuild -license` (the user accepts).
- **Flutter:** pin the Flutter version from the project (`.fvmrc`, `pubspec.yaml` environment, or the CI file) in the
  image.
- Big SDKs take tens of GB. Check free disk first (step 1's report) and keep the SDKs in one known folder or volume.

## Sign-in and secrets

- **Signing keys** (Android keystore, Apple certificates and provisioning profiles) never go in Git. They stay with
  the user: in their password manager, the OS keychain, or GitHub secrets for release jobs. Local debug builds use
  debug signing.
- Play Console and App Store Connect are the user's accounts. API keys for automated uploads (if wanted) are created by
  the user with the narrowest role and stored as secrets.

## Guardrails worth setting

- Agents build, test and prepare release notes and screenshots; **store submission and release to users happen only
  on the user's go** (store reviews are public, releases reach real phones).
- Version codes/build numbers only go up; record the mapping if the user adopted the phase/version rule (the store's
  numeric build number is the "native update version").
- Never install a build on the user's own phone without asking.

## Prove it

Android: `./gradlew assembleDebug test` in Docker, then (with the user's OK) install the APK on an emulator or device
and open it. iOS (Mac): `xcodebuild -scheme <scheme> -destination 'platform=iOS Simulator,name=<device>' test`.

## Checks to add

Lint (Android Lint / `flutter analyze` / ESLint), unit tests, a release build (unsigned or debug-signed), and for apps
with a backend, the API tests. Instrumented/UI tests need an emulator or device: run them on the computer, record the
results the same way.

## Traps

- Emulators inside Docker on Windows usually lack hardware acceleration and crawl: keep emulators on the computer.
- Gradle daemons eat memory: give the build container its own cap and `org.gradle.jvmargs` to match.
- Windows paths and the SDK: keep the SDK path short (deep paths break some tools); `core.longpaths` in Git.
- An app's `local.properties` holds the SDK path on that machine: git-ignored.

## Checked against

developer.android.com (command-line tools, sdkmanager), Apple's Xcode docs, flutter.dev, docs.expo.dev. Verify the
versions the project needs at setup time.
