Class = require "libs.hump.class"
Player = Class{}
Hand = require "scenes.minigame_9.entities.hand"
local tween = require "libs.tween"

function Player:init(x, y, w, h, number) -- delay in seconds
	--All have a timer
	self.timer = 0
	--position size
	self.area = {}
	self.area.x = x
	self.area.y = y
	self.area.w = w
	self.area.h = h
	self.player_number = number

	--Needle hole position
	math.randomseed(os.time()* self.player_number)
	self.needle = {}
	self.needle.x = self.area.x + math.random( 100, self.area.w - 200)
	self.needle.y = self.area.y + 50
	self.needle.w = 35
	self.needle.h = 15
	self.needle.size = 45

	self.control = {}
	if self.player_number == 1 then
		self.control.left = "s"
		self.control.right = "f"
		self.control.up = "d"
	elseif self.player_number == 2 then
		self.control.left = "j"
		self.control.right = "l"
		self.control.up = "k"
	end

	--Physics
	--Physics
	love.physics.setMeter(64)
	self.world = love.physics.newWorld(0, 0, true)
	self.force = 250

	--Needle edges
	self.needle.left = {}
	self.needle.left.body = love.physics.newBody(self.world, self.needle.x + self.needle.h/2, self.needle.y + self.needle.h/2, "static")
	self.needle.left.shape = love.physics.newRectangleShape(self.needle.h, self.needle.h)
	self.needle.left.fixture = love.physics.newFixture(self.needle.left.body, self.needle.left.shape)

	self.needle.right = {}
	self.needle.right.body = love.physics.newBody(self.world, self.needle.x + self.needle.h/2 + self.needle.size , self.needle.y + self.needle.h/2, "static")
	self.needle.right.shape = love.physics.newRectangleShape(self.needle.h, self.needle.h)
	self.needle.right.fixture = love.physics.newFixture(self.needle.right.body, self.needle.right.shape)

	--Walls
	self.area.walls = self:set_walls()

	--Hand
	self.hand = Hand(self.area.x + self.area.w/2 - 100, self.area.y + self.area.h - 300, self.world)


	--WINNER
	self.winner = false


end


function Player:update(dt)
	--Update timer
	self.timer = self.timer + dt

	--Physics
	self.world:update(dt)

	--Hand
	self.hand:update(dt)

	if minigame_9.phase == "active" then
			if love.keyboard.isDown(self.control.left) then
				force = {-self.force, 0}
			elseif love.keyboard.isDown(self.control.right) then
				force = {self.force, 0}
			elseif love.keyboard.isDown(self.control.up) then
				force = { -minigame_9.wind.speed * minigame_9.wind.direction , -minigame_9.auto_advance_force}
			else
				force = {0, 0}
			end
			self.hand.physics.palm.body:applyForce(unpack(force))


		--HANDLE BUMP ON TOP
		if ((self.hand.thread.body:getY() - self.hand.thread.h/2) <= (self.needle.y - self.needle.h/2) - 30) and ( (self.hand.thread.body:getX() < self.needle.left.body:getX() ) or (self.hand.thread.body:getX() > self.needle.right.body:getX() ) ) then
			self.hand.tween = tween.new(1, self.hand, {x = self.hand.original_x + self.hand.w/2, y = self.hand.original_y + self.hand.h/2})
		--BUMP ON TOP WITH THREADED NEEDLE
		elseif ((self.hand.thread.body:getY() - self.hand.thread.h/2) <= (self.needle.y - self.needle.h/2) - 30) and ( (self.hand.thread.body:getX() > self.needle.left.body:getX() ) and (self.hand.thread.body:getX() < self.needle.right.body:getX() ) ) then
			self.hand.physics.palm.body:setLinearVelocity( 0,0 )
			self.winner = true
		end
	end


end

