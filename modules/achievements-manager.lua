module ( "achmng", package.seeall )

getUnlockList = function (  )

  return {
    {
      id = 'morejumps',
      points = 400000,
      title = "Start with more jumps",
      count = true,
    },
    {
      id = "bomb",
      points = 100000,
      title = "Start with bombs",
      count = true,
      counter = "count"
    },
    {
      id = "rocket",
      points = 500000,
      title = "Rockets for multiplayer",
      count = true,
      counter = "count"
    },
    {
      id = "swarm",
      points = 500000,
      title = "Swarms for multiplayer",
      count = true,
      counter = "count"
    },
    {
      id = "nitro",
      points = 500000,
      title = "Start with nitro",
      count = true,
      counter = "count"
    },
    {
      id = "invincible",
      points = 500000,
      title = "Start with shield",
      count = true,
      counter = "count"
    },
    {
      id = 'survival',
      points = 1000000,
      title = "Unlock survival mode",
    },
    {
      id = "bwplay",
      points = 3000000,
      title = 'Unlock vehicle "small cab"',
      altUnlock = globalData.config.boughtAllCars
    },
    {
      id = "tanksplay",
      points = 3000000,
      title = 'Unlock vehicle "D-stroyer"',
      altUnlock = globalData.config.boughtAllCars
    },
    {
      id = "ufoplay",
      points = 3000000,
      title = 'Unlock vehicle "alien cruiser"',
      altUnlock = globalData.config.boughtAllCars
    }
  }
end

countUnlocksAvailable = function ()
  -- Well the function name lies. It just counts unlocks we can buy at level 1.
  local avail = 0
  local list = getUnlockList()
  for i, n in next, list, nil do
    if n.points < globalData.config.expPoints then
      avail = avail + 1
    end
  end
  return avail
end

sendAchievements = function ( layer )
  local achievementlist = getAchievementlist ()
  for i, a in next, achievementlist, nil do
    if a.truth then
      -- This achievement evaluated to true. Save and try to send.
      local notify = saveAchievement ( a, a.steps )
      if notify then
        -- This user has cleared this. Show a popup.
        layer.popups = layer.popups or {}
        table.insert( layer.popups, Popup.new ( 'You just earned the achievement "' .. a.title .. '"', layer ))
        -- Just to be sure we don't forget to add expPoints to a future
        -- achievement:
        a.expPoints = a.expPoints or 200
        config.data.config.expPoints = config.data.config.expPoints + a.expPoints
        table.insert( layer.popups, Popup.new ( 'You just earned ' .. a.expPoints .. ' extra experience points', layer ))
        globalData.notify.achievements = globalData.notify.achievements or 0
        globalData.notify.achievements = globalData.notify.achievements + 1
      end
    end
  end
  -- Check if we should notify the user of new weapons available.
  if globalData.weaponsAvailable < achmng.countUnlocksAvailable() then
    globalData.notify.globalstats = achmng.countUnlocksAvailable() - globalData.weaponsAvailable
    globalData.weaponsAvailable = achmng.countUnlocksAvailable()
  end
end

onUpdate = function ( layer )
  -- Ask this one time only.
  if not globalData.config.askedToRate then
    if globalData.config.playDuration > 600 then
      -- Person has played for 10 minutes. Probably enough to rate the app,
      -- right?
      globalData.config.askedToRate = true
      if MOAIDialog then
        MOAIDialog.showDialog("Rate us?", "Get 500 000 experience point to rate the game", "OK!", nil, "No, thanks.", false, function (answer)
          if answer == MOAIDialog.DIALOG_RESULT_POSITIVE then
            -- Awesome. This person rocks!
            local url = "http://itunes.com/apps/crashndash"
            if MOAIAppAndroid then
              url = "market://details?id=no.morland.roadrage"
            end
            util.openURL(url)
            globalData.config.expPoints = globalData.config.expPoints + 500000
            globalData.config.clickedRate = true
          end
        end)
      end
    end
  end
  if not layer.popups then return end
  if #layer.popups > 0 then
    if not layer.popups[1].showing then
      layer.popups[1].showing = true
      layer.popups[1]:show ()
    end
    if layer.popups[1] and layer.popups[1].shown then
      table.remove ( layer.popups, 1 )
    end
  end
