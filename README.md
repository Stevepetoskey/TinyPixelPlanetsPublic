# Tiny Pixel Planets Title Update 4
## TU4 Beta 1 (v0.4.0:1)
- Added water system
- Added silver and copper buckets with and without water
- Foliage now sways in the wind
- Added ocean planets
- Fixed blocks not showing behind glass and windows
- Added wet sand
- Now can only place saplings and flowers on their appropriate grass and dirt blocks using the new "can_place_on" attribute
- Modified habitable zone size to allow for more habitable planets in system
- Player now points in the direction of movement if moving, otherwise points torwards mouse. Aka now your player can't moon walk.
## TU4 Beta 2 (v0.4.0:2)
- Fixed women not being able to wear silver armor
- Game window is now native 16:9
## TU4 Beta 3 (v0.4.0:3)
- Added new command: worldrule [place_blocks (bool) | break_blocks (bool) | interact_with_blocks (bool) | entity_spawning (bool) | enemy_spawning (bool) | world_spawn_x (int) | world_spawn_y (int) ]
- Added new command: displaycoordinates [true | false]
- Removed entityspawning and enemyspawning commands
- Fixed being able to place blocks from second slot despite no blocks existing which led the game to crash.
## TU4 Beta 4 (v0.4.0:4)
- Added Galaxy navigation
- Now able to travel between star systems
- Reworked the naming system for stars to be more realistic
- Changed how space looks in the star system navigation
- Changed how seeds are generated for star systems (Breaking all previous saves)
## TU4 Beta 5 (v0.4.0:5)
- Fixed Swinging animation
- Fixed star system location in the galaxy being lost after reloading a save
- Systems are now refered to by their system id (String) and no longer by their seed (int)
- Can now save and quit at any point even in space
- Added blues (Currency)
- Slorgs now drop blues when killed
- Fixed being able to kill items
- Fixed Item data showing even after closing the inventory
- Reworked sound engine, now doesn't end a track when leaving a planet
- Added panel in galaxy view that shows what type of planets are in the star system
- Fixed a star system having a different name each time
- Fixed entering a saved star system from the galaxy view remaking the entire star system again
- Fixed ship position in a star system not loading when entering a save
## TU4 Beta 6 (v0.4.0:6)
- Player can now swim in water
- Fixed visited planets not reseting upon generating a new system
- New weather system depending on the planet (rain, showers, snow, blizzards)
- Fixed blues not reseting when starting a new world
- Added achievements
- Made player's name also the name of the save
- Fixed parallax background not loading when it should
## TU4 Beta 7 (v0.4.0:7)
- Made improvements to the water system (No more infinite water bugs)
- Removed scenario gui (Scenarios are no longer planned for TU4)
- Added wheat that grows and can be harvested
- Water now makes dry farmland wet
- Rain now makes dry farmland wet
- Added new command: weather [rain | showers | snow | blizzards]
- Weather now saves
- Added Fig tree that has a chance to drop wheat, tomato, and corn seeds
- Fixed duplicated chest recipe costing 78 wood planks
- Added stone and silver hoes
- Doubled world height (64 blocks now)
- Made some block optimizations
- Added Silver and Copper watering cans
- Water buckets can now hold less than a full block of water 
- Added data property to items
## TU4 Beta 8 (v0.4.0:8)
- Added new blocks (Copper plate, Copper bricks, Cracked copper bricks, Silver plate, Silver bricks, and Cracked Silver bricks)
- Save version now shows on the save in the menu
- Now unable to load saves from TU3 and prior (All star systems prior to TU4 don't exists anymore and would completely break the Galaxy generation)
- Updated inventory and other important GUI textures to look more readable
- Inventory, crafting, and chest now are scrollable as opposed to the old page system
- Chests can now store up to 24 items
- Hotbar inventory slots no longer open and close the inventory but instead act as normal inventory slots, making the GUI much more fluent
- Added bookmarks (Able to warp to bookmarked planets)
- Added Versitalis (Shop Center) and made it auto bookmark on new saves
- Now able to view planet stats in the planet select
- Now able to change planet names
- Began work on fixing a major gui issue from how text reacts to changing the game window (Maybe bitmap fonts can work?)