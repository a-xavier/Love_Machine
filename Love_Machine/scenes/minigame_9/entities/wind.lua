--Wind directio PUT IN OWN FILE LATER
-- QUICK AND DIRTY CLASS?
	math.randomseed(os.time())
	wind = {}
	local tween = require "libs.tween"
	wind.img = love.graphics.newImage( "scenes/minigame_9/img/wind_speck.png")
	direction_choice = {-1, 1}
	wind.direction = direction_choice[math.random(2)] --either going to left or right
	wind.speed = 200 -- math.random(100, 200)
	wind.speck_number = 50
	wind.tween_holder = {}
	wind.speck_holder = {}
	if wind.direction == 1 then
		for i = 1, wind.speck_number, 1 do
			local speck = {x = -20,
						   y = math.random(0, global_height),
						   alpha = math.random() - 0.2,
						   time_to_get_there = math.random(100, 500)/wind.speed}
			table.insert(wind.speck_holder, speck)
		end
	else
		for i = 1, wind.speck_number, 1 do
			local speck = {x = global_width + 20,
						   y = math.random(0, global_height),
						    alpha = math.random()- 0.2,
						   time_to_get_there = math.random(100, 500)/wind.speed}
			table.insert(wind.speck_holder, speck)
		end
	end

	if wind.direction == 1 then
		for k , v in pairs(wind.speck_holder) do
			local choices = {"inOutSine", "outInSine"}
			local easing = choices[math.random(2)]
			table.insert(wind.tween_holder, tween.new(v.time_to_get_there, v, {x = global_width + 20 + math.random(0, global_width)}, "linear"))
			wind.tween_holder[k]:set(v.time_to_get_there * math.random())
		end
	else
		for k , v in pairs(wind.speck_holder) do
			local choices = { "inOutSine", "outInSine"}
			local easing = choices[math.random(2)]
			table.insert(wind.tween_holder, tween.new(v.time_to_get_there, v, {x = -20 - math.random(0, global_width)}, "linear"))
			wind.tween_holder[k]:set(v.time_to_get_there * math.random())
		end
	end


function wind:reset()
math.randomseed(os.time())
direction_choice = {-1, 1}
	wind.direction = -wind.direction
	wind.speed = math.random(100, 200)
	wind.speck_number = 50
	wind.tween_holder = {}
	wind.speck_holder = {}
	if wind.direction == 1 then
		for i = 1, wind.speck_number, 1 do
			local speck = {x = -20,
						   y = math.random(0, global_height),
						   alpha = math.random(),
						   time_to_get_there = math.random(100, 500)/wind.speed}
			table.insert(wind.speck_holder, speck)
		end
	else
		for i = 1, wind.speck_number, 1 do
			local speck = {x = global_width + 20,
						   y = math.random(0, global_height),
						    alpha = math.random(),
						   time_to_get_there = math.random(100, 500)/wind.speed}
			table.insert(wind.speck_holder, speck)
		end
	end

	if wind.direction == 1 then
		for k , v in pairs(wind.speck_holder) do
			local choices = {"inOutSine", "outInSine"}
			local easing = choices[math.random(2)]
			table.insert(wind.tween_holder, tween.new(v.time_to_get_there, v, {x = global_width + 20 + math.random(0, global_width)}, "linear"))
			wind.tween_holder[k]:set(v.time_to_get_there * math.random())
		end
	else
		for k , v in pairs(wind.speck_holder) do
			local choices = { "inOutSine", "outInSine"}
			local easing = choices[math.random(2)]
			table.insert(wind.tween_holder, tween.new(v.time_to_get_there, v, {x = -20 - math.random(0, global_width)}, "linear"))
			wind.tween_holder[k]:set(v.time_to_get_there * math.random())
		end
	end
end

return wind