end

getAchievementlist = function ()
  return {
    { id = "level5",
      title = "Getting started",
      predescription = "Finish level 1-5",
      truth = globalData.config.maxLevels[1] and globalData.config.maxLevels[1] > 5,
      steps = 1,
      totalsteps = 1,
      expPoints = 2000
    },
    { id = "level15",
      title = "Levelling up",
      predescription = "finish level 1-15",
      truth = globalData.config.maxLevels[1] and globalData.config.maxLevels[1] > 15,
      steps = 1,
      totalsteps = 1,
      expPoints = 20000
    },
    { id = "level30",
      predescription = "Finish level 1-30",
      title = "An expert!",
      truth = globalData.config.win,
      steps = 1,
      totalsteps = 1,
      expPoints = 500000
    },
    { id = "level2_10",
      predescription = "Finish level 2-10",
      title = "A stayer!",
      truth = globalData.config.maxLevels[2] and globalData.config.maxLevels[2] > 10,
      steps = 1,
      totalsteps = 1,
      expPoints = 500000
    },
    { id = "level2_15",
      predescription = "Finish all levels in world 2",
      title = "World class driver!",
      truth = globalData.config.maxLevels[2] and globalData.config.maxLevels[2] > 10,
      steps = 1,
      totalsteps = 1,
      expPoints = 500000
    },
    { id = "crash500",
      title = "Crash 500 cars",
      predescription = "crash 500 cars",
      truth = game and game.lastcarscrashed and game.lastcarscrashed > 0,
      steps = game and game.lastcarscrashed or 1,
      count = true,
      totalsteps = 500,
      expPoints = 50000
    },
    { id = "crash1000",
      title = "Car crash o rama",
      predescription = "crash 1000 cars",
      truth = game and game.lastcarscrashed and game.lastcarscrashed > 0,
      steps = game and game.lastcarscrashed or 1,
      count = true,
      totalsteps = 1000,
      expPoints = 150000
    },
    { id = "crash5000",
      title = "Road rage 5000",
      predescription = "crash 5000 cars",
      truth = game and game.lastcarscrashed and game.lastcarscrashed > 0,
      steps = game and game.lastcarscrashed or 1,
      count = true,
      totalsteps = 5000,
      expPoints = 300000
    },
    { id = "25perlevel",
      title = "Aggressive driving",
      predescription = "Crash 25 cars in one level",
      truth = game and game.lastcarscrashed and game.lastcarscrashed >= 25,
      steps = 1,
      totalsteps = 1,
      expPoints = 10000
    },
    { id = "100perlevel",
      title = "Great level",
      predescription = "Crash 100 cars in one level",
      truth = game and game.lastcarscrashed and game.lastcarscrashed >= 100,
      steps = 1,
      totalsteps = 1,
      expPoints = 100000
    },
    { id = "250perlevel",
      title = "Killer level",
      predescription = "Crash 250 cars in one level",
      truth = game and game.lastcarscrashed and game.lastcarscrashed >= 250,
      steps = 1,
      totalsteps = 1,
      expPoints = 1000000
    },
    { id = "careful5",
      title = "Careful driving",
      predescription = "Crash 0 cars on level 5, world 1",
      truth = game and game.lastcarscrashed and game.lastcarscrashed == 0 and globalData.config.currentLevel == 5 and globalData.config.currentWorld == 1 and not globalData.gameover,
      steps = 1,
      totalsteps = 1,
      expPoints = 1000000
    },
    { id = "careful15",
      title = "Very careful driving",
      predescription = "Crash less than 100 cars on level 15, world 1",
      truth = game and game.lastcarscrashed and game.lastcarscrashed < 100 and globalData.config.currentLevel == 15 and globalData.config.currentWorld == 1 and not globalData.gameover,
      steps = 1,
      totalsteps = 1,
      expPoints = 1000000
    },
    { id = "score10000",
      predescription = "Score 10000 points",
      title = "My first personal record",
      truth = globalData.gameover and globalData.score > 10000,
      steps = 1,
      totalsteps = 1,
      expPoints = 20000
    },
    { id = "score25000",
      title = "Not just luck",
      predescription = "Score 25000 points at least 5 times",
      truth = globalData.gameover and globalData.score > 25000,
      steps = 1,
      count = true,
      totalsteps = 5,
      expPoints = 75000
    },
    { id = "score50000",
      title = "Climbing the highscores list",
      predescription = "Score 50000 points",
      truth = globalData.gameover and globalData.score > 50000,
      steps = 1,
      totalsteps = 1,
      expPoints = 100000
    },
    { id = "score100000",
      title = "For the record books",
      predescription = "Score 100000 points",
      truth = globalData.gameover and globalData.score > 100000,
      steps = 1,
      totalsteps = 1,
      expPoints = 300000
    },
    { id = "unlockworld2",
      title = "A new world!",
      predescription = "Unlock world 2",
      truth = achmng.countStars() > 35,
      steps = 1,
      totalsteps = 1,
      expPoints = 20000
    },
    {
      id = "100zombies",
      title = "Cleaning the streets",
      predescription = "Kill 100 zombies",
      truth = game and game.lastObstaclesKilled and game.lastObstaclesKilled.zombie and game.lastObstaclesKilled.zombie > 0,
      steps = (game and game.lastObstaclesKilled and game.lastObstaclesKilled.zombie) or 1,
      totalsteps = 100,
      expPoints = 10000,
      count = true
    },
    {
      id = "1000zombies",
      title = "Zombie massacre",
      predescription = "Kill 1000 zombies",
      truth = game and game.lastObstaclesKilled and game.lastObstaclesKilled.zombie and game.lastObstaclesKilled.zombie > 0,
      steps = (game and game.lastObstaclesKilled and game.lastObstaclesKilled.zombie) or 1,
      totalsteps = 1000,
      expPoints = 80000,
      count = true
    },
    {
      id = "100tanks",
      title = "Start a war!",
      predescription = "Crash 100 tanks",
      truth = game and game.typesCrashed and game.typesCrashed.fascist and game.typesCrashed.fascist > 1,
      steps = (game and game.typesCrashed and game.typesCrashed.fascist and game.typesCrashed.fascist) or 1,
      totalsteps = 100,
      expPoints = 100000,
      count = true
    },
    {
      id = "100aliens",
      title = "Star wars!",
      predescription = "Crash 100 UFOs",
      truth = game and game.typesCrashed and game.typesCrashed.ufo and game.typesCrashed.ufo > 1,
      steps = (game and game.typesCrashed and game.typesCrashed.ufo and game.typesCrashed.ufo) or 1,
      totalsteps = 100,
      expPoints = 100000,
      count = true
    },
    { id = "fbconnect",
      title = "Connected!",
      predescription = "Connect the game with facebook",
      truth = globalData.config.fb,
      steps = 1,
      totalsteps = 1,
      expPoints = 20000
    },
    { id = "hiscorepost",
      title = "On the list!",
      predescription = "Post your highscore",
      truth = globalData.hiscorePosted,
      steps = 1,
      totalsteps = 1,
      expPoints = 10000
    },
    { id = "gamecenterconnected",
      title = "Socially playing!",
      predescription = "Connect with " .. Gamecenter.centername,
      truth = globalData.config.gamecenterConnected,
      steps = 1,
      totalsteps = 1,
      expPoints = 10000
    },
    { id = "multiplay1",
      title = "Making friends",
      predescription = "Win a multiplayer match",
      truth = multiplayer.won,
      steps = 1,
      totalsteps = 1,
      expPoints = 20000
    },
    { id = "multiplay5",
      title = "A social person",
      predescription = "Win 5 multiplayer matches",
      truth = multiplayer.won,
      steps = 1,
      totalsteps = 5,
      count = true,
      expPoints = 50000
    },
    { id = "multiplay20",
      truth = multiplayer.won,
      title = "Multiplayer addicted?",
      predescription = "Win 20 multiplayer matches",
      steps = 1,
      totalsteps = 20,
      count = true,
      expPoints = 150000
    },
    { id = "multiplay100",
      truth = multiplayer.won,
      title = "Just one more game",
      predescription = "Win 100 multiplayer matches",
      steps = 1,
      totalsteps = 100,
      count = true,
      expPoints = 1000000
    },
    { id = "multiplay10000",
      predescription = "Score more than 10000 in a round of multiplayer.",
      title = "Great multiplayer round",
      truth = multiplayer.score > 9999,
      steps = 1,
      totalsteps = 1,
      expPoints = 100000
    },
    { id = "multiplay20000",
      predescription = "Score more than 20000 in a round of multiplayer.",
      title = "Fantastic multiplayer round",
      truth = multiplayer.score > 19999,
      steps = 1,
      totalsteps = 1,
      expPoints = 500000
    },
    { id = "custom5",
      predescription = "Complete 5 different levels found online",
      title = "Broaden the horizon",
      truth = countWorldScores('special') > 4,
      steps = 1,
      totalsteps = 1,
      expPoints = 50000
    },
    { id = "custom15",
      predescription = "Complete 15 different levels found online",
      title = "Impressive list",
      truth = countWorldScores('special') > 14,
      steps = 1,
      totalsteps = 1,
      expPoints = 100000
    },
    { id = "custom25",
      predescription = "Complete 25 different levels found online",
      title = "Gotta try them all",
      truth = countWorldScores('special') > 24,
      steps = 1,
      totalsteps = 1,
      expPoints = 200000
    },
    { id = "survival10",
      title = "Just to survive",
      predescription = "Finish level 10 of survival mode",
      truth = game and game.level and game.level.survivalLevel and game.level.survivalLevel > 9,
      steps = 1,
      totalsteps = 1,
      expPoints = 20000
    },
    { id = "survival20",
      title = "Survival",
      predescription = "Finish level 20 of survival mode",
      truth = game and game.level and game.level.survivalLevel and game.level.survivalLevel > 19,
      steps = 1,
      totalsteps = 1,
      expPoints = 100000
    },
    { id = "survival30",
      predescription = "Finish level 30 of survival mode",
      title = "A survivor",
      truth = game and game.level and game.level.survivalLevel and game.level.survivalLevel > 29,
      steps = 1,
      totalsteps = 1,
      expPoints = 500000
    },
    { id = "supporter",
      predescription = "Buy something from the game shop",
      title = "A supporter!",
      truth = globalData.usedShop,
      steps = 1,
      totalsteps = 1,
      expPoints = 2000000
    },
    { id = "twfollow",
      predescription = "Follow Crash n dash on twitter",
      title = "A follower!",
      truth = globalData.config.twfollow,
      steps = 1,
      totalsteps = 1,
      expPoints = 2000
    },
    { id = "fbfollow",
      predescription = "Like us on facebook",
      title = "A fan!",
      truth = globalData.config.fbfollow,
      steps = 1,
      totalsteps = 1,
      expPoints = 2000
    },
    {
      id = "hiddencar",
      predescription = "Unlock the secret hidden car",
      title = "Ghost car",
      truth = globalData.config.carType and globalData.config.carType == "whitecar",
      steps = 1,
      totalsteps = 1,
      expPoints = 100000
    },
    { id = "30stars",
      predescription = "Collect 30 stars",
      title = "Star collector",
      truth = countStars () >= 30,
      steps = 1,
      totalsteps = 1,
      expPoints = 50000
    },
    { id = "50stars",
      predescription = "Collect 50 stars",
      title = "Star wars",
      truth = countStars () >= 50,
      steps = 1,
      totalsteps = 1,
      expPoints = 100000
    },
    { id = "75stars",
      predescription = "Collect 75 stars",
      title = "Starfleet academy graduate",
      truth = countStars () >= 75,
      steps = 1,
      totalsteps = 1,
      expPoints = 200000
    },
    { id = "10threestars",
      predescription = "Collect 3 stars on 10 levels",
      title = "Perfectionist",
      truth = countLevelsWithKStarsOrMore (3) >= 10,
      steps = 1,
      totalsteps = 1,
      expPoints = 150000
    },
    { id = "20threestars",
      predescription = "Collect 3 stars on 20 levels",
      title = "Nice trophy collection",
      truth = countLevelsWithKStarsOrMore (3) >= 20,
      steps = 1,
      totalsteps = 1,
      expPoints = 500000
    },
    { id = "30threestars",
      predescription = "Collect 3 stars on 30 levels",
      title = "Gotta catch'em all",
      truth = countLevelsWithKStarsOrMore (3) >= 30,
      steps = 1,
      totalsteps = 1,
      expPoints = 1500000
    },
  }
