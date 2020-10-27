# Tilemap

## Description

Three classes to create and use tilemaps.  
It is possible to animate the tiles (thanks to the animation class)  
MIT License.  
Give a star to the repo if you use the library :) and report any bug, thanks. I will fix the bugs and appreciate the stars.
The code were not be tested so it can have bugs :o  

> Classes:  
> TilemapEditor --> Tilemap --> Tile  
> TilemapEditorControls (not a class)

> For using the complete library you have to have the files: Tile.lua, Tilemap.lua, TilemapEditor.lua, TilemapEditorControls.lua and camera.lua.  
If you want to animate the tiles, you will need Animation.lua too.  

That is all what you have to include in the code:  

```lua
	require 'TilemapEditor'
	require 'Animation'
```

> Probably, you don't want let players edit the tilemap, then, you don't want to include the tilemapEditor in the code of the game, you can simply include what you use:

```lua
	require 'Tilemap'
	require 'Animation'
```

---

## Creating a tilemap with tilemapEditor

```TilemapEditor:new(tileSize, pathToTiles)``` Creates a tilemap editor **indispensable for using the tilemapEditor**

All parameters:  
```TilemapEditor:new(tileSize, pathToTiles, relativeWidth, relativeHeight, offsetX, offsetY, tilemap, tileSet)``` Creates a tilemap editor

* **tileSize**: The size of the tiles in the game (it is not the size of the image of the tile)
* **pathToTiles**: A string with the path to the folder that contains **all** the tile images.

* Test yourself with the other arguments

* **tilemap**: A tilemap object for edit.
> It is better to use the TilemapEditor:load() (changing to unammedTilemap.lua)

* **tileSet**: Probably this don't work, sorry.

---

## Editing the tilemap

Left click in the tileSet for selecting a tile.  

Left click in the tilemap zone for adding the last tile selected in the tileset.
Right click for deleting the last tile in the space.

> You can have more tnah one tile in the same gap. This is perfect for backgrounds and transparencies but be careful with clicking a lot of times, a lot of tiles will be stored in the same gap!! (Not good for perfomance)  

Use the arrow keys for moving around the tilemap.

> The tilemap have NO LIMITS ;)  
> It can have any shape (haven't to be rectangular)  
> The cost of looking for a tile is log(n) (Good performance)

---
> **Remember to change the name of the tilemapEditor object in TilemapEditorControls. Default is myTilemapEditor**.

> You can change the controls too.

## Saving the tilemap

If you do not change the default controls, only by pressing ***s***, the tilemap will be stored in the default path (the tilemap folder) under the name unammedTilemap.lua. **Remember to rename the file if you don't want to overrite it**

Check the code if you need to save the tilemaps in a specifid folder. (You will need to do it trought coding)

## Loading a tilemap

Press ***l*** for loading the unammedTilemap.lua tilemap.

Check the code for more. (You will need to do it trought coding)

## Clear tilemap

Press ***c***.

---

## Animate tiles.
Use Tile:animate() for animating the tiles.  
> See animation documentation

---

# Example

```lua
require('TilemapEditor')
require('Animation')

function love.load()
	local pathToTiles = "media/img/tiles/"
	myTilemapEditor = TilemapEditor:new(64, pathToTiles, 0.5, 0.5)
end


function love.update(dt)

end


function love.draw()
	myTilemapEditor:draw()
end
```
