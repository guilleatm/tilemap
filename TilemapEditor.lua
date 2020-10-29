local Tilemap = require('Tilemap')
require('tilemapEditorControls')
local Camera = require('../camera/Camera')

local TilemapEditor = {}

local animateTileSet = true

function TilemapEditor:new(tileSize, pathToTiles, relativeWidth, relativeHeight, ox, oy, tilemap, tileSet) -- #C

	local te = {}

	assert(tileSize and pathToTiles, "ERROR: TilemapEditor:new(tileSize, pathToTiles), tileSize and pathToTiles can not be nil, pathToTiles is the path to the directory that contains the tile images")

	te.tilemap = tilemap or Tilemap:new(tileSize)

	te.pathToTiles = toPath(pathToTiles)
	te.tileIDs = love.filesystem.getDirectoryItems(te.pathToTiles)

	relativeWidth, relativeHeight = relativeWidth or 1, relativeHeight or 0.5
	local w, h = love.graphics.getDimensions()
	local canvasW, canvasH = relativeWidth * w, relativeHeight * h

	te.canvas = love.graphics.newCanvas(canvasW, canvasH)
	te.canvasOx = ox or w - canvasW
	te.canvasOy = oy or h - canvasH
	te.canvasW = canvasW
	te.canvasH = canvasH

	local function getSide() -- https://math.stackexchange.com/questions/466198/algorithm-to-get-the-maximum-size-of-n-squares-that-fit-into-a-rectangle-with-a
		local n = #te.tileIDs
		local w, h = canvasW, canvasH

		px = math.floor(math.sqrt(n * w / h) + 1)
		if math.floor(px * h / w) * px < n then
			sx = h / math.floor((px * h / w) + 1)
		else
			sx = w / px
		end

		return sx
	end


	if tileSet then
		te.tileSet = tileSet
	else

		local side = getSide()
		local nTilesInRow = canvasW / side

		te.tileSet = Tilemap:new(side, te.canvasOx, te.canvasOy)

		local j, i = 1, 1
		for count, tileName in ipairs(te.tileIDs) do
			te.tileSet:addTile((j - 1) * side, (i - 1) * side, te.pathToTiles .. tileName)
			j = j + 1
			if count % nTilesInRow == 0 then
				j = 1
				i = i + 1
			end
		end
	end


	love.graphics.setCanvas(te.canvas)
		love.graphics.setBlendMode('alpha')
		te.tileSet:draw()
		--love.graphics.setColor(0.8, 0.8, 0.8, 1)
	love.graphics.setCanvas()

	setmetatable(te, self)
	self.__index = self
	return te
end

function TilemapEditor:save(path)
	self.tilemap:save(path)
end

function TilemapEditor:load(path, tileSize)
	self.tilemap:load(path, tileSize)
end

function TilemapEditor:draw()
	Camera:set()
		self.tilemap:draw()
	Camera:unset()

	if animateTileSet then
		love.graphics.setCanvas(self.canvas)
		self.tileSet:draw()
		love.graphics.setCanvas()	
	end
	love.graphics.draw(self.canvas, self.canvasOx, self.canvasOy)
end

function TilemapEditor:addTile(x, y, id) -- #Revisar
	self.tilemap:addTile(x, y, id)
end

function TilemapEditor:removeTile(x, y)
	self.tilemap:removeTile(x, y)
end

function TilemapEditor:selectTile(tilemap, x, y)
	return tilemap:selectTile(x, y)
end

function TilemapEditor:clear()
	self.tilemap:clear()
end


function TilemapEditor:leftClick(x, y)
	if x > self.canvasOx and x < self.canvasOx + self.canvasW and y > self.canvasOy and y < self.canvasOy + self.canvasH then
		-- Click inside canvas
		local tiles = self:selectTile(self.tileSet, x - self.canvasOx, y - self.canvasOy)
		self.selectedTile = tiles[#tiles]
	else
		-- Click outside canvas
		if not self.selectedTile then return end
		self:addTile(x + Camera.x, y + Camera.y, self.selectedTile.id)
	end
end

function TilemapEditor:rightClick(x, y)
	if x > self.canvasOx and x < self.canvasOx + self.canvasW and y > self.canvasOy and y < self.canvasOy + self.canvasH then
		-- Click inside canvas
		return
	else
		-- Click outside canvas
		self:removeTile(x + Camera.x, y + Camera.y)
	end
end

function TilemapEditor:up()
	Camera:move(0, -self.tilemap.tileSize)
end
function TilemapEditor:down()
	Camera:move(0, self.tilemap.tileSize)
end
function TilemapEditor:left()
	Camera:move(-self.tilemap.tileSize, 0)
end
function TilemapEditor:right()
	Camera:move(self.tilemap.tileSize, 0)
end

return TilemapEditor