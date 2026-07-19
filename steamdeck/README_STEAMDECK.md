# R3 Steam Deck Native Build

This folder contains the Steam Deck packaging and control notes for a native SteamOS/Linux x86_64 bundle.

## Build Prerequisites

- SteamOS/Linux x86_64, or WSL2 Ubuntu from Windows for packaging.
- A commercial HARMAN AIR SDK for Linux x86_64. Set `AIR_HOME` to the extracted SDK directory.
- Java 17 or newer.
- Node.js if you want the script to compile the release SWF before packaging.
- `SCORE_SAVE_SALT` for official release-compatible scoring. The script defaults to the 2.0.4-compatible salt used by this branch when it is not provided.

The Linux AIR SDK is not part of the free AIR tier. This package target intentionally fails if `AIR_HOME` does not point at a Linux AIR SDK with `lib/adt.jar`. Put the HARMAN license file where the SDK expects it before packaging, or run with `AIR_REFRESH_LICENSE=1` / `AIR_LICENSE_DEV_ID=<id>` to ask ADT to refresh license status.

## Build From Windows

```powershell
.\scripts\package-steamdeck.ps1 -AirHome "C:\path\to\AIRSDK_Linux_x86_64" -Version "2.0.4"
```

## Build From Linux or WSL

```bash
AIR_HOME=/path/to/AIRSDK_Linux_x86_64 ./scripts/package-steamdeck.sh --version 2.0.4
```

The package is written to:

```text
dist/steamdeck/R3Air.<version>.SteamDeck.Native.x86_64.zip
```

## Steam Deck Launch

Launch `r3-steamdeck.sh` from the package root. It sets Deck-friendly graphics environment defaults and then runs the native `R3` executable produced by AIR.

For a non-Steam install:

1. Copy the unzipped package to the Deck.
2. In Desktop Mode, add `r3-steamdeck.sh` as a non-Steam game.
3. Return to Gaming Mode and pick the controller layout below.

For a Steam depot, use `r3-steamdeck.sh` as the Linux launch executable.

## Recommended Steam Deck Controls

Use Steam Input Legacy Mode keyboard emulation.

Primary gameplay lanes:

- L4: Left Arrow
- L5: Down Arrow
- R4: Up Arrow
- R5: Right Arrow

Chord helpers:

- D-pad left: Left Arrow
- D-pad down: Down Arrow
- D-pad up: Up Arrow
- D-pad right: Right Arrow

Menus and utility:

- Start: Enter
- Select: Escape
- L1: Page Up
- R1: Page Down
- X: Left Control, quit/back in gameplay
- B: Slash, restart in gameplay
- A: Enter, confirm
- Y: Escape, cancel where supported
- Right trackpad: Mouse
- Right trackpad click: Left Mouse

Mapping L4, L5, R4, and R5 to the four lane keys keeps the rhythm input on the Deck's rear buttons while preserving the existing keyboard code path.
