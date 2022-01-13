minigame_2 = {}
local moonshine = require 'libs.moonshine'
local tween  = require "libs.tween"


function minigame_2:init()
	-- TAGS
self.scene_type = "game"
self.scene_name = "Trivia"

--Phases either intro active or outro
self.phase = "intro"

--TIMERS 
self.intro_timer = 0
self.intro_timer_max = 2

self.active_timer = 0
self.active_timer_max = 15

self.outro_timer = 0
self.outro_timer_max = 5
--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
	
--Select a question
	self.question_holder = require("scenes.minigame_2.questions.megafile")
	self.question = {}
	math.randomseed(os.time())
	self.question.index = math.random(1, 994) -- select a random question amongst all of them 
	self.question.current = self.question_holder[self.question.index] -- this is used for current game
	
	--Randomise the 2 wrong answers
	self.wrong_answer_1_index = math.random(1,3)
	self.wrong_answer_2_index = math.random(1,3)
	while self.wrong_answer_2_index == self.wrong_answer_1_index do --retry if it's the same index
		self.wrong_answer_2_index = math.random(1,3)
	end
	self.wrong_answer_1 = self.question.current.incorrect_answers[self.wrong_answer_1_index]
	self.wrong_answer_2 = self.question.current.incorrect_answers[self.wrong_answer_2_index]
	self.right_answer = self.question.current.correct_answer
	
	self.answers = shuffle({self.wrong_answer_1, self.wrong_answer_2, self.right_answer})
	
	-- randomise positions for display so correct answer isnt always last
	
	
	--PADDING FOR RECTANGLES
	self.padding = 10 -- In pixels
	self.rounding_edge = 50 
	
	--FONTS and question box 
	self.font_question_default = love.graphics.newFont("fonts/letters_for_learners/Letters for Learners.ttf", 110)
	
	self.question_box = {}
	self.question_box.x = 0 + 2 * self.padding
	self.question_box.y = 0 + 2 * self.padding
	self.question_box.w =  global_width - 4 * self.padding
	self.question_box.h = 3 * self.font_question_default:getHeight()--VARIABLE?
	
	--Space left to fill below question box
							-- 1080 - 20 available and        20 + 3rows of text 
	self.height_below_box = (global_height - self.padding) - (self.question_box.y + self.question_box.h) - 4*self.padding  -- Just height
	--720 pixels left -> minus 4 times padding (40 pixels) 680 pixels left 
	--226 pixels as target height for each answer
	print(self.height_below_box)
	
	
	--Buttons 
	self.red_button = {}
	self.red_button.img = love.graphics.newImage( "img/red_button.png")
	self.red_button.x = 0 + 2 * self.padding
	self.red_button.y = self.question_box.y + self.question_box.h + self.padding
	self.red_button.w = 500
	self.red_button.h = 500
	self.red_button.scaling = (self.height_below_box/3)/self.red_button.w
	self.red_button.final_w = 500 * self.red_button.scaling
	self.red_button.final_h = 500 * self.red_button.scaling
	
	self.green_button = {}
	self.green_button.img = love.graphics.newImage( "img/green_button.png")
	self.green_button.x = 0 + 2 * self.padding
	self.green_button.y = self.red_button.y + self.red_button.final_h + self.padding
	self.green_button.w = 500
	self.green_button.h = 500
	self.green_button.scaling = (self.height_below_box/3)/self.green_button.w
	self.green_button.final_w = 500 * self.green_button.scaling
	self.green_button.final_h = 500 * self.green_button.scaling
	
	self.blue_button = {}
	self.blue_button.img = love.graphics.newImage( "img/blue_button.png")
	self.blue_button.x = 0 + 2 * self.padding
	self.blue_button.y = self.green_button.y + self.green_button.final_h + self.padding
	self.blue_button.w = 500
	self.blue_button.h = 500
	self.blue_button.scaling = (self.height_below_box/3)/self.blue_button.w
	self.blue_button.final_w = 500 * self.blue_button.scaling
	self.blue_button.final_h = 500 * self.blue_button.scaling
	
	self.button_list = {self.red_button, self.green_button, self.blue_button}
	self.answer_box_width = 1000
	
	--Moonshine effect
	self.effect_timer = 0
	self.full_screen_effect = moonshine(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h,moonshine.effects.crt).chain(moonshine.effects.scanlines).chain(moonshine.effects.chromasep)
	--modulate effects
	self.full_screen_effect.crt.distortionFactor = {1.025 , 1.025 } --{1.06, 1.065}
	--self.full_screen_effect.crt.x = 0
	--self.full_screen_effect.crt.y = 0
	self.full_screen_effect.crt.scaleFactor =  {1,1} --{1,1}
	self.full_screen_effect.crt.feather = 0.05 --0.02
	
	self.full_screen_effect.scanlines.width = 10 --2
	--self.full_screen_effect.scanlines.frequency =  -- screen height
	self.full_screen_effect.scanlines.phase	 = 1 --0
	self.full_screen_effect.scanlines.thickness = 1 -- 1
	self.full_screen_effect.scanlines.opacity =  0.1-- 1
	self.full_screen_effect.scanlines.color = {0,0,0} --{0,0,0}
	
	self.full_screen_effect.chromasep.angle = 2.35619 --0
	self.full_screen_effect.chromasep.radius = 0 --0
	
	-- Intro
	self.blink_timer = 0
	self.blink_timer_max = 0.25
	
	-- PLAYER 1 Container
	self.p1_box = {}
	self.p1_box.x = self.red_button.x + self.red_button.final_w + self.padding + self.answer_box_width + self.padding
	self.p1_box.y = self.red_button.y
	self.p1_box.w = (global_width - self.p1_box.x - 4 * self.padding) / 2
	self.p1_box.h = 2 * self.red_button.final_h + self.padding
	self.p1_box.text = "Player 1 Answer:"
	
	self.p1_box.answer = nil
	self.p1_box.idle = {}
	-- is 900x600 and all imgs are 300x300
	self.p1_box.idle.spreadsheet = love.graphics.newImage( "scenes/minigame_2/img/idle_spreadsheet_900_600.png")
	self.p1_box.idle.quads = {love.graphics.newQuad( 0, 0, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 300, 0, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 600, 0, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 0, 300, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 300, 300, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 600, 300, 300, 300, 900, 600 ),}
	self.p1_box.idle.timer = 0
	self.p1_box.idle.active_quad = 1
	self.p1_box.answered_img = love.graphics.newImage( "scenes/minigame_2/img/tick.png")
	
	-- PLAYER 2 Container
	self.p2_box = {}
	self.p2_box.x = self.p1_box.x + self.p1_box.w + self.padding 
	self.p2_box.y = self.p1_box.y
	self.p2_box.w = self.p1_box.w
	self.p2_box.h = self.p1_box.h
	self.p2_box.text = "Player 2 Answer:"
	
	self.p2_box.answer = nil
	self.p2_box.idle = {}
	-- is 900x600 and all imgs are 300x300
	self.p2_box.idle.spreadsheet = love.graphics.newImage( "scenes/minigame_2/img/idle_spreadsheet_900_600.png")
	self.p2_box.idle.quads = {love.graphics.newQuad( 0, 0, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 300, 0, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 600, 0, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 0, 300, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 300, 300, 300, 300, 900, 600 ),
							  love.graphics.newQuad( 600, 300, 300, 300, 900, 600 ),}
	self.p2_box.idle.timer = 0
	self.p2_box.idle.active_quad = 1
	self.p2_box.answered_img = love.graphics.newImage( "scenes/minigame_2/img/tick.png")
	
	--Timer box 
	self.timer_box = {}
	self.timer_box.x = self.p1_box.x
	self.timer_box.y = self.p1_box.y + self.p1_box.h + self.padding
	self.timer_box.w = 2 * self.p1_box.w + self.padding
	self.timer_box.h = self.blue_button.final_h
	
	self.counted_score = {p1 = false, p2 = false}
	
	--outro 

