local level = Level.new ()

level.length = 60
level.tagline = "Keep steady"

level.availableObstacles = {"wheel", "rock"}
level.obstacleFreq = 5
level.enemyLimit = 0
level.maxOffset = 60
level.minOffset = 10
level.jumpCount = 20

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

addRockRow(2, 0)
addRockRow(3, 10)
addRockRow(4, 20)
addRockRow(5, 30)
addRockRow(6, 30)
addRockRow(7, 30)
addRockRow(8, -30)
addRockRow(9, 130)
addRockRow(10, 130)
addRockRow(11, -30)
addRockRow(12, -30)

addRockRow(14, 30)
addRockRow(15, 80)
addRockRow(16, 110)
addRockRow(17, -30)
addRockRow(18, 30)

addRockRow(20, -30)
addRockRow(21, 30)
addRockRow(22, -30)
addRockRow(23, 30)
addRockRow(24, -30)
addRockRow(25, 30)
addRockRow(26, 30)
addRockRow(27, -30)
addRockRow(28, -130)

addRockRow(32, -30)
addRockRow(33, 30)
addRockRow(34, -30)
addRockRow(35, 30)
addRockRow(36, 30)

addRockRow(40, 10)
addRockRow(41, 10)
addRockRow(42, 100)
addRockRow(43, 60)
addRockRow(44, -60)

addRockRow(45, 60)
addRockRow(46, 10)
addRockRow(47, 30)
addRockRow(48, -30)


addRockRow(51, -30)
addRockRow(52, -60)

addRockRow(56, -130)
addRockRow(57, 0)
addRockRow(58, 0)
addRockRow(59, -30)

level.topScore = 3000

return level