function Player:draw()

	--Area
	love.graphics.setColor(0.5, 0.5, 0.5)
	love.graphics.rectangle("fill", self.area.x, self.area.y, self.area.w, self.area.h)
	--Needle
	love.graphics.setColor(1, 0, 1)
	love.graphics.polygon("fill",self.needle.left.body:getWorldPoints(self.needle.left.shape:getPoints()))
	love.graphics.polygon("fill",self.needle.right.body:getWorldPoints(self.needle.right.shape:getPoints()))

		--tmp
	--love.graphics.setColor(0.5, 0.1, 0.1)
	for _, v in pairs(self.area.walls) do
		love.graphics.setColor(0.5, 0.1, 0.1)
		--love.graphics.rectangle("fill", v.body:getX(),  v.body:getY(), v.w, v.h)
		love.graphics.polygon("fill",v.body:getWorldPoints(v.shape:getPoints()))
	end
	--bottom of thread connecting to bottom of the screen
	love.graphics.polygon("fill",
						  self.hand.bottom_thread.x, self.hand.bottom_thread.y - 25,
						  self.hand.bottom_thread.x + self.hand.bottom_thread.w, self.hand.bottom_thread.y - 25,
						  self.area.x + self.area.w/2 - self.hand.bottom_thread.w/2 + self.hand.bottom_thread.w, self.area.y + self.area.h,
						   self.area.x + self.area.w/2 - self.hand.bottom_thread.w/2, self.area.y + self.area.h)

	--Hand
	self.hand:draw()
end

function Player:set_walls()
	self.area.walls = {}

	self.area.walls.top = {}
	self.area.walls.top.x = self.area.x
	self.area.walls.top.y = self.area.y
	self.area.walls.top.w = self.area.w
	self.area.walls.top.h = 5
	self.area.walls.top.body =  love.physics.newBody(self.world, self.area.walls.top.x + self.area.walls.top.w/2, self.area.walls.top.y + self.area.walls.top.h/2, "static")
	self.area.walls.top.shape = love.physics.newRectangleShape(self.area.walls.top.w, self.area.walls.top.h)
	self.area.walls.top.fixture = love.physics.newFixture(self.area.walls.top.body, self.area.walls.top.shape)
	self.area.walls.top.fixture:setUserData( "wall" )
	self.area.walls.top.fixture:setRestitution(1)

	self.area.walls.bottom = {}
	self.area.walls.bottom.x = self.area.x
	self.area.walls.bottom.y = self.area.y + self.area.h
	self.area.walls.bottom.w = self.area.w
	self.area.walls.bottom.h = 5
	self.area.walls.bottom.body =  love.physics.newBody(self.world, self.area.walls.bottom.x + self.area.walls.bottom.w/2, self.area.walls.bottom.y + self.area.walls.bottom.h/2, "static")
	self.area.walls.bottom.shape = love.physics.newRectangleShape(self.area.walls.bottom.w, self.area.walls.bottom.h)
	self.area.walls.bottom.fixture = love.physics.newFixture(self.area.walls.bottom.body, self.area.walls.bottom.shape)
	self.area.walls.bottom.fixture:setUserData( "wall" )
	self.area.walls.bottom.fixture:setRestitution(1)

	self.area.walls.right = {}
	self.area.walls.right.x = self.area.x + self.area.w + 1
	self.area.walls.right.y = self.area.y
	self.area.walls.right.w = 5
	self.area.walls.right.h = self.area.h
	self.area.walls.right.body =  love.physics.newBody(self.world, self.area.walls.right.x + self.area.walls.right.w/2, self.area.walls.right.y + self.area.walls.right.h/2, "static")
	self.area.walls.right.shape = love.physics.newRectangleShape(self.area.walls.right.w, self.area.walls.right.h)
	self.area.walls.right.fixture = love.physics.newFixture(self.area.walls.right.body, self.area.walls.right.shape)
	self.area.walls.right.fixture:setUserData( "wall" )
	self.area.walls.right.fixture:setRestitution(1)

	self.area.walls.left = {}
	self.area.walls.left.x = self.area.x - 1
	self.area.walls.left.y = self.area.y
	self.area.walls.left.w = 5
	self.area.walls.left.h = self.area.h
	self.area.walls.left.body =  love.physics.newBody(self.world, self.area.walls.left.x + self.area.walls.left.w/2, self.area.walls.left.y + self.area.walls.left.h/2, "static")
	self.area.walls.left.shape = love.physics.newRectangleShape(self.area.walls.left.w, self.area.walls.left.h)
	self.area.walls.left.fixture = love.physics.newFixture(self.area.walls.left.body, self.area.walls.left.shape)
	self.area.walls.left.fixture:setUserData( "wall" )
	self.area.walls.left.fixture:setRestitution(1)

	return self.area.walls
end

return Player
