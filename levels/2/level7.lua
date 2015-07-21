local level = Level.new ()

level.length = 40
level.tagline = "Bouncing cactuses"

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

addCactusRow(10, 100)
addCactusRow(35, -100)

level.availableObstacles = {"cactus"}
level.obstacleFreq = 8
level.enemyLimit = 20
level.maxOffset = 40
level.minOffset = 10
table.insert(level.enemyVariations, "sandy")

level.spawnFrequency = 30

level.topScore = 13800

return level
