# CodeVault Windows installer

## Build the installer

From the repository root, run:

```powershell
.\scripts\build_windows_installer.ps1
```

The script reads the application version from `pubspec.yaml`, builds the current Flutter Windows release, and packages the complete runtime into one installer file:

```text
dist\windows\CodeVault-<version>-Windows-x64.exe
```

Only this installer EXE needs to be shared. The recipient runs it to install CodeVault, create shortcuts, and optionally launch the application.

## One-time prerequisites

- Flutter with Windows desktop support
- Visual Studio with **Desktop development with C++**
- Inno Setup 6

Install Inno Setup for the current Windows user with:

```powershell
winget install --id JRSoftware.InnoSetup --exact --scope user
```

The build script automatically locates standard per-user and system-wide Inno Setup installations.

## Release a new version

1. Update `version` in `pubspec.yaml`, for example `1.1.0+2`.
2. Run `.\scripts\build_windows_installer.ps1`.
3. Share the newly generated EXE from `dist\windows`.

The semantic version is used in the installer filename and Windows metadata. The build number is added to the four-part Windows file version.

## Application icon

The editable icon source is `windows\runner\resources\codevault_icon.svg`. The Windows application embeds `windows\runner\resources\app_icon.ico`, and the Inno Setup definition uses the same icon for the installer. Installed Start Menu and desktop shortcuts inherit the icon from `codevault.exe`.

After changing the SVG, regenerate the multi-resolution ICO with ImageMagick:

```powershell
magick -background none windows\runner\resources\codevault_icon.svg -define icon:auto-resize=256,128,64,48,32,24,16 windows\runner\resources\app_icon.ico
```

Then run the installer build script again.

## 32-bit Windows limitation

Flutter 3.38.7 does not provide a Windows x86 engine or a `windows-x86` build target. CodeVault therefore cannot produce a genuine 32-bit Windows application or installer. The generated x64 installer supports 64-bit x86 Windows only.

Changing Inno Setup to produce an x86-labeled installer would not solve this: the bundled Flutter engine and native plugins would remain 64-bit and could not start on 32-bit Windows. Supporting 32-bit Windows would require a separate non-Flutter desktop implementation or an unsupported custom x86 Flutter engine and x86 builds of every native dependency.

## Distribution note

The installer is unsigned unless a Windows code-signing certificate and signing step are configured. Windows SmartScreen can warn recipients about unsigned downloads even when the installer is valid.