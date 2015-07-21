local level = Level.new ()
level.minOffset = 5
level.maxOffset = 20
level.jumpCount = 20

level:addBlock ( 4, 200, "gfx/bricks.png" )
level:alterRoad ( 5, 150 )
level:addBlock ( 6, 200 )
level:addBlock ( 8 )
level:addBlock ( 14 )
level:addBlock ( 18, 150, "gfx/water.png", true, 2 )
level:addBlock ( 24, 200, "gfx/bricks.png" )
level:alterRoad ( 25, 150 )
level:addBlock ( 26, 200, "gfx/water.png", true, 2 )
level:addBlock ( 28, 200, "gfx/water.png", true, 2 )
level:addBlock ( 34, 200, "gfx/bricks.png" )
level:addBlock ( 48, 250, "gfx/water.png", true, 2 )


level.length = 50

level.tagline = "A lot of jumps!"

level.topScore = 11000

return level
