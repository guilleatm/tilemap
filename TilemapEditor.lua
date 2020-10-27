require('Tilemap')
require('tilemapEditorControls')
require('../camera/camera')

TilemapEditor = {}

local animateTileSet = true

function TilemapEditor:new(tileSize, pathToTiles, relativeWidth, relativeHeight, ox, oy, tilemap, tileSet)

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

		local xTile, yTile = 1, 1
		for i, tileName in ipairs(te.tileIDs) do
			te.tileSet:addTile((xTile - 1) * side + side / 2, (yTile - 1) * side + side / 2, te.pathToTiles .. tileName)
			xTile = xTile + 1
			if i % nTilesInRow == 0 then
				xTile = 1
				yTile = yTile + 1
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

function TilemapEditor:save(path_or_name)
	self.tilemap:save(path_or_name)
end

function TilemapEditor:load(path_or_name, oldTileSize)
	self.tilemap:load(path_or_name, self.tilemap.tileSize, oldTileSize)
end

function TilemapEditor:draw()
	camera:set()
		self.tilemap:draw()
	camera:unset()

	if animateTileSet then
		love.graphics.setCanvas(self.canvas)
		self.tileSet:draw()
		love.graphics.setCanvas()	
	end
	love.graphics.draw(self.canvas, self.canvasOx, self.canvasOy)
end

function TilemapEditor:addTile(x, y, id)
	self.tilemap:addTile(x, y, id)
end

function TilemapEditor:removeTile(x, y)
	self.tilemap:removeTile(x, y)
end

function TilemapEditor:selectTile(tilemap, x, y, positionInList)
	return tilemap:selectTile(x, y, positionInList)
end

function TilemapEditor:clear()
	self.tilemap.tiles = {}
	collectgarbage()
end


function TilemapEditor:leftClick(x, y)
	if x > self.canvasOx and x < self.canvasOx + self.canvasW and y > self.canvasOy and y < self.canvasOy + self.canvasH then
		-- Click inside canvas
		self.selectedTile = self:selectTile(self.tileSet, x, y)
	else
		-- Click outside canvas
		if not self.selectedTile then return end
		self:addTile(x + camera.x, y + camera.y, self.selectedTile.id)
	end
end

function TilemapEditor:rightClick(x, y)

	if x > self.canvasOx and x < self.canvasOx + self.canvasW and y > self.canvasOy and y < self.canvasOy + self.canvasH then
		-- Click inside canvas

	else
		-- Click outside canvas
		self:removeTile(x + camera.x, y + camera.y)
	end
end

function TilemapEditor:up()
	camera:move(0, -self.tilemap.tileSize)
end
function TilemapEditor:down()
	camera:move(0, self.tilemap.tileSize)
end
function TilemapEditor:left()
	camera:move(-self.tilemap.tileSize, 0)
end
function TilemapEditor:right()
	camera:move(self.tilemap.tileSize, 0)
end


-- function TilemapEditor:mousePressed(x, y, button)
-- 	if self.mode == 1 then
-- 		TilemapEditor:mousePressedMode1(x, y, button)
-- 	elseif self.mode == 2 then
-- 		TilemapEditor:mousePressedMode2(x, y, button)
-- 	end
-- end

-- function TilemapEditor:mousePressedMode1(x, y, button)
-- 	local oxMap, oyMap = -camera.x / camera.scaleX, -camera.y / camera.scaleY

-- 	if y > self.y and y < self.y + self.h and x > self.x and x < self.x + self.w then -- Click dins del TilemapEditor
-- 		local ex, ey = x - self.x, y - self.y -- TilemapEditor x and TilemapEditor y, les coordenades respecte al TilemapEditor
-- 		local ti, tj = math.floor(ey / (cellSize * self.tileScale)), math.floor(ex / (cellSize * self.tileScale)) + 1
-- 		local tilesInARow = self.w / (cellSize * self.tileScale)
-- 		local tileId = ti * tilesInARow + tj
		
-- 		self.tileSelected = tileId
	
-- 	elseif y > oyMap and y < oyMap + (numCells * cellSize) / camera.scaleY and x > oxMap and x < oxMap + (numCells * cellSize) / camera.scaleX then -- Click dins del mapa
-- 		local mx, my = x - oxMap, y - oyMap -- Map x and map y, les coordenades respecte al mapa
-- 		local ti, tj = math.floor(my / (cellSize / camera.scaleY)), math.floor(mx / (cellSize / camera.scaleX)) + 1
-- 		local tileId = map[ti + 1][tj].id

-- 		if button == 1 then -- Botó esquerre
-- 			self.pastTile = tileId
-- 			self.pastI = ti + 1
-- 			self.pastJ = tj
-- 			map[ti + 1][tj] = tile:new(self.tileSelected, ti + 1, tj)
-- 		elseif button == 2 then -- Botó dret
-- 			mapBack[ti + 1][tj] = tile:new(self.tileSelected, ti + 1, tj)
-- 		elseif button == 3 then -- Botó roda (apretar)
-- 			self.tileSelected = tileId
-- 		end
-- 	end
-- end

-- function TilemapEditor:mousePressedMode2(x, y, button)
-- 	if button == 1 then
-- 		table.insert(self.points, {x, y})
-- 	elseif button == 2 then
-- 		table.remove(self.points)
-- 	end
-- end


-- function TilemapEditor:drawTileImg(i, x, y, scale)
-- 	local s = scale or self.tileScale
-- 	love.graphics.draw(tileImages[i], x, y, 0, s, s)
-- end

-- function TilemapEditor:undo()
-- 	map[self.pastI][self.pastJ] = tile:new(self.pastTile, self.pastI, self.pastJ)
-- end

-- function TilemapEditor:clean()
-- 	local g = collectgarbage("count")
-- 	collectgarbage()
-- 	print(tostring(g - collectgarbage("count")) .. "Kb de basura limpiados")
-- end


-- function TilemapEditor:changeTo(mode)
	
-- 	if mode == 1 then
-- 		camera:setScale(2, 2)
-- 		camera:move(-camera.x, -camera.y)
-- 		self.tileScale = 0.5
-- 	elseif mode == 2 then
-- 		camera:setScale(1, 1)
-- 		camera:move(0, -camera.y)
-- 		self.tileScale = 1
-- 	end
	
-- 	self.mode = mode
-- end

-- function TilemapEditor:zip() -- Canvia tile per tile.id per a que siga mes facil savear i llegir la info
-- 	local mapZip, mapBackZip = {}, {}
-- 	for i = 1, #map do
-- 		table.insert(mapZip, {})
-- 		table.insert(mapBackZip, {})
-- 		for j = 1, #map[1] do
-- 			table.insert(mapZip[i], map[i][j].id)
-- 			table.insert(mapBackZip[i], mapBack[i][j].id)
-- 		end
-- 	end
-- 	return {mapZip, mapBackZip}
-- end
