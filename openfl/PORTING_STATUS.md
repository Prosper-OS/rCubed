# OpenFL Full Game Port Status

The full game port is being built as a separate OpenFL/Haxe source tree so the existing AIR build remains intact.

## Current Porting Strategy

- Keep `src/` as the original ActionScript/AIR source of truth during the migration.
- Generate a broad Haxe conversion under `openfl/ported/` with `scripts/openfl-port-as3.ps1`.
- Keep hand-written OpenFL compatibility and replacement code under `openfl/src/`.
- Use `scripts/openfl-check-port.ps1` to typecheck the full generated tree and expose the next compile blocker.
- Keep `scripts/openfl-build.ps1` for the currently runnable OpenFL scaffold.

## Known Runtime Replacement Areas

- `blooddy_crypto.swc` is being replaced by Haxe/OpenFL code under `openfl/src/by/blooddy/crypto`.
- AIR filesystem and desktop APIs are being replaced by `openfl/src/r3/air` adapters.
- `as3hx` is used as a conversion tool only. Runtime compatibility shims now live in `openfl/src/as3hx`, `openfl/src/FastXML.hx`, and `openfl/src/FastXMLList.hx` so the port is not tied to the old Haxe 3-only haxelib runtime.
- SWC-only timeline symbols currently have OpenFL placeholder classes generated under `openfl/src/assets` by `scripts/openfl-generate-asset-stubs.ps1`.
- `flash.*` imports in converted files are rewritten to `openfl.*` where OpenFL provides a compatible API.
- AIR-only behavior such as native process launching, updater behavior, application storage, and SWF timeline assets still needs real OpenFL-native implementation.

## Current Checkpoint

- `scripts/openfl-port-as3.ps1` converts 444 of 446 ActionScript source files into `openfl/ported`.
- The two source files not emitted by `as3hx` are covered by hand-written replacements where needed so far:
  - `com.flashfla.parser.YAML` is replaced by `openfl/src/com/flashfla/parser/YAML.hx`.
  - `com.flashfla.utils.Sprintf` is replaced by `openfl/src/com/flashfla/utils/Sprintf.hx`.
- The runnable OpenFL scaffold still builds as a native Windows executable with `scripts/openfl-build.ps1`.
- The strict full-tree check now reaches broad Haxe type-porting errors instead of syntax/import scaffolding errors. The first current blocker is GreenSock AS3 truthiness in `openfl/ported/com/greensock/core/Animation.hx`.

## Commands

```powershell
.\scripts\openfl-port-as3.ps1
.\scripts\openfl-generate-asset-stubs.ps1
.\scripts\openfl-check-port.ps1
.\scripts\openfl-build.ps1 -Target windows -Configuration release
```

The generated Haxe tree is not expected to fully compile yet. The first goal is to make the typecheck failure list shrink in tracked, repeatable steps until the OpenFL app can use the ported `Main` instead of the temporary `r3.Main` scaffold.