end

function minigame_2:update(dt)
--ALL THE TIME 
self.effect_timer =  self.effect_timer + dt

-- Update effect frequency
self.full_screen_effect.scanlines.phase = self.effect_timer * 2.5
self.full_screen_effect.scanlines.opacity = math.max(0.1 * math.sin(self.effect_timer),  0.05)
if (self.effect_timer % 7) <= 0.25 then
	self.full_screen_effect.chromasep.angle = math.sin(self.effect_timer) * 2 --0
	self.full_screen_effect.chromasep.radius = 2--0
else
	self.full_screen_effect.chromasep.radius = 0
	self.full_screen_effect.chromasep.angle = 2.35619
end

--Blink at start
if self.blink_timer <= self.blink_timer_max then self.blink_timer = self.blink_timer + dt end 
self.full_screen_effect.crt.scaleFactor =  {1 / (math.exp(self.blink_timer)/math.exp(self.blink_timer_max)),1}

-- Intro
if self.intro_timer <= self.intro_timer_max then self.intro_timer = self.intro_timer + dt else self.phase = "active" end

--ACTIVE
if self.phase == "active" then
	--Move idle animation
	self.p1_box.idle.timer = self.p1_box.idle.timer + 2 * dt
	self.p1_box.idle.active_quad = math.floor((self.p1_box.idle.timer%6) + 1)
	
	
	if (self.active_timer <= self.active_timer_max) and ((self.p1_box.answer == nil) or (self.p2_box.answer == nil)) then
		self.active_timer = self.active_timer + dt 
	else
		self.phase = "reveal"
	end
