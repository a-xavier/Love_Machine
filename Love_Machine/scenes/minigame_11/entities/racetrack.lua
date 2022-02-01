Racetrack = Class{}

function Racetrack:init() -- delay in seconds
	--All have a timer
	self.timer = 0
	--position size
	self.track_width = 175

	self.start_flag = love.graphics.newImage( "scenes/minigame_11/img/start_flag.png")

	self.rectangle_holder = {}

	--Create all rectangle forming the track
	self.rectangle_holder[1] = {x = 50, y = 50, w = self.track_width, h = global_height - 100}

	self.rectangle_holder[2] = {x = self.rectangle_holder[1].x,
								y = self.rectangle_holder[1].y + self.rectangle_holder[1].h - self.track_width ,
	 							w = global_width - self.rectangle_holder[1].x - 50,
								h = self.track_width}

	self.rectangle_holder[3] = {x = self.rectangle_holder[2].x + self.rectangle_holder[2].w - self.track_width,
								y = 400,
	 							w = self.track_width,
								h = global_height - 400 - 50}

	self.rectangle_holder[4] = {x = self.rectangle_holder[3].x - 500 + self.track_width ,
								y = self.rectangle_holder[3].y,
	 							w = 500 - self.track_width,
								h =  self.track_width}

	self.rectangle_holder[5] = {x = self.rectangle_holder[4].x ,
								y = self.rectangle_holder[4].y,
	 							w = self.track_width,
								h = global_height - self.rectangle_holder[2].y + self.track_width}

	self.rectangle_holder[6] = {x = self.rectangle_holder[5].x + self.rectangle_holder[5].w - self.rectangle_holder[4].w,
								y = self.rectangle_holder[5].y + self.rectangle_holder[5].h - self.track_width,
	 							w = self.rectangle_holder[4].w,
								h = self.track_width}
	self.rectangle_holder[7] = {x = self.rectangle_holder[6].x - self.track_width,
								y = self.rectangle_holder[5].y,
	 							w = self.track_width,
								h = self.rectangle_holder[5].h}

	self.rectangle_holder[8] = {x = self.rectangle_holder[7].x - self.rectangle_holder[4].w,
								y = self.rectangle_holder[7].y,
	 							w = self.rectangle_holder[4].w,
								h = self.track_width}

	self.rectangle_holder[9] = {x = self.rectangle_holder[8].x ,
								y = self.rectangle_holder[7].y,
	 							w = self.track_width,
								h = self.rectangle_holder[7].h}

	self.rectangle_holder[10] = {x = self.rectangle_holder[8].x - self.rectangle_holder[4].w,
								y = self.rectangle_holder[6].y,
	 							w = self.rectangle_holder[8].w,
								h = self.track_width}

	self.rectangle_holder[11] = {x = self.rectangle_holder[10].x ,
								y = self.rectangle_holder[1].y + self.track_width,
	 							w = self.track_width,
								h = global_height - self.rectangle_holder[10].y - self.rectangle_holder[1].y  }
	self.rectangle_holder[12] = {x = self.rectangle_holder[11].x ,
								y = self.rectangle_holder[11].y ,
	 							w = global_width - 50  -  self.rectangle_holder[11].x,
								h = self.track_width}
	self.rectangle_holder[13] = {x = self.rectangle_holder[3].x ,
								y = self.rectangle_holder[1].y ,
	 							w = self.track_width,
								h = 2*self.track_width}

	--last
	self.rectangle_holder[14] = {x = self.rectangle_holder[1].x ,
								y = self.rectangle_holder[1].y ,
	 							w = self.rectangle_holder[2].w,
								h = self.track_width}
	for k, v in pairs(self.rectangle_holder) do
		v.tag = "track"
	end

	--Create all rectangle forming the barriers
	self.barrier_holder = {}
	self.barrier_width = 5

	self.barrier_holder[1] = {x =self.rectangle_holder[12].x,- self.barrier_width,
 							  y =self.rectangle_holder[12].y ,
						   	  w = self.barrier_width,
						  	  h = self.rectangle_holder[12].h + self.rectangle_holder[11].h, self.rectangle_holder[10].h}

	self.barrier_holder[2] = {x = self.barrier_holder[1].x,
								  y = self.barrier_holder[1].y + self.barrier_holder[1].h,
							   	  w = self.rectangle_holder[5].x + self.track_width - self.rectangle_holder[10].x ,
							  	  h = self.barrier_width}

  	self.barrier_holder[3] = {x = self.rectangle_holder[6].x + self.rectangle_holder[6].w,
								y =self.rectangle_holder[6].y,
							   	w = self.barrier_width ,
							  	h = self.rectangle_holder[6].h}

	self.barrier_holder[4] = {x = self.rectangle_holder[12].x + self.track_width,
								y = self.rectangle_holder[12].y + self.track_width,
								w = self.rectangle_holder[3].x - self.rectangle_holder[12].x,
								h = self.barrier_width}

	self.barrier_holder[5] = {x = self.rectangle_holder[14].x + self.track_width + 25, -- 25 offset hack
								y = self.rectangle_holder[14].y + self.track_width,
								w = self.rectangle_holder[3].x - self.rectangle_holder[14].x - self.track_width -25,
								h = self.barrier_width}



	for k, v in pairs(self.barrier_holder) do
		v.tag = "barrier"
	end

	--Create checkpoints

	self.checkpoint_holder = {}

	self.checkpoint_holder[1] = {x = self.rectangle_holder[3].x - self.track_width,
								y = self.rectangle_holder[2].y,
								w = 3 * self.track_width,
								h = 5,
								tag = "checkpoint",
								tag_counted_player_1 = false,
								tag_counted_player_2 = false}

	self.checkpoint_holder[2] = {x = self.rectangle_holder[3].x,
								y = self.rectangle_holder[1].y + self.track_width,
								w =2 * self.track_width,
								h = 5,
								tag = "checkpoint",
								tag_counted_player_1 = false,
								tag_counted_player_2 = false}

	self.start_line = {x = self.rectangle_holder[1].x,
								y = 420,
								w = self.track_width,
								h = 5,
								tag = "start",
								tag_counted_player_1 = false,
								tag_counted_player_2 = false}

end


function Racetrack:update(dt)
	--Update timer
	self.timer = self.timer + dt

end

function Racetrack:draw()
	--track
	for k, v in pairs(self.rectangle_holder) do
		love.graphics.setColor(1, 1, 1, 0.25)
		--love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
		love.graphics.setColor(0, 0, 0, 1, 0.25)
		--love.graphics.rectangle("line", v.x, v.y, v.w, v.h)
		--love.graphics.print(k, v.x, v.y)
	end
	--barriers
	for k, v in pairs(self.barrier_holder) do
		love.graphics.setColor(0, 0.9, 0.7, 0.25)
		--love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
	end

	--Checkpoints
	--barriers
	for k, v in pairs(self.checkpoint_holder) do
		love.graphics.setColor(0.9, 0.1, 0.7, 0.25)
		--love.graphics.rectangle("fill", v.x, v.y, v.w, v.h)
		love.graphics.setColor(0,0,0, 0.5)
		--love.graphics.print("Checkpoint "..tostring(k),  v.x, v.y)
	end
	love.graphics.setColor(0.9, 0.9, 0.7, 0.25)
	love.graphics.rectangle("fill", self.start_line.x, self.start_line.y, self.start_line.w, self.start_line.h)
	love.graphics.setColor(0,0,0, 0.5)
	--love.graphics.print("START LINE", self.start_line.x, self.start_line.y)

end

return Racetrack
