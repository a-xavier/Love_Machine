Class = require "libs.hump.class"

Profiler = Class{}

function Profiler:init() -- delay in seconds
	--All have a timer
	self.timer = 0
	self.frame = 0

	self.profiler = require "libs.profile"
	self.profiler.start()
end


function Profiler:update(dt)
	--Update timer
	self.timer = self.timer + dt
	self.frame = self.frame + 1

	 if self.frame%100 == 0 then
		self.report = self.profiler.report(20)
		self.profiler.reset()
	end

end

function Profiler:draw()
	if global_debug == true then
		love.graphics.setColor(0.5, 0.5,0.5, 1)
		love.graphics.print(self.report or "Please wait...", 50, 200)
	end
end

return Profiler
