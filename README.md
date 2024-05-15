# Tiny Pixel Planets TU4.1 (v0.4.1 / Godot 4 port)
This branch is for my unstable development process in porting Tiny Pixel Planets from Godot 3 to Godot 4 (a lot of work). Once finished with porting to godot 4 I will focus on some bug fixes/ small improvements before beginning TU5.

## Game fixes so far
- Fixed Gender buttons not changing after closing and opening a new save again
- Fixed item data not showing when hovering over inventory item
- Removed the "Exotic wear" achievement (there is no rhodonite armor)
- Fixed star system nav visited planets not saving when leaving star system
- Fixed clicking on "One small step" achievement crashing the game if any other achievement is unlocked before it
- Fixed being able to see below the background

## Features
- Action 1 and Action 2 slots now reflect the correct keybinds
- Snow and Rain now collides with blocks
- When you die you now spawn on the planet you died on, rather than the first planet you spawned on (This was annoying if you were in another star system and didn't bookmark the planet you died on)
- You can now click on planet icons in the Star system nav, which will show you how to get to the planet
- Now able to place blocks in water and on flowers
- Now able to close inventory and achievement menu by pressing the repective keybind
- Now able to change the inventory keybind
- Revamped command input. Now the command console will list possible commands and paramaters based on what it typed
- Added signs! Customize your own messages using signs
- New tutorial and Shopping center to go with the new signs

## Dev notes
- TU4 and before saves will no longer work in TU4.1 due to Godot 4’s changes in file storage
