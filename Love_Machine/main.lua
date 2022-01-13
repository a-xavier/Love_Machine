gamestate = require "libs.hump.gamestate"
push = require "libs.push" -- FOR RESOLUTION
-- Debug Tag
global_debug = true
global_width = 1920
global_height = 1080
default_font = love.graphics.newFont(14)


function love.load()
	-- MOUSE INVISIBLE AT ALL TIME
	--love.mouse.setVisible(false)

	-- LOAD ALL SCENES
	titlescreen = require "scenes.titlescreen.titlescreen"
	minigame_1 = require "scenes.minigame_1.minigame_1"
	minigame_2 = require "scenes.minigame_2.minigame_2"
	minigame_3 = require "scenes.minigame_3.minigame_3"
	minigame_4 = require "scenes.minigame_4.minigame_4"
	minigame_5 = require "scenes.minigame_5.minigame_5"
	minigame_6 = require "scenes.minigame_6.minigame_6"
	minigame_7 = require "scenes.minigame_7.minigame_7"
	minigame_8 = require "scenes.minigame_8.minigame_8"
	minigame_9 = require "scenes.minigame_9.minigame_9"
	splashscreen = require "scenes.splashscreen.splashscreen"
	scoreboard = require "scenes.scoreboard.scoreboard"

	--GLOBALS
	global_game_holder = {minigame_1,
						  minigame_2,
						  minigame_3,
						  minigame_4,
						  minigame_5,
						  minigame_6,
						  minigame_7,
						  minigame_8,
						  minigame_9}
	global_current_game_index = 0
	global_difficulty = 1
	global_game_finished = 0

	global_score_counter = {p1 = 0, p2 = 0}

	-- GAMESTATE INITIALISATION
	-- NEEDED FOR HUMP GAMESTATE TO WORK
	gamestate.registerEvents()

	-- INIT TO AVOID LOADINGS
	titlescreen:init()

	-- CHANGES TO TEST DIRECTLY LV1
	gamestate.switch(splashscreen)
	 -- SET PROPER SIZE

end

function love.update()

end

function love.draw()

end

-- QUICK QUIT for QUICK TESTS
function love.keyreleased(key)
   if key == "escape" then
      love.event.quit()
   end
end

function draw_debug()
	if global_debug == true then
		love.graphics.setColor(0.8,0.8,0.8)
		love.graphics.setFont(default_font)
		love.graphics.print("Width: "..tostring(love.graphics.getWidth( )), 10, 10)
		love.graphics.print("Height: "..tostring(love.graphics.getHeight( )), 10, 25)
		love.graphics.print("FPS : "..tostring(love.timer.getFPS( )), 10, 40)
		love.graphics.setColor(0,0,0)
	end
end

-- TESTS COLISION FOR 2 OBJECTS WITH WIDTH AND X Y
function intersect_with_pointer(object, pointer)
	if pointer.x then
		if object.x < pointer.x  and (object.x + object.w) > pointer.x and object.y < pointer.y and (object.y + object.h) > pointer.y then
			interacting =  true
		else
			interacting =  false
		end
		return interacting
	else
		return false
	end
end

-- distance between 2 points

function distance_2_points(x1, y1, x2, y2)
--√ (x2 − x1)2 + (y2 − y1)2
return math.sqrt( math.pow(x2 - x1, 2) + math.pow(y2 - y1, 2))
end
