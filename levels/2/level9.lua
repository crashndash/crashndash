local level = Level.new ()

level.length = 60
level.tagline = "How many jumps can you save?"
level.jumpCount = 20

level.availableObstacles = {"wheel", "rock"}
level.obstacleFreq = 5
level.enemyLimit = 5
level.maxOffset = 60
level.minOffset = 50

local addRockRow = function ( pos, xpos )
  local cpos = -160
  while cpos < 160 do
    if (cpos >= xpos - 30) and (cpos <= xpos + 30) then
      -- Too close
    else
      level:addPredefObstacle ( pos, "rock", 60, 60, cpos )
      level:alterRoad(pos, 150)
    end
    cpos = cpos + 70
  end
end

addRockRow(4, 10)
addRockRow(8, -10)
addRockRow(12, 80)
addRockRow(21, 70)
addRockRow(24, 50)
addRockRow(33, -70)
addRockRow(38, -80)
addRockRow(42, 100)
addRockRow(46, 180)
addRockRow(54, 0)

level.topScore = 9800

return level
