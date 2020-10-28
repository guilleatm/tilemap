local Tile = {}

function Tile:new(x, y, id)
	local t = {}

	assert(x and y and id, "ERROR: Tile:new(x, y, id), There is a nil argument")
	
	t.id = id
	t.img = love.graphics.newImage(t.id)
	t.imgSize = t.img:getWidth() -- OK
	t.x = x
	t.y = y
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
	t.x = data.x
	t.y = data.y

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
		love.graphics.draw(self.img, self.x, self.y, 0, tileSize / self.imgSize)
	end
end

-- function Tile:animate(width, height, duration, loop, start, ox, oy)
-- 	self.animation = Animation:new(self.img, width, height, duration, loop) -- The animation takes 0.5 seconds and loops 

-- 	if start ~= false then
-- 		self.animation:start()
-- 	end
-- end

return Tile