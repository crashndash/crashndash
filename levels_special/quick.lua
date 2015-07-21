local level = Level.new()

level.length = 200000

level.useLevelNumberAsTitle = true
level.useProgress = false
if not globalData.skipQuickInfo then
  level:addInfo(1, "Tap to jump\n\n\n\n\n\n\n\n\n\nArrows to steer", {gfx = "gfx/handnarrows.png", width = 112, height = 256})
  level.skipButton = false
  level.infoDismiss = "OK!"
end
level.tagline = "Quick game"
level.jumpCount = 30

-- Set up some random blocks here and there.

level.powerFreq = 5
local allPowers = {"bomb", "jumps_pu", "nitro", "invincible"}
level.availablePowerUps = {"bomb"}
level:addBlock(3, 150, "gfx/water.png", true, 2)
local blocksPer10 = 1

local blocks = {
  {150, "gfx/water.png", true, 2},
  {100, "gfx/grass.png"},
  {200, "gfx/bricks.png"},
  {150, "gfx/grass.png"},
  {100, "gfx/water.png", true, 2}
}
local updated = {}

level.updateLevel = function ()
  if level.roadCount % 10 == 0 and not updated[level.roadCount] then
    updated[level.roadCount] = true
    -- See if we want to toss in more available powerups.
    local added = 0
    while added < blocksPer10 do
      -- Find a random place to place it.
      local place = math.random(level.roadCount + 1, level.roadCount +  10)
      if not level.blocks[place] and not level.blocks[place - 1] and not level.blocks[place + 1] then
        -- Find a random block to use.
        local b = blocks[math.random(1, #blocks)]
        level:addBlock(place, unpack(b))
        added = added + 1
      end
    end
    if level.roadCount % 30 == 0 then
      if #level.availablePowerUps < #allPowers then
        table.insert(level.availablePowerUps, allPowers[(level.roadCount / 10) + 1])
      end
      -- Randomly add swarms.
      if math.random(1, 2) == 2 then
        if not level.blocks[level.roadCount + 1] then
          local random  = math.random(#game.level.enemyVariations)
          local type = game.level.enemyVariations[random]
          level:addSwarm(level.roadCount + 1, 5, type)
        end
      end
    end
    if level.roadCount % 100 == 0 and blocksPer10 < 4 then
      blocksPer10 = blocksPer10 + 1
    end
  end
end
globalData.skipQuickInfo = true
return level
