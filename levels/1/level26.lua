local level = Level.new ()

level.tagline = "Zig zag"

level.length = 100

level.availablePowerUps = {"bomb", "nitro", "jumps_pu"}

level.powerFreq = 5
level.obstacleFreq = 10

local x = 1
while x < 10 do
  if x % 2 == 0 then
    level:alterOffset ( x, 0, 150 )
  else
    level:alterOffset ( x, 150, 0 )
  end
  x = x + 1
end

x = 25
while x < 28 do
  if x % 2 == 0 then
    level:alterOffset ( x, 0, 190 )
  else
    level:alterOffset ( x, 190, 0 )
  end
  x = x + 1
end

x = 38
while x < 58 do
  if x % 4 == 0 then
    level:alterOffset ( x, 0, 190 )
  else
    if x % 2 == 0 then
      level:alterOffset ( x, 190, 0 )
    else
      level:alterOffset ( x, 100, 100 )
    end
  end
  x = x + 1
end

x = 70
while x < 80 do
  level:alterOffset ( x, 100, 100 )
  x = x + 1
end

x = 80
while x < 90 do
  level:alterOffset ( x, 10, 220 )
  x = x + 1
end

level.topScore = 17000

return level
