-- game.status: 
-- 0 - not started
-- 1 - running
-- 2 - game over
require("AnAL")
window = {}
window.height = 640
window.width = 480
math.randomseed(os.time())

function love.load()
	love.window.setMode(window.width, window.height)

	-- world = love.physics.newWorld(0, 740, true);
	bird = {}
	bird.texture = love.graphics.newImage("bird.png");
	bird.object = newAnimation(bird.texture, 71, 49, 0.3, 0)
	bird.x = 180
	bird.y = 280
	bird.velocityY = 0
	-- bird.body = love.physics.newBody(world, bird.x, bird.y, "dynamic")
	-- bird.shape = love.physics.newRectangleShape(71, 49)
	-- bird.fixture = love.physics.newFixture(bird.body, bird.shape)
	-- bird.fixture:setUserData("bird")

	gravity = 1200
	jumpHeight = 380
	speed = 200
	distanceX = 380
	distanceY = 440

	score = {}
	score.num = 0
	score.x = 220
	score.y = 80

	ground = {}
	ground.height = 100
	ground.width = 480
	ground.x = 0
	ground.y = window.height - ground.height

	wallTexture = love.graphics.newImage("wall.png")
	wallTexture2 = love.graphics.newImage("wall2.png")
	walls = {}

	game = {}
	game.status = 0

	font = love.graphics.newFont("zekton.ttf", 52)
	love.graphics.setFont(font)

	generateWall()
end

function love.update(dt)
	bird.object:update(dt)

	if bird.velocityY ~= 0 then
		bird.y = bird.y - bird.velocityY * dt
		bird.velocityY = bird.velocityY - gravity * dt

		if bird.y < 0 then
			bird.velocityY = 0
			bird.y = 0
		end

		if (bird.y + 49) > ground.y then
			game.status = 2
			bird.velocityY = 0
			bird.y = ground.y - 49
		end
	end

	if game.status == 1 then
		moveWalls(dt)
	end

	if game.status == 2 then
		bird.velocityY = -400
	end

	if #walls < 2 then
		generateWall()
	end

	if walls[1].x < -100 then
		removeWall()
		generateWall()
		
	end

	if walls[1].x + 50 < bird.x and walls[1].flyed ~= true then
		score.num = score.num + 1
		walls[1].flyed = true
	end

	checkCollision()
	-- world:update(dt)
end

function love.keypressed(key)
	if key == "up" and game.status ~= 2 then
		bird.velocityY = jumpHeight
		game.status = 1
	end

	if key == "return" and game.status == 2 then
		love.load()
	end
end

function love.draw()
	love.graphics.setBackgroundColor(112, 197, 206);
	
	--draw walls 
	drawWalls()
	
	--draw player
	bird.object:draw(bird.x, bird.y)

	--draw ground
	drawGround()
	
 	--draw score
 	love.graphics.print(score.num, score.x, score.y)

 	if (game.status == 2) then
 		love.graphics.print("\tGame over\n  Enter to restart", score.x - 160, score.y + 100)
 	end
end

function drawGround()
	love.graphics.setColor(222, 216, 149)
	love.graphics.rectangle("fill", ground.x, ground.y, ground.width, ground.height)
	love.graphics.setColor(115, 191, 46)
	love.graphics.rectangle("fill", ground.x, ground.y, ground.width, 12)
	love.graphics.setColor(255, 255, 255)
end

function generateWall()
	wallCord = math.random(-200, 0)
	if walls[1] == nil then 
		wall = {x = window.width,  y = wallCord, x2 = window.width, y2 = wallCord + distanceY}
	else
		wall = {x = walls[#walls].x + distanceX, y = wallCord, x2 = walls[#walls].x + distanceX, y2 = wallCord + distanceY}
	end
	
	table.insert(walls, wall)
end

function removeWall()
	table.remove(walls, 1)
end

function moveWalls(dt)
	for key, value in pairs(walls) do
		value.x =  value.x - speed * dt
		value.x2 = value.x2 - speed * dt
	end
end


function drawWalls()
	for key, value in pairs(walls) do
		love.graphics.draw(wallTexture, value.x, value.y)
		love.graphics.draw(wallTexture2, value.x2, value.y2)
	end
end

function checkCollision()
	if walls[1].y + 300 > bird.y and walls[1].x < bird.x + 71 
	and bird.x < walls[1].x + 100 then
		game.status = 2
	end

	if walls[1].y2 < bird.y + 49 and walls[1].x2 < bird.x + 71 
	and bird.x < walls[1].x2 + 100 then
		game.status = 2
	end
end