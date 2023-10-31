# Template-Platformer-Solar2D

## Introduction
This is a sample project to help learn how to build a platformer with Solar2D.
Includes basic features such as Player Controller, Movement Platform, Level Controller, etc.

## Scenes
* Start Scene:
  - This is simply a starting scene, where we allow the player to start the level.
* Game Scene:
  - This scene is controller all of gameplay.
  - The map data will be read by [Ponytiled](https://github.com/ponywolf/ponytiled) module and create the map.
  - Extends all plugins by object type in map data.
  - Controller gamestate.

## How to create new level?
* You need install [Tiled](https://www.mapeditor.org/) to design maps.
* Export json file into [maps folder](https://github.com/Kan-Kzeit/Template-Platformer-Solar2D/tree/main/res/maps)

```lua
    --in game.lua
    -- load world
    self.level = params.level -- replace your level file here
    print("lode map ".."level_"..self.level)
    local pathData = "res/maps/" .. "level_"..self.level .. ".json"
```

![image](https://github.com/Kan-Kzeit/Template-Platformer-Solar2D/assets/70838508/42adedcd-e59b-4d90-ac1d-be463a2124b1)

## Credit
Map editor: https://www.mapeditor.org/ </br>
Map plugin: https://github.com/ponywolf/ponytiled

