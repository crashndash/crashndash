module ("speed", package.seeall )

getSpeed = function (  )
  local carSpeed = 1
  if game and game.level then
    local car = game.getCar()
    carSpeed = car.properties.speed
  end
  return 240 * (game and game.level.speedFactor or 1) * carSpeed
end
