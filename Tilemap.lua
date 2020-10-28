local Tile = require('Tile')
require('../utils/utils')

local Tilemap = {}


local animationKey = 'anim'
-- anim_w64h64d1l1s1 --examples
-- anim_d1l1s1

function Tilemap:new(tileSize)

	assert(tileSize, "ERROR: Tilemap:new(tileSize), tileSize can not be nil")

	local tm = {}
	tm.tileSize = tileSize
	tm.tiles = {}

	setmetatable(tm, self)
	self.__index = self
	return tm
end

function Tilemap:draw()
	local dt = love.timer.getDelta()

	for i, row in pairs(self.tiles) do
		for j, tiles in pairs(row) do
			for _, tile in pairs(tiles) do
				tile:draw(self.tileSize, dt)
			end
		end
	end
end

function Tilemap:selectTile(x, y)

	local j, i = (x - (x % self.tileSize)) / self.tileSize, (y - (y % self.tileSize)) / self.tileSize

	if not self.tiles[i] or not self.tiles[i][j] then
		return nil, j, i

	end
	return self.tiles[i][j], j, i
end

function Tilemap:addTile(x, y, id) -- #M

	local tiles, j, i = self:selectTile(x, y)
	local tile = Tile:new(j * self.tileSize, i * self.tileSize, id)

	-- if string.find(id, animationKey) then -- #C ANIMATIONS IN TILES!!
	-- 	tile.animation = Animation:load(id, nil, nil, nil, nil, self.tileSize)
	-- 	tile.animation:start()
	-- end
	
	if tiles then
		table.insert(tiles, tile)
	else
		if not self.tiles[i] then
		self.tiles[i] = {}
		end
		if not self.tiles[i][j] then
			self.tiles[i][j] = {tile}
		end
	end
end

function Tilemap:removeTile(x, y)

	local tiles, j, i = self:selectTile(x, y)

	tiles[#tiles] = nil -- Arguments passed by reference
end

function Tilemap:clear()
	self.tiles = {}
	collectgarbage()
end

function Tilemap:save(path_or_name) -- #Revisar

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

function Tilemap:load(path_or_name, tileSize) -- #C

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

	for k, almostTile in pairs(tilesInfo) do -- #C
		table.insert(self.tiles, Tile:load(almostTile))
	end

	self:setSize(tileSize, oldTileSize)

	return self
end

return Tilemap