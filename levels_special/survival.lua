local level = Level.new ()
level.length = 200000
level.enemyLimit = 2
level.spawnFrequency = 10
level.useLevelNumberAsTitle = true
level.minOffset = 10
level.maxOffset = 30
level.obstacleFreq = 40
level.hardened = {}
level.survivalLevel = 1

level.updateLevel = function ()
  -- Update some variables every 20 roadCount
  if level.roadCount % 10 == 0 then
    if level.hardened[level.roadCount / 10] then return end
    level.hardened[level.roadCount / 10] = true
    level.survivalLevel =  level.roadCount / 10 + 1
    if level.maxOffset < 120 then
      level.maxOffset = level.maxOffset + 4
      level.minOffset = level.minOffset + 3
    end
    if level.obstacleFreq > 5 then
      level.obstacleFreq = level.obstacleFreq - 1
    end
    if level.survivalLevel % 4 == 0 then
      level.enemyLimit = level.enemyLimit + 1
      -- Being even more evil every 40 roadcount...
      local evilness = math.min ( level.survivalLevel / 4, 4 )
      local placed = 0
      while evilness > placed do
        -- Place a hole in x places the next 60 roadcounts.
        local randomnum = math.random(1, 40)
        level:addPredefObstacle ( level.roadCount + randomnum, "bricks", 150, 150 )
        placed = placed + 1
      end
      if level.survivalLevel % 8 == 0 then
        -- And every 120 roadCount we are even more evil than that...
        local placeTurns = evilness / 2
        local turnsPlaced = 0
        while placeTurns > turnsPlaced do
          local rand = math.random(1, 80)
          -- Add a steep turn somewhere * x along the next 60 roadcounts
          -- Determine if we want a right or left turn.
          local x1 = 0
          local x2 = 190
          if rand > 40 then
            x1 = 190
            x2 = 0
          end
          level:alterOffset ( level.roadCount + rand, x1, x2 )
          turnsPlaced = turnsPlaced + 1
        end
        -- Add more speed.
        level.speedFactor = level.speedFactor * 1.2
      end
    end
    local levelBonus = 100 * level.survivalLevel
    table.insert( game.level.popups, Popup.new ( "level " .. level.survivalLevel .. ".\n You gained " .. levelBonus .. " bonus points." ) )
    game.score = game.score + levelBonus

  end
end

level.powerFreq = 5
level.useProgress = false

level.availablePowerUps = {"nitro", "bomb", "jumps_pu"}

level.tagline = "How long can you keep going...?"

return level
