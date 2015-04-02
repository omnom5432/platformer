Player = {}

--Constructor
function Player:new()
	--parameters
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
	facing = "right",
	cooldown = 0,
	attacks = {}	--the attacks that are currently being done to the player
	}

	setmetatable(object, {__index = Player})
	return object
end


--Action functions
function Player:jump()
	if self.canJump then
		self.ySpeed = self.jumpSpeed
		self.canJump = false
	end
end

function Player:stopJump()
	if self.ySpeed < 0 then
		self.ySpeed = self.ySpeed / 2
	end
end

function Player:moveRight()
	self.xSpeed = self.runSpeed
	self.state = "move"
	self.facing = "right"
end

function Player:moveLeft()
	self.xSpeed = -1 * (self.runSpeed)
	self.state = "move"
	self.facing = "left"
end

function Player:collide(event)
	if event == "floor" then
		self.ySpeed = 0
		self.onFloor = true
		self.canJump = true
	end
	if event == "ceiling" then
		self.ySpeed = 0
	end
end

function Player:attack()
	local temp
	if (self.cooldown == 0) then
		temp = Attack:new()
		temp.duration = 5
		temp.force = 500
		if (self.facing == "right") then
			--attack right
			temp.force = -temp.force
			--set attack position to be to the right of player	
		elseif (self.facing == "left") then
			--attack left
			
		end
		--this is only to test, remove later
		table.insert(self.attacks, temp)
		
		self.cooldown = 20
	end
	--create an attack object
	--set state to either "attackLeft" or "attackRight"
	return temp;
end

--Control functions
function Player:update(dt, gravity, friction, map)
	--short hand variables to keep track of the corners of the player
	--x and y refer to the center of the player, this is to find the bounding box for the player
	local halfX = self.width / 2
	local halfY = self.height / 2

	--apply gravity and friction
	self.ySpeed = self.ySpeed + (gravity * dt)
	--the player slides to a stop
	if math.abs(self.xSpeed) < (friction * dt) then 
		self.xSpeed = 0
	end
	if not(self.xSpeed == 0) then
		self.xSpeed = self.xSpeed - (friction * dt * (math.abs(self.xSpeed) / self.xSpeed))
	end
	--apply attacks, attacks override any user input
	for i,v in ipairs(self.attacks) do
		self.xSpeed = v.force
		self.ySpeed = -(math.abs(v.force))
		v.duration = v.duration - 1
		if (v.duration < 0) then
			table.remove(self.attacks, i)
		end
	end
	--limit the player's speed
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
		end
	elseif self.xSpeed < 0 then	--check left
		if not(self:isColliding(map, nextX - halfX, self.y - halfY))
			and not(self:isColliding(map, nextX - halfX, self.y + halfY - 1)) then
			self.x = nextX
		else
			self.x = nextX + self.width - ((nextX + halfX) % map.tileWidth)
		end
	end
	
	--update state
	self:getState()
	if (self.cooldown > 0) then
		self.cooldown = self.cooldown - 1
	end
end

--returns true if the coordinates given intersect a map tile
function Player:isColliding( map, x, y )
	-- body
	local layer = map.layers["Walls"]
	local tileX, tileY = math.floor(x/map.tileWidth), math.floor(y/map.tileHeight)

	local tile = layer:get(tileX, tileY)

	return not(tile == nil)

end
--calculates the state
function Player:getState()
	if math.abs(self.xSpeed) < (self.runSpeed / 2)then
		self.state = "stand"
	end
	if self.ySpeed < 0 then
		self.state = "jump"
	elseif self.ySpeed > 0 then
		self.state = "fall"
	end

end