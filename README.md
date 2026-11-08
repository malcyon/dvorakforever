# Dvorak Forever

<!-- One or two sentences: what the addon does and who it is for. -->
A World of Warcraft addon for players who type Dvorak. It moves every key binding to
the key in the same physical place, so movement stays under your left hand
(W A S D become , A O E) while chat still types Dvorak.

<!-- Screenshot of the options page: media/screenshot-options.png -->

## Why

<!-- The game binds keys by the character your keyboard layout types, not by
the key's position. Explain the problem a Dvorak player hits with the default
bindings, and why switching the system layout to QWERTY isn't a fix (chat). -->

## Features

- Switches every binding between QWERTY and Dvorak positions in one click,
  including Shift, Ctrl, Alt and Mac Command combinations, spells, macros and
  action bars.
- Switching back restores the original bindings exactly.
- `/` stays on `/`, so it still opens chat with a slash command.
- Works on account-wide or character-specific bindings, whichever the Key
  Bindings screen uses.

## Installation

<!-- CurseForge link once the project exists. -->
1. Install from CurseForge, or download the zip from
   [Releases](https://github.com/malcyon/dvorakforever/releases).
2. Unzip it into the `Interface/AddOns/` folder of your game version
   (`_forever_`, `_retail_` or `_classic_era_`), so the folder is
   `AddOns/DvorakForever`.

## Usage

- **Options → AddOns → Dvorak Forever**: pick the keyboard layout from the
  dropdown.
- `/dvorak dvorak`: move bindings to Dvorak positions.
- `/dvorak qwerty`: move them back.
- `/dvorak keys`: print the name the game gives each key you press, to check
  your keys. Type it again to stop.
- `/dvorak`: show the current layout and open the options page.

## Good to know

- Bindings can't be changed in combat; the addon tells you and changes nothing.
- The game saves the moved bindings like any change on the Key Bindings screen.
  Nothing is re-applied at login, so switch once.
- With "Character Specific Key Bindings" ticked, switch on each character.
- On first use the addon works out your current layout from the movement keys
  (Move Forward, Move Backward, Strafe Right).

## Supported games

WoW Forever, Retail and Classic Era.

## Reporting problems

<!-- GitHub Issues, or the CurseForge comments. -->
Please open an issue on
[GitHub](https://github.com/malcyon/dvorakforever/issues).

## License

Dvorak Forever is free software under the
[GNU General Public License v3.0 or later](LICENSE).
