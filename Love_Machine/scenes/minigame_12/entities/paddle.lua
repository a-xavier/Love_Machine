Paddle = Class{}

function Paddle:init(x, y, number) -- delay in seconds
	--All have a timer
	local Draft = require "libs.draft"
	local draft = Draft()
	self.timer = 0
	--position size
	self.x = x
	self.y = y
	self.player_number = number

	self.w = 300
	self.h = 5
	self.curve_h = 75

	if self.player_number == 1 then
		self.paddle_points = draft:ellipticBow(0, 0, self.w, self.curve_h, math.pi, 0, 100, false)
		table.insert(self.paddle_points, - self.w/2)
		table.insert(self.paddle_points, - self.h)
		table.insert(self.paddle_points,  self.w/2)
		table.insert(self.paddle_points, - self.h)
	elseif  self.player_number == 2 then
		self.paddle_points = draft:ellipticBow(0, 0, self.w, self.curve_h, math.pi, math.pi, 100, false)
		table.insert(self.paddle_points, self.w/2)
		table.insert(self.paddle_points, self.h)
		table.insert(self.paddle_points, - self.w/2)
		table.insert(self.paddle_points, self.h)
	end

	self.body = love.physics.newBody(minigame_12.world, self.x, self.y , "dynamic" )
	self.shape = love.physics.newChainShape( true, self.paddle_points)
	self.fixture = love.physics.newFixture( self.body, self.shape, 1)
	self.fixture:setRestitution( 1 )
	self.fixture:setUserData( {"paddle", self.player_number} )
	self.body:setLinearDamping( 7.5 )
	self.body:setAngle(0)
	self.body:setMass( 75 )

	--controls
	if self.player_number == 1 then
		self.left_key = "s"
		self.right_key = "f"
	elseif self.player_number == 2 then
		self.left_key = "j"
		self.right_key = "l"
	end

	self.speed = 800000

	--Make the polygon points
	--from left to right
end


function Paddle:update(dt)
	--Update timer
	self.timer = self.timer + dt
	--Always keep same y
	self.body:setY(self.y)

	if love.keyboard.isDown(self.left_key) then
		self.body:applyForce( -self.speed, 0 )
	end
	if love.keyboard.isDown(self.right_key) then
		self.body:applyForce(self.speed, 0 )
	end

	-- IF REACHES THE EXTREMITIES
	if self.body:getX() > minigame_12.play_area.x + minigame_12.play_area.w - self.w/2 then
		self.body:setLinearVelocity( 0,0 )
		self.body:applyForce( -self.speed, 0 )
	elseif self.body:getX() < minigame_12.play_area.x + self.w/2 then
		self.body:setLinearVelocity( 0,0 )
		self.body:applyForce( self.speed, 0 )
	end


end

function Paddle:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.polygon("fill", self.body:getWorldPoints(self.shape:getPoints()))
	love.graphics.setColor(1,0,0)
	--love.graphics.rectangle("fill", self.body:getX() - 5 , self.body:getY() - 5, 10, 10)

end

return Paddle
