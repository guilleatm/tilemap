local defaultControls = { -- Change the controls if you prefer others (The keys on the left)
	['s'] = 'save',
	['l'] = 'load',
	['c'] = 'clear',
	['up'] = 'up',
	['down'] = 'down',
	['left'] = 'left',
	['right'] = 'right',
	['mouse1'] = 'leftClick',
	['mouse2'] = 'rightClick'
}


function love.keypressed(key)
	local functionName = defaultControls[key]
	if functionName then
		myTilemapEditor[functionName](myTilemapEditor)
	end
end

function love.mousepressed(x, y, buttonID, isTouch, presses)
	local functionName = defaultControls['mouse' .. tostring(buttonID)]
	if functionName then
		myTilemapEditor[functionName](myTilemapEditor, x, y)
	end
end

function love.mousereleased(x, y, buttonID, isTouch, presses)
end

function love.mousemoved(x, y, dx, dy, isTouch)
end