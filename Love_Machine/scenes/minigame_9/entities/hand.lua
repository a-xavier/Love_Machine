Class = require "libs.hump.class"

Hand = Class{}

function Hand:init(x, y, world) -- delay in seconds
	--All have a timer
	self.timer = 0
	--position size
	self.x = x
	self.original_x = x
	self.original_y = y
	self.y = y
	self.w = 200
	self.h = 300

	self.image = {}
	self.image.img = love.graphics.newImage( "scenes/minigame_9/img/hand.png")
	self.image.x = 0
	self.image.y = 0
	self.image.w = 1080
	self.image.h = 310

	--[[objects.ground.body = love.physics.newBody(world, 650/2, 650-50/2) --remember, the shape (the rectangle we create next) anchors to the body from its center, so we have to move it to (650/2, 650-50/2)
	objects.ground.shape = love.physics.newRectangleShape(650, 50) --make a rectangle with a width of 650 and a height of 50
	objects.ground.fixture = love.physics.newFixture(objects.ground.body, objects.ground.shape) --attach shape to body]]

	--Physics
	self.physics = {}

	--Palm holding the thread
	self.physics.palm = {}
	self.physics.palm.body = love.physics.newBody(world, self.x + self.w/2, self.y + self.h/2, "dynamic")
	self.physics.palm.shape = love.physics.newRectangleShape(self.w, self.h)
	self.physics.palm.fixture = love.physics.newFixture(self.physics.palm.body, self.physics.palm.shape, 1)
	self.physics.palm.body:setY(self.physics.palm.body:getY() - 15)
	self.physics.palm.body:setLinearDamping(0.5)
	self.physics.palm.body:setMass(1)

	self.thread = {}
	self.thread.img = love.graphics.newImage( "scenes/minigame_9/img/thread.png")
	self.thread.w = 20
	self.thread.h = 70
	self.thread.body = love.physics.newBody(world, self.x + self.w/2,  self.y - self.thread.h/2 -5, "dynamic")
	self.thread.shape = love.physics.newRectangleShape(self.thread.w, self.thread.h)
	self.thread.fixture = love.physics.newFixture(self.thread.body, self.thread.shape)

	self.thread.joint = love.physics.newWeldJoint( self.thread.body, self.physics.palm.body, self.x + self.w/2, self.y - self.thread.h/2 -5 , false )
	--bottom of thread for connecting
	self.bottom_thread = {}
	self.bottom_thread.w = 20
	self.bottom_thread.x = self.physics.palm.body:getX() - self.bottom_thread.w/20
	self.bottom_thread.y = self.physics.palm.body:getY() + self.h/2

		--image of hand
	self.image.x = self.bottom_thread.x
	self.image.y = self.bottom_thread.y



end


function Hand:update(dt)
	--Update timer
	self.timer = self.timer + dt
	--update position for printing
	self.physics.palm.body:setAngle( 0 )
	--Botton of the threads
	self.bottom_thread.x = self.physics.palm.body:getX() - self.bottom_thread.w/20
	self.bottom_thread.y = self.physics.palm.body:getY() + self.h/2
	--move image of hand
		--image of hand
	self.image.x = self.bottom_thread.x
	self.image.y = self.bottom_thread.y

	--keep track of palm
	if self.tween == nil then
		self.x = self.physics.palm.body:getX()
		self.y = self.physics.palm.body:getY()
	end

	if self.tween ~= nil then
		self.physics.palm.body:setX(self.x)
		self.physics.palm.body:setY(self.y)
		self.tween:update(dt)
		if self.tween:update(dt) == true then
			self.tween = nil
			self.physics.palm.body:setLinearVelocity( 0,0 )
		end
	end

end

function Hand:draw()
	love.graphics.setColor(1,1,1)
	--love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	--Draw based on physics
	--love.graphics.polygon("fill",self.physics.palm.body:getWorldPoints(self.physics.palm.shape:getPoints()))
	local shake_x = math.random(-2,2)
	local shake_y = math.random(-2,2)
	--Draw thread
	love.graphics.setColor(1,0,0)
	--love.graphics.polygon("fill",self.thread.body:getWorldPoints(self.thread.shape:getPoints()))
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.thread.img, self.thread.body:getX() - self.thread.w/2 + shake_x, self.thread.body:getY() - self.thread.h/2 + shake_y)

	--hand image
	love.graphics.setColor(1,1,1)
	love.graphics.draw(self.image.img, self.image.x + shake_x, self.image.y + shake_y, 0, 1, 1, 997, 300)


end

return Hand
