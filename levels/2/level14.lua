local level = Level.new ()

level.length = 50
level.tagline = "Crazy amounts of zombies..."

level.availableObstacles = {"zombie", "wheel"}
level.obstacleFreq = 5
level.enemyLimit = 1
local addZombieRow = function ( index, x )
  local ypos = -100
  local xpos = -util.halfX + 60
  local xint = 2
  if x then
    xpos = x
    xint = -xint
  end
  while ypos < 100 do
    level:addPredefObstacle ( index, "zombie", nil, nil, xpos - xint, ypos)
    ypos = ypos + 40
    xint = xint + xint
  end
end


local a = 1
while a < 50 do
  local number = math.random(1,6)
  if number == 3 then
    addZombieRow(a, util.halfX - 60)
  else
    addZombieRow(a)
  end
  a = a +1
end

level.maxOffset = 60
level.minOffset = 50

level.availablePowerUps = { "invincible" }
level.powerFreq = 5

level.topScore = 43310

return level