end

countStars = function (world)
  if not globalData.config.doneWorlds then return 0 end
  local count = 0
  for i in next, globalData.config.doneWorlds do
    if world and world ~= i then
      -- No go.
    else
      for j, stars in next, globalData.config.doneWorlds[i], nil do
        count = count + stars
      end
    end
  end
  return count
end

countLevelsWithKStarsOrMore = function ( K )
  if not globalData.config.doneWorlds then return 0 end
  local count = 0
  for i in next, globalData.config.doneWorlds do
    for j, stars in next, globalData.config.doneWorlds[i], nil do
      if stars >= K then count = count + 1 end
    end
  end
  return count
end

countWorldScores = function(world)
  local c = 0
  for i, s in next, globalData.config.worldScores[world] do
    c = c + 1
  end
  return c
end

saveAchievement = function ( achievement, steps )
  local id = achievement.id
  config.data.config.achievements[id] = config.data.config.achievements[id] or 0
  local notify = false
  local a = achievement
  if a.totalsteps then
    if config.data.config.achievements[id] < a.totalsteps and config.data.config.achievements[id] + steps >= a.totalsteps then
      notify = true
    end
  end
  if notify or a.count then
    config.data.config.achievements[id] = config.data.config.achievements[id] + steps
  end

  config:saveGame ()
  return notify
