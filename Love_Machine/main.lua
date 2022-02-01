gamestate = require "libs.hump.gamestate"
Class = require "libs.hump.class"
tween  = require "libs.tween"

-- Debug Tag
global_debug = true
global_width = 1920
global_height = 1080
default_font = love.graphics.newFont(14)

--GC TESTS
collectgarbage ("setstepmul", 120)
collectgarbage ("setpause", 80)


function love.load()
	-- MOUSE INVISIBLE AT ALL TIME
	love.mouse.setVisible(false)

	-- LOAD ALL SCENES
	titlescreen = require "scenes.titlescreen.titlescreen"
	--splashscreen = require "scenes.splashscreen.splashscreen" -- Give up splashscreen
	scoreboard = require "scenes.scoreboard.scoreboard"

	--SINGLE GAME MODE
	choose_game = require "scenes.choose_game.choose_game"

	--Reference to path of all minigames

	global_reference_table = {"scenes.minigame_1.minigame_1",
							  "scenes.minigame_2.minigame_2",
							  "scenes.minigame_3.minigame_3",
							  "scenes.minigame_4.minigame_4",
							  "scenes.minigame_5.minigame_5",
							  "scenes.minigame_6.minigame_6",
							  "scenes.minigame_7.minigame_7",
							  "scenes.minigame_8.minigame_8",
							  "scenes.minigame_9.minigame_9",
							  "scenes.minigame_10.minigame_10",
						  	"scenes.minigame_11.minigame_11",
						  	"scenes.minigame_12.minigame_12",
						  	"scenes.minigame_13.minigame_13"}


	--GLOBALS
	global_current_game_index = 0
	global_difficulty = 1
	global_game_finished = 0
	global_score_counter = {p1 = 0, p2 = 0}
	global_game_mode = "normal"

	-- GAMESTATE INITIALISATION
	-- NEEDED FOR HUMP GAMESTATE TO WORK
	gamestate.registerEvents()

	-- INIT TO AVOID LOADINGS
	titlescreen:init()

	-- CHANGES TO TEST DIRECTLY LV1
	--require( "scenes.minigame_10.minigame_10")
	--gamestate.switch(require("scenes.minigame_13.minigame_13"))
	gamestate.switch(titlescreen)
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
   if key == "r" then
      love.event.quit("restart")
   end

   if key == "p" then
	   global_debug = not global_debug
   end

   if key == "n" then
	   gamestate.switch(scoreboard)
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

function shuffle(tbl)
  math.randomseed(os.time() * 2)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

--FOR MEMORY  PUROPOSE
function deep_release(table, level, parent)
	local level  = level or 1
	local parent = parent or global_reference_table[global_current_game_index]
  for id,entry in pairs(table) do
      if type(entry) == 'table' then --limit level of scrub to 100
          deep_release(entry, (level + 1), tostring(parent).."-"..tostring(id))
		  --print("entering scrub level "..tostring(level).." from "..tostring(parent))
      elseif entry and (type(entry) == 'userdata') then --if entry not nul and love -related / userdata
          if entry:type() ~= "Canvas" then --Canvas make love crash if released
						print(entry:type().." removed on level "..tostring(level).." with parent: "..tostring(parent))
						entry:release()
					end
			else
				--print(type(entry).." removed on level "..tostring(level).." with parent: "..tostring(parent))
				entry = nil
			end
  end

	--IF THE SCENE CONTAINS A WORLD FROM BUMP
end
