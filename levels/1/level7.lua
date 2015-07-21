local level = Level.new ()
level.jumpHeight = 3
level.jumpDuration = 2.25
level.carWeight = 5
level.length = 60
level.powerFreq = 6

local stops = {5, 26, 35, 50}
for i, a in ipairs ( stops ) do
  level:alterOffset ( a, 160, 10 )
  level:alterOffset ( a + 4, 10, 160 )
end

level.tagline = "A little weightless... \nand bomb powerups!"

level.topScore = 13000

return level
