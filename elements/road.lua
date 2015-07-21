module ( "Road", package.seeall )

local MODULE_LENGTH = 200

local RIGHT = "right"
local LEFT = "left"
local EXPANDING = "expanding"
local SHRINKING = "shrinking"

local getRoadBorderName = function ( side, expand)
  local theme = game.level.theme or "grass"
  local name = "gfx/level_themes/" .. theme .. "/roadborder_" .. side .. "_" .. expand .. ".png"
  return name
end

function new ( world, oldRoad, offset, block, length )
  local road = {}
  road.startOffsetLeft = oldRoad and oldRoad.endOffsetLeft or 20
  road.startOffsetRight = oldRoad and oldRoad.endOffsetRight or 20
  road.endOffsetLeft = offset[1] or 20
  road.endOffsetRight = offset[2] or 20
  road.length = length or MODULE_LENGTH
  road.length = oldRoad and road.length or SCREEN_UNITS_Y + road.length

  road.edgePart = world:addBody ( MOAIBox2DBody.KINEMATIC )
  if not road.edgePart then return nil end
  road.blockPart = world:addBody ( MOAIBox2DBody.KINEMATIC )
  road.edgePart.type = "grass"
  road.blockPart.type = "grassblock"
  local halfX = SCREEN_UNITS_X/2
  local halfY = oldRoad and SCREEN_UNITS_Y/2 or -SCREEN_UNITS_Y/2

  if not oldRoad then
    road.first = true
  end

  local edges
  road.props = {}

  local theme = game.level.theme or "grass"

  local roadPropLength = road.length
  local yOffset = 240
  if not oldRoad then
    yOffset = -240
    -- Set the roadPropLength to something that is divisible by 50, so the
    -- grid helper is happy.
    roadPropLength = 1150
  end

  local roadProp = util.getGrid ( SCREEN_UNITS_X, roadPropLength, "gfx/level_themes/" .. theme .. "/road.png", -SCREEN_UNITS_X / 2, yOffset )
  roadProp:setParent ( road.edgePart )
  roadProp:setPriority(-100)
  table.insert ( road.props, roadProp )

  if block then
    -- Make sure all enemies are inside the play frame.
    for i, enemy in next, game.level.enemies, nil do
      if enemy.body and not enemy.bodyRemoved then
        local x, y = enemy.body:getPosition()
        local carheight = enemy.body.userData.properties.size[4]
        if carheight and y and y > SCREEN_UNITS_Y / 2 - carheight then
          local diff = (SCREEN_UNITS_Y / 2 - carheight) - y
          local setY = y + diff
          enemy.body:setTransform(x, setY)
        end
      end
    end
    local edges = {}
    for i = halfY + 20, halfY + road.length - 20, 20 do
      table.insert ( edges, -halfX )
      table.insert ( edges, i )
      table.insert ( edges, halfX )
      table.insert ( edges, i )
    end
    local roadSides = {
      -halfX + road.startOffsetLeft, halfY,
      halfX - road.startOffsetRight, halfY,
      -halfX + road.endOffsetLeft, halfY + road.length,
      halfX - road.endOffsetRight, halfY + road.length
    }
    road.roadEdges = road.edgePart:addEdges ( roadSides )
    for i, fixture in ipairs ( road.roadEdges ) do
      fixture:setFilter ( 0x02 )
      fixture:setRestitution ( 0 )
    end

    road.blockEdges = road.blockPart:addEdges ( edges )
    for i, fixture in ipairs ( road.blockEdges ) do
      fixture:setFilter ( 0x02 )
      fixture:setRestitution ( 0 )
    end

    for i = 1, #roadSides, 4 do
      local x1, y1, x2, y2 = roadSides[i], roadSides[i+1], roadSides[i+2], roadSides[i+3]
      local width = math.abs ( x1 - x2 ) > 0 and math.abs ( x1 - x2 ) or 4
      local height = math.abs ( y1 - y2 ) > 0 and math.abs ( y1 - y2 ) or 4
    end

    -- For some reason this offset is always the same, no matter what the
    -- speed or block length we have.
    local offsetY = 240
    tilewidth = 1
    if block.animated then
      tilewidth = 2
    end
    local prop = util.getGrid ( SCREEN_UNITS_X, road.length, block.img, - (SCREEN_UNITS_X / 2), offsetY, nil, tilewidth )
    if block.animated then
      local t = MOAIThread.new()
      t:run(function (  )
        while block do
          prop:animate()
          util.sleep(.2)
        end
      end)
    end
    prop:setParent ( road.edgePart )
    prop:setPriority ( 4 )

    table.insert ( road.props, prop )
  else
    local edges = {
      -halfX + road.startOffsetLeft, halfY,
      -halfX + road.endOffsetLeft, halfY + road.length,
      halfX - road.startOffsetRight, halfY,
      halfX - road.endOffsetRight, halfY + road.length
    }

    -- We might want to move to using polygons instead,
    -- since this creates a lot of edges
    local blocking = {}
    local leftWidth = road.endOffsetLeft - road.startOffsetLeft
    local rightWidth = road.endOffsetRight - road.startOffsetRight
    local count = road.length / 20.0
    for i = 1, count, 1 do
      -- Left side
      table.insert ( blocking, -halfX )
      table.insert ( blocking, halfY + i * 20)
      table.insert ( blocking, -halfX + road.startOffsetLeft + ( i / count ) * leftWidth - 20 )
      table.insert ( blocking, halfY + i * 20 )
      -- Right side
      table.insert ( blocking, halfX )
      table.insert ( blocking, halfY + i * 20)
      table.insert ( blocking, halfX - road.startOffsetRight - ( i / count ) * rightWidth + 20 )
      table.insert ( blocking, halfY + i * 20 )
    end

    road.blockEdges = road.blockPart:addEdges ( blocking )
    for i, fixture in ipairs ( road.blockEdges ) do
      fixture:setFilter ( 0x02 )
    end

    road.roadEdges = road.edgePart:addEdges ( edges )
    for i, fixture in ipairs ( road.roadEdges ) do
      fixture:setFilter ( 0x02 )
    end
    local expandLeft = road.startOffsetLeft < road.endOffsetLeft and EXPANDING or SHRINKING
    local expandRight = road.startOffsetRight < road.endOffsetRight and EXPANDING or SHRINKING
    local width = math.abs ( road.startOffsetLeft - road.endOffsetLeft )
    local yPos = (halfY + halfY + road.length) / 2
    local xPos = (road.startOffsetLeft + road.endOffsetLeft) / 2 - halfX
    local leftBorderProp = util.getProp ( getRoadBorderName ( LEFT, expandLeft ), width, road.length, xPos, yPos, road.edgePart )
    table.insert ( road.props, leftBorderProp )

    width = math.abs ( road.startOffsetRight - road.endOffsetRight )
    xPos = halfX - (road.startOffsetRight + road.endOffsetRight) / 2
    local rightBorderProp = util.getProp ( getRoadBorderName ( RIGHT, expandRight ), width, road.length, xPos, yPos, road.edgePart )
    table.insert ( road.props, rightBorderProp )

    local grassWidth = math.min ( road.startOffsetLeft, road.endOffsetLeft )
    xPos = -halfX + grassWidth/2
    local leftProp = util.getProp ( "gfx/level_themes/" .. theme .. "/side.png", grassWidth, road.length, xPos, yPos, road.edgePart )
    leftProp:setPriority ( 2 )
    table.insert ( road.props, leftProp )
    grassWidth = math.min ( road.startOffsetRight, road.endOffsetRight )
    xPos = halfX - grassWidth/2
    local rightProp = util.getProp ( "gfx/level_themes/" .. theme .. "/side.png", grassWidth, road.length, xPos, yPos, road.edgePart )
    rightProp:setPriority ( 2 )
    rightProp:setRot ( 180 )
    table.insert ( road.props, rightProp )

    local lineProp = util.getGrid ( 8, 48, "gfx/white.png", 0, 240, 8 )
    lineProp:setParent ( road.edgePart )
    lineProp:setPriority(-99)
    if not oldRoad then
      local lineProp2 = util.getGrid ( 8, 48, "gfx/white.png", 0, 0, 8 )
      lineProp2:setParent ( road.edgePart )
      lineProp2:setPriority(-99)
      table.insert ( road.props, lineProp2 )
    end

    -- Level finishing.
    if game and game.level and game.level.finishing and not game.level.lineInserted then
      game.level.lineInserted = true
      local finishProp = util.getGrid ( SCREEN_UNITS_X, 40, "gfx/finish.png", -SCREEN_UNITS_X / 2, yOffset )
      finishProp:setParent ( road.edgePart )
      finishProp:setPriority(-99)
      table.insert ( road.props, finishProp )
      road.finisher = true
    end

    table.insert ( road.props, lineProp )

  end
  road.edgePart:setLinearVelocity ( 0, -speed.getSpeed ())
  road.blockPart:setLinearVelocity ( 0, -speed.getSpeed () )
  road.speed = -speed.getSpeed ()

  road.onUpdate = function ( self )
    if self.speed ~= -speed.getSpeed () then
      self.speed = -speed.getSpeed ()
      self.edgePart:setLinearVelocity ( 0, -speed.getSpeed () )
      if self.blockPart then
        self.blockPart:setLinearVelocity ( 0, -speed.getSpeed () )
      end
    end
    if self.finisher then
      -- Find out if the road is beyond reach.
      local x, y = self.edgePart:getPosition()
      if y < -600 then
        game.level.lineFinished = true
      end
    end
  end


  road.shouldSpawn = function ( self )
    local x, y  = self.edgePart:getPosition ()
    if not x or not y then return end
    if (( road.first and y < -195 ) or -y >= (self.length -5)) and not self.spawned then
      self.spawned = true
      return true
    end
  end

  road.shouldDie = function ( self )
    local x, y  = self.edgePart:getPosition ()
    if -y - road.length - 200 > SCREEN_UNITS_Y then
      return true
    end
  end

  road.destroy = function ( self )
    for i, prop in next, self.props, nil do
      game.removePropFromGameLayer ( prop )
    end
    self.props = nil
    self.roadEdges = nil
    self.blockEdges = nil
    self.edgePart:destroy ()
    if self.blockPart then self.blockPart:destroy () end
  end

  road.setCollisionHandler = function ( func, blockFunc )
    for i, fixture in ipairs ( road.roadEdges ) do
      fixture:setCollisionHandler ( func, MOAIBox2DArbiter.BEGIN, 0xFFF )
    end
    if road.blockEdges then
      for i, fixture in ipairs ( road.blockEdges ) do
        fixture:setCollisionHandler ( func, MOAIBox2DArbiter.BEGIN, 0xFFF )
      end
    end
  end

  return road

end
