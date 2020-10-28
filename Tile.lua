local Tile = {}

function Tile:new(j, i, id)
	local t = {}

	assert(j and i and id, "ERROR: Tile:new(j, i, id), There is a nil argument")
	
	t.id = id
	t.img = love.graphics.newImage(t.id)
	t.imgSize = t.img:getWidth() -- OK
	t.j = j
	t.i = i
	--t.animation = nil
	

	setmetatable(t, self)
	self.__index = self
	return t
end

function Tile:load(data)
	local t = {}

	t.id = data.id
	t.img = love.graphics.newImage(data.id)
	t.imgSize = t.img:getWidth() -- OK
	t.j = data.j
	t.i = data.i

	if data.animation then
		t.animation = Animation:loadFromTable(data.id, data.animation)
	end
	
	setmetatable(t, self)
	self.__index = self
	return t
end

function Tile:draw(tileSize, dt)

	if self.animation then
		dt = dt or love.timer.getDelta()
		self.animation:update(dt)
		self.animation:draw(self.x, self.y)
	else
		love.graphics.draw(self.img, self.j * tileSize, self.i * tileSize, 0, tileSize / self.imgSize)
	end
end

return Tile