local level = Level.new ()

level.tagline = "Getting started..."

level:addInfo(1, "Welcome!\n" ..
  "You can control the car from side to side by pressing the arrow controls at the bottom!", {gfx = "gfx/handnarrows.png", width = 56, height = 128})

level:addInfo( 3, "The other cars are out to get you. Get rid of them by pushing them out of the road.\n\n" ..
  "You can also try to land on them while jumping. \n\n" ..
  "To jump, click anywhere on the screen." )

level:addInfo( 16, "There is a road block coming up! \n\nThe only way to avoid it is by jumping!" )

level:addBlock ( 18, 50 )

level:addInfo( 22, "Good job!\n\n" ..
  "This is the end of the level! Sometimes levels are finished by defeating a boss-car, but this was the easy one, remember?" )


level.enemyLimit = 1
level.length = 23

level.topScore = 9300

return level
