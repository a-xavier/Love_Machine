Class = require "libs.hump.class"

Player = Class{
	init = function(self, x, y)
	love.physics.setMeter(64) --the height of a meter our worlds will be 64px
	self.world = love.physics.newWorld(0,640, true) --create a world for the bodies to exist in with horizontal gravity of 0 and vertical gravity of 9.81
	
	
	--defines playable area
	self.area = {} 
	self.area.x = x
	self.area.y = y
	self.area.w = global_width/2 - 100
	self.area.h = global_height - self.area.y - 100
	
	self.area.walls = {}
	
	self.area.walls.top = {}
	self.area.walls.top.x = self.area.x
	self.area.walls.top.y = self.area.y
	self.area.walls.top.w = self.area.w
	self.area.walls.top.h = 5
	self.area.walls.top.body =  love.physics.newBody( self.world, self.area.walls.top.x + self.area.walls.top.w/2, self.area.walls.top.y, "static")
	self.area.walls.top.shape = love.physics.newRectangleShape(self.area.walls.top.w, self.area.walls.top.h)
	self.area.walls.top.fixture = love.physics.newFixture(self.area.walls.top.body, self.area.walls.top.shape)
	
	self.area.walls.bottom = {}
	self.area.walls.bottom.x = self.area.x
	self.area.walls.bottom.y = self.area.y + self.area.h
	self.area.walls.bottom.w = self.area.w
	self.area.walls.bottom.h = 5
	self.area.walls.bottom.body =  love.physics.newBody( self.world, self.area.walls.bottom.x + self.area.walls.bottom.w/2 , self.area.walls.bottom.y, "static")
	self.area.walls.bottom.shape = love.physics.newRectangleShape(self.area.walls.bottom.w, self.area.walls.bottom.h)
	self.area.walls.bottom.fixture = love.physics.newFixture(self.area.walls.bottom.body, self.area.walls.bottom.shape)
	self.area.walls.bottom.fixture:setUserData( "ground" )
	
	self.area.walls.right = {}
	self.area.walls.right.x = self.area.x + self.area.w + 1
	self.area.walls.right.y = self.area.y
	self.area.walls.right.w = 5
	self.area.walls.right.h = self.area.h
	self.area.walls.right.body =  love.physics.newBody( self.world, self.area.walls.right.x, self.area.walls.right.y + self.area.walls.right.h/2, "static")
	self.area.walls.right.shape = love.physics.newRectangleShape(self.area.walls.right.w, self.area.walls.right.h)
	self.area.walls.right.fixture = love.physics.newFixture(self.area.walls.right.body, self.area.walls.right.shape)
	
	self.area.walls.left = {}
	self.area.walls.left.x = self.area.x - 1
	self.area.walls.left.y = self.area.y
	self.area.walls.left.w = 5
	self.area.walls.left.h = self.area.h
	self.area.walls.left.body =  love.physics.newBody( self.world, self.area.walls.left.x, self.area.walls.left.y + self.area.walls.left.h/2, "static")
	self.area.walls.left.shape = love.physics.newRectangleShape(self.area.walls.left.w, self.area.walls.left.h)
	self.area.walls.left.fixture = love.physics.newFixture(self.area.walls.left.body, self.area.walls.left.shape)
	
	--defines player body 
	
	self.body = {}
	self.body.w = 50
	self.body.h = 100
	self.body.x = self.area.x + 10
	self.body.y = self.area.y + self.area.h - self.body.h
	
	--define ball and behaviour of ball
	
	self.ball = {}
	self.ball.starting_position = {x = self.body.x + self.body.w + 20, y = self.body.y }
	self.ball.is_at_starting_position = true
	self.ball.x = self.ball.starting_position.x
	self.ball.y = self.ball.starting_position.y
	self.ball.r = 20
	self.ball.mass = 1
	self.ball.normal_gravity =  9.81*64
	self.ball.force = 0
	
	--ball physics 
	self.ball.body = love.physics.newBody(self.world,self.ball.x, self.ball.y, "dynamic")
	self.ball.shape = love.physics.newCircleShape(self.ball.r) --the ball's shape has a radius of 20
	self.ball.fixture = love.physics.newFixture(self.ball.body, self.ball.shape, self.ball.mass) 
	self.ball.fixture:setRestitution(0.75) -- Baased on random internet search
	
	--Set bounce ma for reset
	self.ball.ground_bounce = 0
	self.ball.ground_bounce_max = 2
	self.ball.ground_bounce_counted = false
	
	--arrow when pressing stuff 
	self.arrow = {}
	self.arrow.x1 = 0
	self.arrow.y1 = 0
	self.arrow.x2 = 0
	self.arrow.y2 = 0
	self.arrow.force = 10
	
	self.arrow.angle = 0
	self.arrow.outer_radius_default= 50
	self.arrow.outer_radius = 50
	
	-- reset ball at beginning
	self:reset_ball()
	
	-- Basket to score 
	-- 2 squares , if ball passed in the middle then score 
	self.basket = {}
	self.basket.size = 150
	
	self.basket.left = {}
	self.basket.left.w = 20
	self.basket.left.h = self.basket.left.w
	self.basket.left.x = self.area.x + self.area.w - self.basket.size - 2*self.basket.left.w
	self.basket.left.y = self.area.y + 200 --math.random(self.area.y, self.area.y - self.area.w)
	self.basket.left.body =  love.physics.newBody( self.world, self.basket.left.x + self.basket.left.w/2,self.basket.left.y + self.basket.left.h/2, "static")
	self.basket.left.shape = love.physics.newRectangleShape(self.basket.left.w, self.basket.left.h)
	self.basket.left.fixture = love.physics.newFixture(self.basket.left.body, self.basket.left.shape)
	

	
	self.basket.right = {}
	self.basket.right = {}
	self.basket.right.w = self.basket.left.w
	self.basket.right.h = self.basket.left.h
	self.basket.right.x = self.area.x + self.area.w - self.basket.right.w
	self.basket.right.y = self.basket.left.y
	self.basket.right.body =  love.physics.newBody( self.world, self.basket.right.x + self.basket.right.w/2,self.basket.right.y + self.basket.right.h/2, "static")
	self.basket.right.shape = love.physics.newRectangleShape(self.basket.right.w, self.basket.right.h)
	self.basket.right.fixture = love.physics.newFixture(self.basket.right.body, self.basket.right.shape)
	
	self.basket.global = {}
	self.basket.global.x = self.basket.left.x
	self.basket.global.y = self.basket.left.y
	self.basket.global.w = (self.basket.right.x + self.basket.right.w) - self.basket.left.x
	self.basket.global.h = self.basket.left.h 
	
	
	
	-- SCORE KEEPING 
	
	self.score = 0
	self.can_score = true 
	self.has_scored = false
	
	end
	}

