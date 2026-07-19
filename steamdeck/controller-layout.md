# Steam Deck Controller Layout

Steam Input mode: Legacy keyboard emulation.

## Gameplay

| Steam Deck input | Keyboard output | Purpose |
| --- | --- | --- |
| L4 | Left Arrow | Left lane |
| L5 | Down Arrow | Down lane |
| R4 | Up Arrow | Up lane |
| R5 | Right Arrow | Right lane |
| D-pad left | Left Arrow | Left lane helper |
| D-pad down | Down Arrow | Down lane helper |
| D-pad up | Up Arrow | Up lane helper |
| D-pad right | Right Arrow | Right lane helper |
| X | Left Control | Quit/back in gameplay |
| B | Slash | Restart song |

## Menus

| Steam Deck input | Keyboard output | Purpose |
| --- | --- | --- |
| D-pad | Arrow keys | Navigate |
| Start | Enter | Confirm |
| Select | Escape | Cancel where supported |
| A | Enter | Confirm |
| Y | Escape | Cancel where supported |
| L1 | Page Up | Fast song-list navigation |
| R1 | Page Down | Fast song-list navigation |
| Right trackpad | Mouse | Pointer fallback |
| Right trackpad click | Left Mouse | Click fallback |

This layout makes L4, L5, R4, and R5 the primary rhythm controls while keeping the game on its existing keyboard input path. It avoids a native Steamworks dependency, which would require a separate AIR native extension before the game could consume Steam Input actions directly.
