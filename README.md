# Tiny Pixel Planets TU4.1 (v0.4.1 / Godot 4 port)
This branch is for my unstable development process in porting Tiny Pixel Planets from Godot 3 to Godot 4 (a lot of work). Once finished with porting to godot 4 I will focus on some bug fixes/ small improvements before beginning TU5.

## Game fixes so far
- Fixed Gender buttons not changing after closing and opening a new save again

## Features
- Action 1 and Action 2 slots now reflect the correct keybinds
- Snow and Rain now collides with blocks
- When you die you now spawn on the planet you died on, rather than the first planet you spawned on (This was annoying if you were in another star system and didn't bookmark the planet you died on)
- You can now click on planet icons in the Star system nav, which will show you how to get to the planet

## Dev notes
- TU4 and before save will no longer work in TU4.1 due to Godot 4’s changes in file storage