end

getMyAchievements = function ( layer )
  local configs = globalData.config
  local id = configs.id or ""
  if not configs.fb then
    -- @todo fix this
    -- Do something useful.
  end
  menu.clearScreen ( layer )
  -- Parse from json.
  -- Iterate over results.
  layer.achievements = {}
  local nextYValue = 130
  local nextXValue = 15
  local delta = 1
  local list = getAchievementlist ()
  menu.setTotalPagerItems ( layer, #list )
  local leftbutton, rightbutton, pagetext = menu.makePagerButtons ( layer, - 130 )
  menu.new ( layer, { leftbutton, rightbutton, pagetext } )
  for count, a_local in next, list, nil do
    if menu.pageItems ( layer, delta ) then
      local a = a_local
      local i = a_local.id
      local title = a.title
      local text = a.predescription
      local achievementslist = configs.achievements or {}
      local completed = achievementslist[i] or 0
      local check
      local width = SCREEN_UNITS_X - 20
      local height = 30
      local bg
      if completed >= a.totalsteps then
        text = text .. " (done)"
        check = util.getProp ( "gfx/check.png", 12, 12, -SCREEN_UNITS_X / 2 + 20, nextYValue )
        bg = util.getProp ( "gfx/black.png", width + 6, height + 8, 0, nextYValue )
      else
        if a_local.count then
          text = text .. " (" .. completed .. " of " .. a.totalsteps .. " done)"
        else
          text = text .. " (not done)"
        end
        check = util.getProp ( "gfx/check-no.png", 12, 12, -SCREEN_UNITS_X / 2 + 20, nextYValue )
        bg = util.getProp ( "gfx/background.png", width + 6, height + 8, 0, nextYValue )
      end
      layer.achievements[i] = util.makeText ( text, width - 35, height, nextXValue, nextYValue - 8, 8 )
      layer.achievements[i].title = util.makeText ( title, width - 35, height, nextXValue, nextYValue, 16 )
      layer.achievements[i]:setAlignment ( MOAITextBox.LEFT_JUSTIFY, MOAITextBox.CENTER_JUSTIFY )
      layer:insertProp ( bg )
      nextYValue = nextYValue - 40

      layer:insertProp ( layer.achievements[i] )
      layer:insertProp ( check )
      layer:insertProp ( layer.achievements[i].title )
    end
    delta = delta + 1
  end
end
