# R3 OpenFL Port Foundation

This directory starts the free cross-platform replacement path for the AIR runtime. It is intentionally separate from the existing ActionScript/AIR project so the current 2.0.4 build can keep working while the game is ported in phases.

## Runtime Choice

The chosen path is Haxe + OpenFL + Lime:

- Haxe is the free cross-platform language/toolchain.
- OpenFL keeps a Flash-style display API, which is the closest free fit for the current ActionScript codebase.
- Lime handles platform windows, rendering, input, audio, assets, and native targets.
- The same source can target HTML5 for quick validation and native Windows, macOS, and Linux for final desktop builds.

## Local Toolchain

This machine currently uses:

- Haxe: `C:\Dev\tools\haxe-4.3.7`
- Neko: `C:\Dev\tools\neko-2.4.1`
- Haxelib repository: `C:\Dev\tools\haxelib`
- Lime: `8.3.2`
- OpenFL: `9.5.2`

Build the scaffold:

```powershell
.\scripts\openfl-build.ps1 -Target html5
```

Native desktop builds use the same script, but each platform still needs a free native compiler toolchain:

```powershell
.\scripts\openfl-build.ps1 -Target windows
.\scripts\openfl-build.ps1 -Target linux
.\scripts\openfl-build.ps1 -Target mac
```

## Steam Deck Controls

The Steam Deck package should map:

- L4 to `Left`
- L5 to `Down`
- R4 to `Up`
- R5 to `Right`

The OpenFL scaffold accepts those arrow keys now, plus desktop fallback keys `A`, `S`, `K`, and `L`.

## Porting Plan

1. Move reusable game state, timing, settings, and score logic into Haxe modules.
2. Replace AIR-only file/cache/network APIs with Lime/OpenFL adapters.
3. Port the rhythm renderer to OpenFL display/OpenGL-backed drawing.
4. Port audio and visual latency controls with platform-specific validation.
5. Port playlist/song loading, noteskins, and local settings.
6. Add native packaging for Windows, Linux/Steam Deck, and macOS.

The current `Main.hx` is a compile-test and input/rendering foundation. It is not the full game yet.

## Full Game Port

The full ActionScript conversion is tracked in [PORTING_STATUS.md](PORTING_STATUS.md). Regenerate the broad converted tree with:

```powershell
.\scripts\openfl-port-as3.ps1
.\scripts\openfl-generate-asset-stubs.ps1
```

Then typecheck the generated tree and compatibility layer with:

```powershell
.\scripts\openfl-check-port.ps1
```

`openfl-check-port.ps1` uses the real OpenFL/Lime native build path with the generated source forced into the compilation graph. It is expected to fail until the remaining ActionScript semantics are ported, but it now reports the actual Haxe type backlog instead of silently passing.