end

--Reveal trigger

if (self.p1_box.answer ~= nil) and (self.p2_box.answer ~= nil) then self.phase = "reveal" end

--REVEAL 

if self.phase == "reveal" then 
	self.outro_timer = self.outro_timer + dt
	
end

end

function minigame_2:draw(dt)


	love.graphics.setCanvas(self.canvas)
		love.graphics.clear()
		--self.full_screen_effect(function() -- MOONSHINE EFFECT
		----- DRAW HERE ----
		--Main rectangle
		love.graphics.setColor(0.1, 0.9, 0.7)
		love.graphics.rectangle("fill", 0 + self.padding, 0 + self.padding, global_width - 2 * self.padding, global_height - 2 * self.padding, self.rounding_edge)
		--Question rectangle
		love.graphics.setColor(0.1, 0.8, 0.6)
		
		--get dimmension needed for question
		width, wrappedtext = self.font_question_default:getWrap( self.question.current.question, global_width - 4 * self.padding )
		height_of_text = #wrappedtext * self.font_question_default:getHeight()
		
		love.graphics.rectangle("fill",self.question_box.x, self.question_box.y, self.question_box.w, self.question_box.h, self.rounding_edge)
		
		--Print question
		love.graphics.setColor(0,0,0)
		love.graphics.setFont(self.font_question_default)
		love.graphics.printf(self.question.current.question, self.question_box.x, self.question_box.y + (self.question_box.h - height_of_text)/2, self.question_box.w, "center")
		love.graphics.setColor(1,1,1)
		love.graphics.printf(self.question.current.question, self.question_box.x - 2, self.question_box.y + (self.question_box.h - height_of_text)/2 - 2, self.question_box.w, "center")
		
		-- DRAW PLAYER BOX AND TIMERS 
		love.graphics.setColor(1,1,1)
		love.graphics.rectangle("fill", self.p1_box.x, self.p1_box.y, self.p1_box.w, self.p1_box.h, self.rounding_edge/2)
		love.graphics.rectangle("fill", self.p2_box.x, self.p2_box.y, self.p2_box.w, self.p2_box.h, self.rounding_edge/2)
		love.graphics.rectangle("fill", self.timer_box.x, self.timer_box.y, self.timer_box.w, self.timer_box.h, self.rounding_edge/2)
		love.graphics.setColor(0,0,0)
		love.graphics.printf(self.p1_box.text, self.p1_box.x, self.p1_box.y, self.p1_box.w, "center" )
		love.graphics.printf(self.p2_box.text, self.p2_box.x, self.p2_box.y, self.p2_box.w, "center" )
		-- DRAE IDLE ANIMATION
		

		
		--ACTIVE PHASE
		if self.phase == "active" or self.phase == "reveal" then
				-- Print Ticking timer 
				local time_left = math.max(math.ceil((self.active_timer_max - self.active_timer)),0) -- so it doesnt show -0 (minus zero)
				love.graphics.printf(tostring(time_left).."/"..tostring(self.active_timer_max), self.timer_box.x, self.timer_box.y + (self.timer_box.h/2) - self.font_question_default:getHeight()/2, self.timer_box.w, "center" )
				--print(self.active_timer)
				--print(self.phase)
				-- Print buttons
				love.graphics.setColor(1,1,1)
				love.graphics.draw(self.red_button.img, self.red_button.x, self.red_button.y, 0, self.red_button.scaling, self.red_button.scaling)
				love.graphics.draw(self.green_button.img, self.green_button.x, self.green_button.y, 0, self.green_button.scaling, self.green_button.scaling)
				love.graphics.draw(self.blue_button.img, self.blue_button.x, self.blue_button.y, 0, self.blue_button.scaling, self.blue_button.scaling)
				
				-- Draw answer boxes
				--TIED TO BUTTONS
				love.graphics.setColor(0.1, 0.8, 0.6)
				for _, v in pairs(self.button_list) do
					love.graphics.rectangle("fill", v.x + v.final_w + self.padding, v.y, self.answer_box_width, v.final_h, self.rounding_edge)
				end
				-- Print answers text  -- Tied to answer boxes and buttons
				
				for k, v in pairs(self.button_list) do
					width, wrappedtext = self.font_question_default:getWrap( self.answers[k], self.answer_box_width)
					height_of_text = #wrappedtext * self.font_question_default:getHeight()
					-- if reveal, do not print wring answers
					if (self.phase == "reveal") then
						if (self.answers[k] == self.right_answer) then
						love.graphics.setColor(0,0,0)
						love.graphics.printf(self.answers[k], v.x + v.final_w + self.padding + 2, v.y + (v.final_h - height_of_text)/2 + 2, self.answer_box_width + 2,"center")
						love.graphics.setColor(1, 1, 1)
						love.graphics.printf(self.answers[k], v.x + v.final_w + self.padding, v.y + (v.final_h - height_of_text)/2, self.answer_box_width,"center")
						end
					else
						love.graphics.setColor(0,0,0)
						love.graphics.printf(self.answers[k], v.x + v.final_w + self.padding + 2, v.y + (v.final_h - height_of_text)/2 + 2, self.answer_box_width + 2,"center")
						love.graphics.setColor(1, 1, 1)
						love.graphics.printf(self.answers[k], v.x + v.final_w + self.padding, v.y + (v.final_h - height_of_text)/2, self.answer_box_width,"center")
					end
				end
				
				--DRAW IDLE ANIMATION AND ANSWERED
				love.graphics.setColor(1,1,1)
				if self.p1_box.answer == nil then 
					love.graphics.draw(self.p1_box.idle.spreadsheet, self.p1_box.idle.quads[self.p1_box.idle.active_quad], self.p1_box.x, self.p1_box.y + height_of_text + 50)
				else
					if (self.phase == "reveal") and (self.answers[self.p1_box.answer] == self.right_answer) then
						love.graphics.setColor(1,1,1)
						if self.counted_score.p1 == false then 
							global_score_counter.p1 = global_score_counter.p1 + 1 -- SCORE POINT
							self.counted_score.p1 = true
						end
					else
						love.graphics.setColor(0,0,0)
					end
					love.graphics.draw(self.p1_box.answered_img,self.p1_box.x, self.p1_box.y + height_of_text + 50)
				end
				
				if self.p2_box.answer == nil then
					love.graphics.draw(self.p2_box.idle.spreadsheet, self.p2_box.idle.quads[self.p1_box.idle.active_quad], self.p2_box.x, self.p2_box.y + height_of_text + 50)
				else
					if (self.phase == "reveal") and (self.answers[self.p2_box.answer] == self.right_answer) then
						love.graphics.setColor(1,1,1)
						if self.counted_score.p2 == false then 
							global_score_counter.p2 = global_score_counter.p2 + 1 --SCORE + 1
							self.counted_score.p2 = true
						end
					else
						love.graphics.setColor(0,0,0)
					end
					love.graphics.draw(self.p2_box.answered_img,self.p2_box.x, self.p2_box.y + height_of_text + 50)
				end
				
				--outro and fade to black
				if self.outro_timer_max - self.outro_timer <=1 then
					time_left = 1 - (self.outro_timer_max - self.outro_timer)
					love.graphics.setColor(0,0,0, time_left)
					love.graphics.rectangle("fill", 0, 0 , global_width, global_height)
					love.graphics.setColor(1,1,1)
				end
				if self.outro_timer >= self.outro_timer_max then 
					gamestate.switch(scoreboard)
				end
		end
		
		----- FINISH DRAWING ----
		--end)--#nofilter
	love.graphics.setCanvas()
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(self.canvas, self.aspect_ratio.x, self.aspect_ratio.y, 0, self.aspect_ratio.scale, self.aspect_ratio.scale)
	draw_debug()

end

-------
---CONTROLS
------
function minigame_2:keyreleased(key)
	if self.phase == "active" then
		if self.p1_box.answer == nil then --if not answered yet
			if key == "s" then 
				self.p1_box.answer = 1
			elseif key == "d" then 
				self.p1_box.answer = 2
			elseif key == "f" then 
				self.p1_box.answer = 3
			end
			
			self.p1_box.answer_time = self.active_timer_max - self.active_timer
		end
		
		if self.p2_box.answer == nil then --if not answered yet
			if key == "j" then 
				self.p2_box.answer = 1
			elseif key == "k" then 
				self.p2_box.answer = 2
			elseif key == "l" then 
				self.p2_box.answer = 3
			end
			
			self.p2_box.answer_time = self.active_timer_max - self.active_timer
		end
	end
end


function minigame_2:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)

end

function minigame_2:enter(previous)

end

function shuffle(tbl)
  for i = #tbl, 2, -1 do
    local j = math.random(i)
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

-- NEEDS TO BE AT THE VERY END
return minigame_2