function Player:update(dt)
	 self.world:update(dt * 1.75) 


	
	if self.ball.ground_bounce == self.ball.ground_bounce_max then
		self.ball.ground_bounce = 0
		self.can_score = true
		self:reset_ball()
	end

	 
	 --update x y for drawing ball
	 self.ball.x = self.ball.body:getX() 
	 self.ball.y = self.ball.body:getY()
	 
	 --No gravity when at starting point 
	if (self.ball.x == self.ball.starting_position.x) and (self.ball.y == self.ball.starting_position.y) then
		self.world:setGravity(0,0)
		
		self.ball.is_at_starting_position = true
		
		--modify self.arrow.angle outside of player in game
		
		--inner point
		self.arrow.x1 = self.ball.x + math.cos(self.arrow.angle) * (self.ball.r + 5)
		self.arrow.y1 = self.ball.y + math.sin(self.arrow.angle) * (self.ball.r + 5)
		
		--outer point
		self.arrow.x2 = self.ball.x + math.cos(self.arrow.angle) * (self.ball.r + self.arrow.outer_radius)
		self.arrow.y2 = self.ball.y + math.sin(self.arrow.angle) * (self.ball.r + self.arrow.outer_radius)
		
		self.arrow.length = distance_2_points(self.arrow.x1, self.arrow.y1, self.arrow.x2, self.arrow.y2)
	end
	
	--SCORING SYSTEM
	local vx, vy = self.ball.body:getLinearVelocity()
	if intersect_with_pointer(self.basket.global, self.ball) and (vy > 0) and (self.can_score == true) then 
		self.score = self.score + 1
		minigame_3.sounds.horn:play()
		self.can_score = false 
		self:reset_basket()
	end

end

