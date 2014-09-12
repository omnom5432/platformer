
--called when the game is started
function love.load()
	g = love.graphics
	playerColour = {123, 0, 43}
	groundColour = {43, 54, 65}

	playerx = 400
	playery = 300
	playerH = 32
	playerW = 16
	playerState = "jump"
	
	velX = 0
	velY = 0
	grav = 1500
	friction = 20
	speed = 400
	jumpspeed = -800
	yFloor = 400
end

--called every frame
--dt = delta time, the time in seconds from the last frame
function love.update(dt)
	--get inputs
	if love.keyboard.isDown("right")then
		velX = speed
	end
	if love.keyboard.isDown("left") then
		velX = -1 * speed
	end
	if not(playerState == "jump") and love.keyboard.isDown("x") then
		velY = jumpspeed
		playerState = "jump"
	end

	--move player
	playerx, playery = playerx + (velX * dt), playery + (velY * dt)

	--apply gravity and friction
	velY = velY + (grav * dt)
	if velX < 0 then
		velX = velX + friction 
	end
	if velX >0 then
		velX = velX - friction
	end

	if playery >= yFloor - playerH then
		playery = yFloor - playerH
		velY = 0
		playerState = "stand"
	end
end
--also called every frame, used to draw the game
function love.draw()
	g.setColor(playerColour)
	g.rectangle("fill", playerx, playery, playerW, playerH)

	g.setColor(groundColour)
	g.rectangle("fill", 0, yFloor, 800, 100)
end

function love.keyreleased(key)
	if key == "escape" then
		love.event.push("quit")	--quit the game
	end
	if key == "x" then
		velY = velY / 2
	end
end