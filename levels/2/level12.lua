local level = Level.new ()

level.tagline = "No jumps?"

level.length = 100

level.availablePowerUps = {"jumps_pu"}

level.powerFreq = 21
level.enemyLimit = 0
level.maxOffset = 100
level.minOffset = 80

level:addPowerUp(19, "nitro")
level:addPowerUp(30, "nitro")
level:addPowerUp(50, "nitro")
level:addPowerUp(69, "nitro")
level:addPowerUp(89, "nitro")

local addCactusRow = function ( pos, xpos )
  local cpos = -160
  while cpos < 160 do
    if (cpos >= xpos - 30) and (cpos <= xpos + 30) then
      -- Too close
    else
      level:addPredefObstacle ( pos, "cactus", 60, 60, cpos )
      level:alterRoad(pos, 150)
    end
    cpos = cpos + 70
  end
end

addCactusRow(23, 90)
addCactusRow(40, 100)
addCactusRow(41, -100)

addCactusRow(71, 60)
addCactusRow(75, -60)
addCactusRow(79, 0)


local x = 10
while x < 14 do
  if x % 2 == 0 then
    level:alterOffset ( x, 0, 190 )
  else
    level:alterOffset ( x, 190, 0 )
  end
  x = x + 1
end

x = 38
while x < 40 do
  if x % 2 == 0 then
    level:alterOffset ( x, 0, 150 )
  else
    level:alterOffset ( x, 150, 0 )
  end
  x = x + 1
end
x = 45
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

x = 60
while x < 70 do
  level:alterOffset ( x, 100, 100 )
  x = x + 1
end
x = 70
while x < 80 do
  level:alterOffset ( x, 0, 190 )
  x = x + 1
end

x = 80
while x < 90 do
  level:alterOffset ( x, 10, 220 )
  x = x + 1
end

level.topScore = 2000
level.jumpCount = 0

return level
