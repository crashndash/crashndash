local level = Level.new ()

level.length = 60
level.tagline = "Rocky roads"

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

level:addPredefObstacle ( 3, "rock", 60, 60, -120 )
level:addPredefObstacle ( 3, "rock", 60, 60, 50 )
level:addPredefObstacle ( 3, "rock", 60, 60, 110 )

addRockRow(11, 40)
addRockRow(12, 10)

addRockRow(14, -50)
addRockRow(15, -80)

addRockRow(21, 70)
addRockRow(22, -90)
addRockRow(23, 70)

addRockRow(40, -40)
addRockRow(41, 40)

addRockRow(51, 40)
addRockRow(52, 40)

level:addSwarm(30, 8, "miniufo")
level:addSwarm(33, 8, "miniufo")

level:addBlock(2, 200, "gfx/rock.png")
level:addBlock(4, 200, "gfx/rock.png")

level.topScore = 7440

return level
