Enemy = {}

--Constructor
function Enemy:new()
	local object = {
		x = 0,
		y = 0,
		width = 0,
		height = 0,
		xSpeed = 0,
		ySpeed = 0,
		xSpeedMax = 800,
		ySpeedMax = 800,
		state = "stand",
		jumpSpeed = 0,
		runSpeed = 0,
		canJump = false,
		onFloor = false,
		facing = "right"
	}

	setmetatable(object, {__index = Enemy})
	return object
end

function Enemy:moveLeft() 
	self.xSpeed = -self.runSpeed
	self.state = "move"
	self.facing = "left"
end

function Enemy:moveRight()
	self.xSpeed = self.runSpeed
	self.state = "move"
	self.facing = "right"
end


function Enemy:update(dt, gravity, map)
	local halfX = self.width / 2
	local halfY = self.width / 2

	--apply gravity
	self.ySpeed = self.ySpeed + gravity

	--limit the speed
	self.xSpeed = math.clamp(self.xSpeed, -self.xSpeedMax, self.xSpeedMax)
	self.ySpeed = math.clamp(self.ySpeed, -self.ySpeedMax, self.ySpeedMax)

	--update position
	local nextY = math.floor(self.y + (self.ySpeed * dt))
	if self.ySpeed < 0 then	--check upwards, check each top corner
		if not(self:isColliding(map, self.x - halfX, nextY - halfY))
			and not(self:isColliding(map, self.x + halfX - 1, nextY - halfY)) then
			self.y = nextY
			self.onFloor = false
		else
			self.y = nextY + map.tileHeight - ((nextY - halfY) % map.tileHeight)
			self:collide("ceiling")
		end
	elseif self.ySpeed > 0 then	--check down
		if not(self:isColliding(map, self.x - halfX, nextY + halfY))
			and not(self:isColliding(map, self.x + halfX - 1, nextY + halfY)) then
			self.y = nextY
			self.onFloor = false
		else
			self.y = nextY - ((nextY + halfY) % map.tileHeight)
			self:collide("floor")
		end
	end
	local nextX = math.floor(self.x + (self.xSpeed * dt))
	if self.xSpeed > 0 then --check right
		if not(self:isColliding(map, nextX + halfX, self.y - halfY))
			and not(self:isColliding(map, nextX + halfX, self.y + halfY - 1)) then
			self.x = nextX
		else
			self.x = nextX - ((nextX + halfX) % map.tileWidth)
			self:moveLeft()
		end
	elseif self.xSpeed < 0 then	--check left
		if not(self:isColliding(map, nextX - halfX, self.y - halfY))
			and not(self:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
			self.x = nextX
		else
			self.x = nextX + self.width - ((nextX + halfX) % map.tileWidth)
			self:moveRight()
		end
	end
end

--returns true if the coordinates given intersect a map tile
function Enemy:isColliding( map, x, y )
	-- body
	local layer = map.layers["Walls"]
	local tileX, tileY = math.floor(x/map.tileWidth), math.floor(y/map.tileHeight)

	local tile = layer:get(tileX, tileY)

	return not(tile == nil)

end

function Enemy:collide(event)
	if event == "floor" then
		self.ySpeed = 0
		self.onFloor = true
		self.canJump = true
	end
	if event == "ceiling" then
		self.ySpeed = 0
	end
end