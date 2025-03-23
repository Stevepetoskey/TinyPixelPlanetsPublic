# Tiny Pixel Planets Title Update 6 branch (unstable)
This branch is for unstable development of TU6 (v0.6.0)

## TU6 beta 1 (v0.6.0:1)
- Added lighting system (still WIP)
- Added colored LED lamps
- Display blocks now emit light when powered
- Added quartz bricks for every color variant
- Added Asteroid rock bricks, polished, and carved ateroid rock
- Fixed copper bucket recipe resulting in a bottomless silver bucket
## TU6 beta 2 (v0.6.0:2)
- Finished Lighting system
- Reworked crafting system to be more player friendly
- Items and Blues now use tweens to animate being picked up which is more reliable
- Added timespeed [float] command
- Moved blockData and itemData dictionaries to the GlobalData script
- Block data and item data now comes from json files
- Upgraded items (Including upgrade modules) now shine
## TU6 beta 3 (v0.6.0:3)
- Upgrade modules now say what they apply to
- Now able to split up items when transfering between volumes (Such as chests)
- Added cooking pot which completely overhuals the previous food system.
- Removed bread from oven crafting
- Added new tutorial system and replaced the old tutorial button with a walkthrough button.
- Started work on implementing Character V3 model. Pushing out this update incase I destroy everything while adding character.
## TU6 beta 4 (v0.6.0:4)
- Changed sex ids from Guy and Woman to male and female
- Updated character model and armors to Model v3
- Updated settings menu, now each category has it's own tab
- Added sound effects and environment audio sliders under audio settings
- Settings menu can now be accessed from the in game pause menu
- Added walking sfx
- Player walk animation now varries with player speed
- Player now uses oxygen when underwater
- Bubbles now form from player when underwater
- Fixed being able to discover the same planet multiple times
- Fixed leaving planet with inventory open freezing the game
- Added placing and breaking sound effects
## TU6 beta 5 (v0.6.0:5)
- Added coal ore (stone and sandstone) and coal
- Added torches
- Made some improvements to the light rendering algorithm
- Structure save block have been renamed to Structure block, and can now load structures.
- All entities now use built in velocity for movement to be inline with Godot 4 structures
- Structure blocks now highlight the selected area
- Structure blocks now save from the local position of the block instead of the global position in the world
- Fixed completely empty worlds freezing the game (this was caused by the creature spawning process)
- Fixed reaching the bottom of the world (below bottom rock) crashing the game
- Mines now generate with wooden floor if no blocks are underneath
- Dungeons now have the option to always try and close off open exits
- Complete overhual of the frigid dungeon
- Added fan blocks
- Remade scorched dungeons
