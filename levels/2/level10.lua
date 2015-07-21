local level = Level.new ()
level.minOffset = 10
level.maxOffset = 20

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

addRockRow(11, 40)
addRockRow(12, 10)

addRockRow(31, 70)
addRockRow(32, -90)

level.length = 40

level.tagline = "The bosses in the desert"

level.hasBoss = true

level.boss = "tanker"
level.bossCount = 3

level.topScore = 12620

return level
