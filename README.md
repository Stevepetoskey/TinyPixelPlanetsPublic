![image of Tiny Pixel Planet](https://img.itch.zone/aW1hZ2UvMTY1NzQ3Mi8xMjE1NTQ2Ni5wbmc=/original/sou%2Fzh.png)

Tiny Pixel Planets is a Terraria like sandbox game in space. 
Tiny Pixel Planet uses Godot 3.5.1

For release packages go to https://sp-possibilities.itch.io/tiny-pixel-planets

All features from Title Update 1 can be found here: [TU1 Features](https://sp-possibilities.itch.io/tiny-pixel-planets/devlog/422986/tiny-pixel-planets-major-update)

## Title Update 2
Since I decided to open a new public repository instead of opening my private repository to the public, the Earliest this repo goes back to is TU2 Beta 1.

### Features
- Planets in the sky now have 3D shading on them to correctly reperesent how the star light interacts with the star system (Using actual 3D scenes being layered onto sprites via viewports and shader magic)
- Added Slorgs! What is a block base sandbox game without a slime like enemy!
- Made world sizes for small and medium planets 4 time larger with new world generation system (Even takes less time to generate bigger worlds than the previous world gen system)
- Made armor that you can craft and wear! (No effects as of now, other than looking cool!)
- Added Silver and Copper ore, ingots, and pickaxes
- Improved space flight by adding a panel with details on everything in the system
- Added character customization in menu
- Added weapons with attack feature
- Planets in the navigation scene now have shading
- You can now die!

### Improvements
- Changed color of space
- Players now appear where they left off on their current planet before quiting
- Added stars in the night sky

### Fixes
- Fixed All worlds within a star system having the same generation
- Saves now save the world rotation and planetary orbits
- Fixed Slorgs freezing and doing nothing after attacking
- Fixed inventory disappearing randomly
- Fixed block lag
- Fixed background not loading after it should
- Fixed world randomly crashing during loading

## Title Update 3
### Features
- Added chest (Stores 8 items)
- Can now make workbench and sticks with exotic planks
- Added second item hotbar, use it with the right mouse button
- Added item entity
- Added Rhodonite toolset
- Added Exotic wood toolset
- You now lose oxygen on planets without a atmosphere
- Wearing a full space suit adds extra oxygen
- You can now die of lack of oxygen
- Added Quartz (Block, Ore, Mineral) with 4 different colors (White, Rose, Purple, Blue)
- Added asteroids (new planet with random asteroids flying around with no gravity)
- Added Tutorial 
- Added commands and a command prompt
- Added Sprinting
- Added Exotic planet
- Added Exotic blocks
- Added windows (Wood, Exotic wood, and Copper)

### Improvements
- Inventory now maxes out at 16 items
- Items can only stack up to 99 now
- Added sticks to inventory crafting
- Star system layout is now saved, instead of building from a seed when loading
- Glass and windows now expand their texture
- Changed the way stars are shown

### Fixes
- Fixed Player falling out of the world
- Fixed going on a new planet giving the player a wood pickaxe
- Fixed player textures not loading while landing on planet/ loading game

## Title Update 3.1
### Features
- Added Web Demo
- Added tooltip that is displayed when hovering over items
- Armor now is functional

## Tiny Pixel Planets Title Update 4
### Features
- Added water system
- Added silver and copper buckets with and without water
- Foliage now sways in the wind
- Added ocean planets
- Fixed blocks not showing behind glass and windows
- Added wet sand
- Now can only place saplings and flowers on their appropriate grass and dirt blocks using the new "can_place_on" attribute
- Added new command: worldrule [place_blocks (bool) | break_blocks (bool) | interact_with_blocks (bool) | entity_spawning (bool) | enemy_spawning (bool) | world_spawn_x (int) | world_spawn_y (int) ]
- Added new command: displaycoordinates [true | false]
- Added Galaxy navigation
- Now able to travel between star systems
- Reworked the naming system for stars to be more realistic
- Systems are now refered to by their system id (String) and no longer by their seed (int)
- Can now save and quit at any point even in space
- Added blues (Currency)
- Slorgs now drop blues when killed
- Added panel in galaxy view that shows what type of planets are in the star system
- New weather system depending on the planet (rain, showers, snow, blizzards)
- Added achievements
- Added tomato, wheat, and corn seeds
- Added new command: weather [rain | showers | snow | blizzards]
- Added Fig tree that has a chance to drop wheat, tomato, and corn seeds
- Added stone and silver hoes
- Doubled world height (64 blocks now)
- Added Silver and Copper watering cans
- Added data property to items
- Added new blocks (Copper plate, Copper bricks, Cracked copper bricks, Silver plate, Silver bricks, and Cracked Silver bricks)
- Save version now shows on the save in the menu
- Now unable to load saves from TU3 and prior (All star systems prior to TU4 don't exists anymore and would completely break the Galaxy generation)
- Added bookmarks (Able to warp to bookmarked planets)
- Added Versitalis (Shop Center) and made it auto bookmark on new saves
- Now able to view planet stats in the planet select
- Now able to change planet names
- Added Space squids
- Added Rockius
- Now able to restore health by eating food items
- Added settings menu
- Now able to change music volume
- Now able to set keybinds
- Added a new block: Bottom rock (Unbreakable and generates at the bottom of the world)
### Improvements
- Modified habitable zone size to allow for more habitable planets in system
- Player now points in the direction of movement if moving, otherwise points torwards mouse. Aka now your player can't moon walk.
- Removed entityspawning and enemyspawning commands
- Game window is now native 16:9
- Changed how space looks in the star system navigation
- Changed how seeds are generated for star systems (Breaking all previous saves)
- Reworked sound engine, now doesn't end a track when leaving a planet
- Made player's name also the name of the save
- Made some block optimizations
- Updated inventory and other important GUI textures to look more readable
- Inventory, crafting, and chest now are scrollable as opposed to the old page system
- Chests can now store up to 24 items
- Hotbar inventory slots no longer open and close the inventory but instead act as normal inventory slots, making the GUI much more fluent
### Fixes
- Fixed women not being able to wear silver armor
- Fixed being able to place blocks from second slot despite no blocks existing which led the game to crash.
- Fixed Swinging animation
- Fixed being able to kill items
- Fixed Item data showing even after closing the inventory
- Fixed parallax background not loading when it should
- Fixed duplicated chest recipe costing 78 wood planks
- Fixed camera limit preventing the player from viewing the bottom two block layers