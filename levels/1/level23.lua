local level = Level.new ()

level.tagline = "Stay on the right road!"

level.length = 100
level.jumps = 0

level.availablePowerUps = {"bomb", "nitro"}

level.powerFreq = 15
level.obstacleFreq = 10
level.minOffset = 20
level.maxOffset = 20

level:addPredefObstacle ( 2, "grass", 150, 1200, 0 )
local x = 10
while x < 20 do
  level:alterOffset ( x, 235, 20 )
  x = x +1
end

level:addPredefObstacle ( 22, "grass", 150, 1600, 0 )
x = 30
while x < 40 do
  level:alterOffset ( x, 235, 20 )
  x = x +1
end

level:addPredefObstacle ( 52, "grass", 150, 1200, 0 )
x = 60
while x < 70 do
  level:alterOffset ( x, 20, 235 )
  x = x +1
end

level:addPredefObstacle ( 72, "grass", 150, 1200, 0 )
x = 80
while x < 85 do
  level:alterOffset ( x, 235, 20 )
  x = x +1
end
while x < 90 do
  level:alterOffset ( x, 100, 100 )
  x = x +1
end

level.topScore = 10000

return level
