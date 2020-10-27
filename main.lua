-- require('Tile')
-- require('Tilemap')
require('TilemapEditor')
require('../animations/Animation')

local t = 0

function love.load()
	local pathToTiles = "media/img/tiles/"
	myTilemapEditor = TilemapEditor:new(64, pathToTiles, 0.5, 0.5)
end


function love.update(dt)
	t = t + dt

	if t > 3 then		
		t = 0
	end
end


function love.draw()
	myTilemapEditor:draw()
end