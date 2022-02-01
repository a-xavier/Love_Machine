local Platforms = Class{}

function Platforms:init() -- delay in seconds
	--All have a timer
	self.timer = 0
	--position size
	self.x = x
	self.y = y
	self.offset = 50

	self.measures = {}
	self.measures.hole_size = 200
	self.measures.platform_height = 50
	self.measures.platform_distance = 190

	--Build the initial platforms
	self.platform_holder = {}
	math.randomseed(os.time())
	local index = 0
	local y_index = global_height
	while index <= 150 do
		if index == 0 then
			local platform = {}
			platform.left = {}
			platform.left.x = -self.offset
			platform.left.y = global_height - (index+1) * self.measures.platform_height - index * self.measures.platform_distance
			platform.left.w = global_width + 2*self.offset
			platform.left.h = self.measures.platform_height
			platform.right = {}
			platform.right.x = -10000
			platform.right.y = -10000
			platform.right.w = 1
			platform.right.h = 1
			platform.color = {math.random(), math.random(), math.random()}
			y_index = platform.left.y
			index = index + 1
			platform.index = index
			platform.left.tag = "floor"
			platform.right.tag = "floor"
			platform.left.physics = "solid"
			platform.right.physics = "solid"
			platform.right.index = index
			platform.left.index = index
			table.insert(self.platform_holder, platform)

		else
			local hole_location = math.random(100, global_width - self.measures.hole_size - 200) -- 100 is padding left and right
			local platform = {}
			--Left part of the platform
			platform.hole_x_left = hole_location
			platform.hole_x_right = hole_location + self.measures.hole_size

			platform.left = {}
			platform.left.x = -self.offset -- OFFSET
			platform.left.y = global_height - (index+1) * self.measures.platform_height - index * self.measures.platform_distance
			platform.left.w = hole_location + self.offset
			platform.left.h = self.measures.platform_height

			platform.right = {}
			platform.right.x = hole_location + self.measures.hole_size
			platform.right.y = platform.left.y
			platform.right.w = global_width - platform.right.x + self.offset
			platform.right.h = self.measures.platform_height

			platform.color = {math.random(), math.random(), math.random()}
			y_index = platform.left.y
			index = index + 1
			platform.index = index
			platform.left.tag = "floor"
			platform.right.tag = "floor"
			platform.left.physics = "solid"
			platform.right.physics = "solid"
			platform.right.index = index
			platform.left.index = index
			platform.right.side = "right"
			platform.left.side = "left"

			table.insert(self.platform_holder, platform)
		end

	end

	print(#self.platform_holder)
end


function Platforms:update(dt)
	--Update timer
	self.timer = self.timer + dt

end

function Platforms:draw()
	--Draw platforms
	for k, v in pairs(self.platform_holder) do
		love.graphics.setColor(v.color)
		love.graphics.rectangle("fill", v.left.x, v.left.y, v.left.w, v.left.h )
		love.graphics.rectangle("fill", v.right.x, v.right.y, v.right.w, v.right.h )
	end

end


return Platforms
