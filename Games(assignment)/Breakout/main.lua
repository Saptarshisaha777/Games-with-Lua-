require 'src/Dependencies'

ball2 = Ball()
-- loading the main with all the global variables
function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- app window title
  love.window.setTitle('Breakout')

  math.randomseed(os.time())

  gFonts = {
    ['small'] = love.graphics.newFont('fonts/font.ttf', 8),
    ['medium'] = love.graphics.newFont('fonts/font.ttf', 16),
    ['large'] = love.graphics.newFont('fonts/font.ttf', 32)
  }
  love.graphics.setFont(gFonts['small'])


-- add the basic textures and Backgrounds for future use
  gTextures = {
    ['background'] = love.graphics.newImage('graphics/background.png'),
    ['main'] = love.graphics.newImage('graphics/breakout.png'),
    ['arrows'] = love.graphics.newImage('graphics/arrows.png'),
    ['hearts'] = love.graphics.newImage('graphics/hearts.png'),
    ['particle'] = love.graphics.newImage('graphics/particle.png'),
  }

-- adding the quad table for all the sprites
gFrames = {
    ['paddles'] = GenerateQuadsPaddles(gTextures['main']),
    ['balls'] = GenerateQuadsBalls(gTextures['main']),
    ['bricks'] = GenerateQuadsBricks(gTextures['main']),
    ['arrows'] = GenerateQuads(gTextures['arrows'], 24, 24),
    ['hearts'] = GenerateQuads(gTextures['hearts'], 10, 9),
    ['powers'] = GenerateQuadsPower(gTextures['main'])
}

  gSounds = {
    ['paddle-hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'stream'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['wall-hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static'),
    ['confirm'] = love.audio.newSource('sounds/confirm.wav', 'static'),
    ['select'] = love.audio.newSource('sounds/select.wav', 'static'),
    ['no-select'] = love.audio.newSource('sounds/no-select.wav', 'static'),
    ['brick-hit-1'] = love.audio.newSource('sounds/brick-hit-1.wav', 'static'),
    ['brick-hit-2'] = love.audio.newSource('sounds/brick-hit-2.wav', 'static'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
    ['victory'] = love.audio.newSource('sounds/victory.wav', 'static'),
    ['recover'] = love.audio.newSource('sounds/recover.wav', 'static'),
    ['high-score'] = love.audio.newSource('sounds/high_score.wav', 'static'),
    ['pause'] = love.audio.newSource('sounds/pause.wav', 'static'),

    ['music'] = love.audio.newSource('sounds/music.wav', 'stream')
  }

  gSounds['music']:setLooping(true)
  gSounds['music']:play()

  gStateMachine = StateMachine {
    ['start'] = function() return StartState() end,
    ['paddle-select'] = function() return PaddleSelectState() end,
    ['serve'] = function() return ServeState() end,
    ['play'] = function() return PlayState() end,
    ['game-over'] = function() return GameOverState() end,
    ['victory'] = function() return VictoryState() end,
    ['high-scores'] = function() return HighScoreState() end,
    ['enter-high-score'] = function() return EnterHighScoreState() end
  }

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })

  gStateMachine:change('start', {
        highScores = loadHighScores()
    })

  love.keyboard.keysPressed = {}

end


function love.resize(w, h)
  push:resize(w, h)
end


function love.keypressed(key)
  -- body...
  love.keyboard.keysPressed[key] = true

end

-- it is needed to check if a specific button is pressed by user by other classes as table values cannot be called directly
function love.keyboard.wasPressed(key)

  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end

end


function love.update(dt)

  gStateMachine:update(dt)

  love.keyboard.keysPressed = {}

end


function love.draw()

  push:start()

  local backgroundWidth = gTextures['background']:getWidth()
  local backgroundHeight = gTextures['background']:getHeight()

  love.graphics.draw(gTextures['background'],
    -- starting from 0 0 coordinate
    0, 0,
    -- no rotation
    0,
    -- scaling the image's x & y axis to fill the screen
    VIRTUAL_WIDTH / (backgroundWidth - 1), VIRTUAL_HEIGHT / (backgroundHeight - 1)
  )

  displayFPS()

  gStateMachine:render()

  push:finish()

end

function renderHealth(health)
    -- start of our health rendering
    local healthX = VIRTUAL_WIDTH - 100

    -- render health left
    for i = 1, health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][1], healthX, 4)
        healthX = healthX + 11
    end

    -- render missing health
    for i = 1, 3 - health do
        love.graphics.draw(gTextures['hearts'], gFrames['hearts'][2], healthX, 4)
        healthX = healthX + 11
    end
end

--[[
    Renders the current FPS.
]]
function displayFPS()
    -- simple FPS display across all states
    love.graphics.setFont(gFonts['small'])
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 5, 5)
    love.graphics.setColor(255, 255, 255, 255)
end

--[[
    Simply renders the player's score at the top right, with left-side padding
    for the score number.
]]
function renderScore(score)
    love.graphics.setFont(gFonts['small'])
    love.graphics.print('Score:', VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, 'right')
end


function loadHighScores()
    love.filesystem.setIdentity('breakout')

    -- if the file doesn't exist, initialize it with some default scores
    if not love.filesystem.getInfo('breakout.lst') then
        local scores = ''
        for i = 10, 1, -1 do
            scores = scores .. 'SPT\n'
            scores = scores .. tostring(i * 1000) .. '\n'
        end

        love.filesystem.write('breakout.lst', scores)
    end

    -- flag for whether we're reading a name or not
    local name = true
    local currentName = nil
    local counter = 1

    -- initialize scores table with at least 10 blank entries
    local scores = {}

    for i = 1, 10 do
        -- blank table; each will hold a name and a score
        scores[i] = {
            name = nil,
            score = nil
        }
    end

    -- iterate over each line in the file, filling in names and scores
    for line in love.filesystem.lines('breakout.lst') do
        if name then
            scores[counter].name = string.sub(line, 1, 3)
        else
            scores[counter].score = tonumber(line)
            counter = counter + 1
        end

        -- flip the name flag
        name = not name
    end

    return scores
end
