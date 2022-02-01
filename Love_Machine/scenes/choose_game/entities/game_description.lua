GameDescription = Class{}

function GameDescription:init() -- delay in seconds

	self.games = {}

	self.games[1] = {name = "Build A Tower", description = "Mash the green button to build the highest tower possible.", left = nil, up = "Build", right = nil}

	self.games[2] = {name = "Trivia", description = "Give the right answer.", left = "Answer 1", up = "Answer 2", right = "Answer 2"}

	self.games[3] = {name = "Basketball", description = "Shoot some hoops.", left = "Up", up = "Shoot (Hold and Release)", right = "Down"}

	self.games[4] = {name = "Don't Grab The Last Bite", description = "Grab as much food as you want without taking the last one.",
	 				 left = "Grab 1 bite", up = "Grab 2 bite", right = "Grab 3 bite"}

	self.games[5] = {name = "Rock Paper Scissors", description = "Rock Crushed Scissors, Paper Covers Rock, Scissors Cut Paper.",
					 left = "Rock", up = "Paper", right = "Scissors"}

	self.games[6] = {name = "Run & Jump", description = "Jump and avoid obstacles.", left = nil, up = "Jump", right = nil}

	self.games[7] = {name = "Cowboy Duel", description = "Shoot after the given bell.", left = nil, up = "Shoot", right = nil}

	self.games[8] = {name = "Dance Off", description = "Repeat the dance moves with the rhythm.", left = "To the Left!", up = "Up! Up!", right = "To the Right!"}

	self.games[9] = {name = "Thread The Needle In The Wind", description = "It's windy outside and you are trying to thread a needle with shaky hands.",
	 				left = "Go Left", up = "Steady Hand", right = "Go Right"}

	self.games[10] = {name = "Infinite Jump", description = "Jump to the top and don't reach the bottom.", left = "Left", up = "Jump", right = "Right"}

	self.games[11] = {name = "Racecar Driver", description = "Be the first to finish 3 laps.", left = "Turn Left", up = "Accelerate", right = "Turn Right"}

	self.games[12] = {name = "Not Pong", description = "Win at not Pong", left = "Left", up = nil, right = "Right"}

	self.games[13] = {name = "Et Tron", description = "Don't crash into anything and trap your opponent with your trail.", left = " Turn Left", up = nil, right = " Turn Right"}

end


function GameDescription:update(dt)

end

function GameDescription:draw()

end

return GameDescription
