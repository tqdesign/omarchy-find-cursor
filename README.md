# Find Cursor

Double-tap **Ctrl** and rings collapse onto the mouse pointer, like Windows'
*Show location of pointer when I press the CTRL key*. Built as an
[Omarchy](https://omarchy.org/) shell plugin for Hyprland.

- Two rings in the theme accent color, with a dark halo so they show on any background.
- Click-through and keyboard-transparent; it never steals focus.
- Draws only on the monitor the pointer is on.

## Install

```bash
omarchy plugin add https://github.com/tqdesign/omarchy-find-cursor.git --enable
```

Put the launcher on your `PATH`:

```bash
ln -s ~/.config/omarchy/plugins/tqdesign.find-cursor/bin/find-cursor ~/.local/bin/find-cursor
```

Then hook up double-tap Ctrl by adding this line to `~/.config/hypr/hyprland.lua`
(after the Omarchy defaults are loaded):

```lua
dofile(os.getenv("HOME") .. "/.config/omarchy/plugins/tqdesign.find-cursor/hypr/find-cursor.lua")
```

Validate with `hyprctl reload && hyprctl configerrors`.

Prefer a regular key? Skip the Lua snippet and bind the launcher instead:

```lua
o.bind("SUPER + CTRL + M", "Find cursor", "find-cursor")
```

## How it works

`bin/find-cursor` reads the pointer position from `hyprctl cursorpos` and
summons the overlay:

```bash
omarchy-shell shell summon tqdesign.find-cursor '{"x":1200,"y":800}'
```

`Overlay.qml` maps a transparent layer-shell surface with an empty input region
on the matching screen, plays the animation, and hides itself.

## Tuning

Edit the properties at the top of `Overlay.qml` (the shell reloads on save):

| Property | Default | Meaning |
| --- | --- | --- |
| `ringCount` | `2` | Number of rings |
| `ringDelayMs` | `140` | Delay between rings |
| `shrinkMs` | `520` | How long each ring takes to collapse |
| `startRadius` | `130` | Starting ring radius in px |
| `endRadius` | `6` | Final ring radius in px |

The double-tap window is `DOUBLE_MS` in `hypr/find-cursor.lua`.

## License

MIT
