local level = Level.new ()
level.length = 100
level.enemyLimit = 2
level.spawnFrequency = 10

local room = multiplayer.room or ""

level.progressCar = nil
level.multiplayer = true
level.useLevelNumberAsTitle = true
level.useProgress = true
level.useProgressCar = false

local userandom = tonumber(room)
if not userandom then
  -- Just so we don't send a string (or nil) as randomseed
  userandom = 0
end

local totalBlocks = multiplayer.totalBlocks
if totalBlocks then
  for i, bl in ipairs(totalBlocks) do
    -- Avoid double blocks. And too early blocks.
    if bl > 2 and not level.blocks[bl + 1] and not level.blocks[bl - 1] then
      if bl % 2 == 0 then
        level:addBlock(bl)
      else
        level:addBlock(bl, 200, "gfx/bricks.png" )
      end
    end
  end
end

local totalUps = multiplayer.totalUps
level.availablePowerUps = {"nitro", "swarm", "bomb", "rocket"}
if totalUps then
  for i, up in ipairs(totalUps) do
    if not level.blocks[up[1]] then
      local pu = level.availablePowerUps[up[2]]
      level:addPowerUp(up[1], pu )
    end
  end
end

level.tagline = "Playing in room " .. room

return level
