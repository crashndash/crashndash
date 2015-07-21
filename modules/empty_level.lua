module ( "EmptyLevel", package.seeall )

emptylevel = {}
offsets = {}
powerups = {}
blocks = {}
obstacles = {}
swarms = {}


local initLevel = function (force)
  if not emptylevel.length or force then
    emptylevel = Level.new()
    emptylevel.minOffset = 30
    emptylevel.maxOffset = 30
  end
end

setOffsets = function ( o )
  offsets = o
end

getOffsets = function (  )
  return offsets
end

setPowerups = function ( p )
  powerups = p
end

getPowerups = function (  )
  return powerups
end

setBlocks = function ( b )
  blocks = b
end

getBlocks = function (  )
  return blocks
end

setObstacles = function(o)
  obstacles = o
end

getObstacles = function()
  return obstacles
end

setSwarms = function(s)
  swarms = s
end

getSwarms = function (  )
  return swarms
end

setLevel = function ( newLevel )
  initLevel(true)
  if not newLevel then
    return
  end
  -- Set a couple of values from the new level.
  emptylevel.length = newLevel.length and newLevel.length or 50
  emptylevel.tagline = newLevel.tagline and newLevel.tagline or ""
  emptylevel.name = newLevel.name or ""
end

getLevel = function (  )
  initLevel()
  return emptylevel
end
