-- require('Tile')
-- require('Tilemap')
local TilemapEditor = require('TilemapEditor')
Animation = require('../animations/Animation')

function love.load()
	local pathToTiles = "media/img/tiles/"
	myTilemapEditor = TilemapEditor:new(64, pathToTiles, 0.5, 0.5)
end


function love.update(dt)
end


function love.draw()
	myTilemapEditor:draw()
end