function Player:draw()
	
	--area draw
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.area.x, self.area.y, self.area.w, self.area.h)
	
	--draw player body 
	love.graphics.setColor(1,0,0)
	love.graphics.rectangle("fill", self.body.x, self.body.y,self.body.w, self.body.h)
	
	--draw ball
	love.graphics.setColor(0.8,0.5,0.2)
	love.graphics.circle("fill", self.ball.x, self.ball.y, self.ball.r)
	
	--draw basket 
	love.graphics.setColor(0,0,1)
	love.graphics.rectangle("fill", self.basket.left.x, self.basket.left.y, self.basket.left.w, self.basket.left.h)
	love.graphics.rectangle("fill", self.basket.right.x, self.basket.right.y, self.basket.right.w, self.basket.right.h)
	
	love.graphics.setColor(1,0,1, 0.5)
	love.graphics.rectangle("fill", self.basket.global.x, self.basket.global.y, self.basket.global.w, self.basket.global.h)
	
	--Print Score 
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(minigame_3.font)
	love.graphics.printf("Score: "..tostring(self.score), self.area.x, self.area.y - minigame_3.font:getHeight(), self.area.w, "left")

	
	--draw arrow 
	if  self.ball.is_at_starting_position == true then
		love.graphics.setColor(0,0,0)
		love.graphics.arrow(self.arrow.x1, self.arrow.y1,self.arrow.x2, self.arrow.y2, 15, 0.35)
	end
	
	--printcontacts)
	love.graphics.setColor(1, 1, 1)
	
	--[[
	for k, v in pairs(self.area.walls) do
		love.graphics.setColor(0,1,0)
		love.graphics.rectangle("fill", v.body:getX(), v.body:getY(), v.w, v.h)
	end]]
	

end

function Player:reset_basket()
	--self.basket.left.y = math.random(self.area.y + 200, self.area.y + self.area.h - 200)
	
	--destry fixture first 
	self.basket.left.fixture:destroy()
	self.basket.right.fixture:destroy()
	
	
	
	self.basket.left = {}
	self.basket.left.w = 20
	self.basket.left.h = self.basket.left.w
	self.basket.left.x = self.area.x + self.area.w - self.basket.size - 2*self.basket.left.w
	self.basket.left.y = math.random(self.area.y + 200, self.area.y + self.area.h - 200)
	self.basket.left.body =  love.physics.newBody( self.world, self.basket.left.x + self.basket.left.w/2,self.basket.left.y + self.basket.left.h/2, "static")
	self.basket.left.shape = love.physics.newRectangleShape(self.basket.left.w, self.basket.left.h)
	self.basket.left.fixture = love.physics.newFixture(self.basket.left.body, self.basket.left.shape)
	

	
	self.basket.right = {}
	self.basket.right = {}
	self.basket.right.w = self.basket.left.w
	self.basket.right.h = self.basket.left.h
	self.basket.right.x = self.area.x + self.area.w - self.basket.right.w
	self.basket.right.y = self.basket.left.y
	self.basket.right.body =  love.physics.newBody( self.world, self.basket.right.x + self.basket.right.w/2,self.basket.right.y + self.basket.right.h/2, "static")
	self.basket.right.shape = love.physics.newRectangleShape(self.basket.right.w, self.basket.right.h)
	self.basket.right.fixture = love.physics.newFixture(self.basket.right.body, self.basket.right.shape)
	
	self.basket.global = {}
	self.basket.global.x = self.basket.left.x
	self.basket.global.y = self.basket.left.y
	self.basket.global.w = (self.basket.right.x + self.basket.right.w) - self.basket.left.x
	self.basket.global.h = self.basket.left.h 

end




function Player:reset_ball()
	self.ball.body:setX(self.ball.starting_position.x)
	self.ball.body:setY(self.ball.starting_position.y)
	self.world:setGravity(0,0)
	self.ball.body:setLinearVelocity(0,0)
end

function love.graphics.arrow(x1, y1, x2, y2, arrlen, angle)
	love.graphics.line(x1, y1, x2, y2)
	local a = math.atan2(y1 - y2, x1 - x2)
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a + angle), y2 + arrlen * math.sin(a + angle))
	love.graphics.line(x2, y2, x2 + arrlen * math.cos(a - angle), y2 + arrlen * math.sin(a - angle))
end

return Player