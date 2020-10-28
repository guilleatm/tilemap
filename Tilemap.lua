local Tile = require('Tile')
require('../utils/utils')

local Tilemap = {}


local animationKey, wallKey = 'anim', 'wall'
-- anim_w64h64d1l1s1 --examples
-- anim_d1l1s1

function Tilemap:new(tileSize, ox, oy)

	local tm = {}

	assert(tileSize, "ERROR: Tilemap:new(tileSize), tileSize can not be nil")
	tm.tileSize = tileSize
	tm.ox = ox or 0
	tm.oy = oy or 0

	tm.tiles = {}
	tm.walls = {}

	setmetatable(tm, self)
	self.__index = self
	return tm
end


function Tilemap:save(path_or_name)

	local defaultFolder = 'tilemaps/'
	local defaultTilemapName = 'unnamedTilemap'
	local os = love.system.getOS()

	if os == 'Android' or os == 'iOS' then
		assert(love.filesystem.createDirectory(defaultFolder), "Tilemap:save(path): Couldn't create the directory")
		path_or_name = toPath(love.filesystem.getSaveDirectory()) .. defaultFolder .. path_or_name or defaultTilemapName
	else
		path_or_name = path_or_name or toPath(love.filesystem.getSource()) .. defaultFolder .. defaultTilemapName
	end	
	
	path_or_name = path_or_name .. ".lua"
	
	local file = io.open(path_or_name, 'w')
	assert(file, "Tilemap:save(path_or_name): Failed on creating new file, make sure the path is correct")

	local content = string.format("return {%s}", tableToString(self.tiles, ','))
	file:write(content)
	file:close()
end

function Tilemap:load(path_or_name, tileSize, oldTileSize)

	local defaultFolder = 'tilemaps/'
	local defaultTilemapEditorName = 'unnamedTilemap'
	local os = love.system.getOS()

	if os == 'Android' or os == 'iOS' then
		path_or_name = path_or_name or toPath(love.filesystem.getSaveDirectory()) .. defaultFolder .. defaultTilemapEditorName
	else
		path_or_name = path_or_name or (toPath(love.filesystem.getSource()) .. defaultFolder .. defaultTilemapEditorName)
	end	
	
	path_or_name = path_or_name .. ".lua"

	self:clear()

	local tilesInfo = dofile(path_or_name)

	for k, almostTile in pairs(tilesInfo) do
		table.insert(self.tiles, Tile:load(almostTile))
	end

	self:setSize(tileSize, oldTileSize)

	return self
end

function Tilemap:draw()
	-- for k, tile in pairs(self.tiles) do
	-- 	tile:draw(self.tileSize)
	-- end
	local dt = love.timer.getDelta()

	for i = #self.tiles, 1, -1 do
		self.tiles[i]:draw(self.tileSize, dt)
	end
end

function Tilemap:addTile(x, y, id)

	local xTile, yTile = (x - (x % self.tileSize)) / self.tileSize, (y - (y % self.tileSize)) / self.tileSize

	local i = binarySearchAmplified(xTile * self.tileSize, self.tiles, true, {'x'})

	-- table.insert(self.tiles, i, Tile:new(xTile * self.tileSize, yTile * self.tileSize, id, self.tileSize))
	-- self.tiles[i]:animate() -- #C

	local tile = Tile:new(xTile * self.tileSize, yTile * self.tileSize, id, self.tileSize)
	
	if string.find(id, animationKey) then
		tile.animation = Animation:load(id, nil, nil, nil, nil, self.tileSize)
		tile.animation:start() -- #C
	end
	if string.find(id, wallKey) then
		tile.wall = true
		table.insert(self.walls, tile)
	end
	table.insert(self.tiles, i, tile)
end

function Tilemap:removeTile(x, y)

	local iTileToRemove = self:selectTile(x, y, true)

	if iTileToRemove then
		table.remove(self.tiles, iTileToRemove)
	end
end

function Tilemap:selectTile(x, y, positionInList)
	x = x - self.ox
	y = y - self.oy

	local xTile, yTile = (x - (x % self.tileSize)) / self.tileSize, (y - (y % self.tileSize)) / self.tileSize

	local first, last = binarySearchAmplified(xTile * self.tileSize, self.tiles, false, {'x'})

	if not first then return end

	if first == last then
		local tile = self.tiles[first]
		if tile.y == yTile * self.tileSize then
			if positionInList then
				return first
			else
				return self.tiles[first]
			end
		end
	else
		for i = first, last do
			local tile = self.tiles[i]
			if tile.y == yTile * self.tileSize then
				if positionInList then
					return i
				else
					return self.tiles[i]
				end
			end
		end
	end
end

function Tilemap:clear()
	self.tiles = {}
	collectgarbage()
end

function Tilemap:setScale(scale)

	if scale then
		self.tileSize = self.tileSize * self.scale
	end	

	return self.scale
end

function Tilemap:setSize(size, oldTileSize)

	if size then
		self.tileSize = size
		local factor = size / (oldTileSize or size)
	
		for i, tile in ipairs(self.tiles) do
			tile.x = tile.x * factor
			tile.y = tile.y * factor
		end
	end

	return self.tileSize
end

return Tilemap