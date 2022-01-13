Class = require "libs.hump.class"
Player = Class{}
local tween = require "libs.tween"

function Player:init(x, y, number) -- delay in seconds
	--position size
	self.x = x
	self.y = y
	self.w = 200
	self.h = 400
	
	self.player_number = number
	--timer
	self.timer = math.random(1, 10)
	--can shoot
	self.can_shoot = false
	self.shoot_triggered = false 
	self.has_shot = false
	
	self.premature_shooter = false
	self.killer = false
	self.dead = false
	self.killed = false
	
	self.show_bang_timer = 0
	self.show_bang_timer_max = 0.05
	
	self.shot_sound = love.audio.newSource( "scenes/minigame_7/sound/gunshot.ogg", "static")
	
	--Anims and 
	self.spritesheet = love.graphics.newImage( "scenes/minigame_7/img/player_"..tostring(self.player_number)..".png")
	self.blood_img = love.graphics.newImage( "scenes/minigame_7/img/blood_player_"..tostring(self.player_number)..".png")
	self.quads = {love.graphics.newQuad(0, 0, self.w, self.h, self.spritesheet:getWidth(), self.spritesheet:getHeight() ),
				  love.graphics.newQuad(self.w, 0, self.w, self.h, self.spritesheet:getWidth(), self.spritesheet:getHeight() ),
				  love.graphics.newQuad(2*self.w, 0, self.w, self.h, self.spritesheet:getWidth(), self.spritesheet:getHeight() ),
				  love.graphics.newQuad(0, self.h, self.w, self.h, self.spritesheet:getWidth(), self.spritesheet:getHeight() ),
				  love.graphics.newQuad(self.w, self.h, self.w, self.h, self.spritesheet:getWidth(), self.spritesheet:getHeight() )}
	self.current_quad = 1
	
	if self.player_number == 1 then
		self.gun_x = 160 + self.x
		self.gun_y = 180 + self.y
	elseif self.player_number == 2 then
		self.gun_x = 37 + self.x
		self.gun_y = 180 + self.y
	end
	
	--particle
	self.smoke = love.graphics.newImage( "scenes/minigame_7/img/smoke.png")
	self.particle_system = love.graphics.newParticleSystem(self.smoke, 10000)
	self.particle_system:setParticleLifetime(2, 10) -- Particles live at least 2s and at most 5s.
	self.particle_system:setEmissionRate(50)
	self.particle_system:setSizes( 0.1, 0.5, 1, 2, 3, 4 )
	self.particle_system:setLinearAcceleration(-5, -50, 5, -100) -- Random movement in all directions.
	self.particle_system:setColors(1, 1, 1, 1, 1, 1, 1, 0) -- Fade to transparency.
	self.particle_system:setLinearDamping( 0, 1 )
	
	--bullet 
	self.bullet = {}
	self.bullet.img = love.graphics.newImage( "scenes/minigame_7/img/bullet.png")
	self.bullet.x = self.gun_x
	self.bullet.y = self.gun_y
	
end


function Player:update(dt)
	--always update own timer 
	self.timer = self.timer + 5*dt
	
	--resolve shooting 
	if (self.shoot_triggered == true) and (minigame_7.allowed_to_shoot == false) then
		minigame_7.phase = "outro"
		if self.player_number == 1 then minigame_7.winner = "player_2" end
		if self.player_number == 2 then minigame_7.winner = "player_1" end
		self.premature_shooter = true
		self.current_quad = 4
	end

	if (self.shoot_triggered == true) and (minigame_7.allowed_to_shoot == true) and (minigame_7.phase == "active") then
		minigame_7.phase = "outro"
		self.shot_sound:play()
		if self.player_number == 1 then minigame_7.winner = "player_1" end
		if self.player_number == 2 then minigame_7.winner = "player_2" end
		self.killer = true
		self.current_quad = 5
		--create tween
		if self.player_number == 1 then
			self.bullet_tween = tween.new(0.1, self.bullet, {x = global_width})
		else
			self.bullet_tween = tween.new(0.1, self.bullet, {x = 0})
		end
	end
	
	--Particles
	if self.killer == true then 
		self.particle_system:update(dt)
		self.bullet_tween:update(dt)
	end 
	
	--BANG SHOW TIMER 
	if (self.killer == true) and (minigame_7.phase == "outro") then 
		self.show_bang_timer = self.show_bang_timer + dt 
		if self.show_bang_timer >= self.show_bang_timer_max then self.current_quad = 4 end
	end

	
	--update anim
	if (self.shoot_triggered == false) and (self.killed == false) then
		if math.floor(self.timer%8) == 0 then
			self.current_quad = 1
		elseif math.floor(self.timer%8) == 1 then
			self.current_quad = 2
		elseif math.floor(self.timer%8) == 2  then
			self.current_quad = 3
		elseif math.floor(self.timer%8) == 3  then
			self.current_quad = 2
		else
			self.current_quad = 1
		end
	end
	

end

function Player:draw()
	love.graphics.setColor(1, 1, 1)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)
	love.graphics.draw(self.spritesheet, self.quads[self.current_quad], self.x, self.y)
	if self.killed == true then 
		love.graphics.draw(self.blood_img, self.x, self.y)
	end
	if self.killer == true then 
		self.particle_system:start()
		love.graphics.draw(self.particle_system, self.gun_x, self.gun_y)
		love.graphics.draw(self.bullet.img, self.bullet.x, self.bullet.y)
	end 


end

return Player