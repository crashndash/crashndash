local level = Level.new()
local l = EmptyLevel.getLevel()
local ofs = EmptyLevel.getOffsets()
if ofs then
  for i, o in next, ofs, nil do
    -- Try to assemble an offset alter for this delta.
    local os = {}
    if o['0'] then
      table.insert(os, o['0'])
    else
      table.insert(os, level.minOffset)
    end
    if o['1'] then
      table.insert(os, o['1'])
    else
      table.insert(os, level.minOffset)
    end
    level:alterOffset(tonumber(i), unpack(os))
  end
end
-- Add blocks.
local bs = EmptyLevel.getBlocks()
local animated = {
  fire = true,
  water = true
}
if bs then
  for i, b in next, bs, nil do
    -- Make sure we have a number.
    if tonumber(i) then
      if animated[b] then
        -- Look away plz.
        if b == "fire" then
          b = "firesprite"
        end
        level:addBlock(tonumber(i), 200, "gfx/" .. b .. ".png", true, 2)
      else
        level:addBlock(tonumber(i), 200, "gfx/" .. b .. ".png")
      end
    end
  end
end

-- Add powerups.
local ps = EmptyLevel.getPowerups()
if bs then
  for i, p in next, ps, nil do
    level:addPowerUp(tonumber(i), p)
  end
end

-- Add swarms.
local sw = EmptyLevel.getSwarms()
if sw then
  for i, s in next, sw, nil do
    if not level.blocks[tonumber(i) + 1] then
      local random  = math.random(#level.enemyVariations)
      local type = level.enemyVariations[random]
      level:addSwarm(tonumber(i), 5, type)
    end
  end
end

-- Add obstacles.
local ob = EmptyLevel.getObstacles()
if ob then
  for i, o in next, ob, nil do
    level:addPredefObstacle(tonumber(i), o)
  end
end


level.tagline = l.tagline
level.length = l.length
level.minOffset = l.minOffset
level.maxOffset = l.maxOffset
level.name = l.name
return level
