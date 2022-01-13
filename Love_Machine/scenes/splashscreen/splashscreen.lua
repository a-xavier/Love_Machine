local o_ten_one = require("libs.o-ten-one")
splashscreen = {}


function splashscreen:init()
	self.splash = o_ten_one.new({fill='lighten', delay_after=1})
	self.splash.onDone = function() gamestate.switch(titlescreen) end
	self.bgm = love.audio.newSource( "scenes/splashscreen/sound/loop_intro_lofi.ogg", 'static' )
	self.bgm:setLooping(true)
	
	--Handle resolution
	w, h = love.graphics.getDimensions()
	self.aspect_ratio = require('libs/AspectRatio')
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
	
	

end

function splashscreen:update(dt)
	self.bgm:play()
	self.splash:update(dt)

end

function splashscreen:draw(dt)
	self.splash:draw(dt)
end


function splashscreen:resize(w, h)
	self.aspect_ratio:init(w, h, global_width, global_height)
	self.canvas =  love.graphics.newCanvas(self.aspect_ratio.dig_w, self.aspect_ratio.dig_h)
end

function splashscreen:enter(previous)

end


-- NEEDS TO BE AT THE VERY END
return splashscreen
