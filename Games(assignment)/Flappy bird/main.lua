
push = require "push"
Class = require 'class'
require 'Bird'
require 'Pipe'
require 'PipePair'

require 'StateMachine'
require 'states/BaseState'
require 'states/PlayState'
require 'states/TitleScreenState'
require 'states/EndState'
require 'states/CountState'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288


local background = love.graphics.newImage('background.png')
local background_scroll = 0

local ground = love.graphics.newImage('ground.png')
local ground_scroll = 0

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60

local LOOPING_POINT = 413 -- setting the bckground looping pont

--trophies for the winner
 TROPHY_B = love.graphics.newImage('winnerb.png')
 TROPHY_S = love.graphics.newImage('winners.png')
 TROPHY_G = love.graphics.newImage('winnerg.png')
--[[
local pipePairs = {}
local spawnTime = 0

local lastY = -PIPE_HEIGHT + math.random(80) + 20

local bird = Bird()

local scrolling = true
]]



function love.load()
  love.graphics.setDefaultFilter('nearest', 'nearest')

  -- app window title
  love.window.setTitle('Flappy Bird')

  -- initialize our nice-looking retro text fonts
  smallFont = love.graphics.newFont('font.ttf', 8)
  mediumFont = love.graphics.newFont('flappy.ttf', 14)
  flappyFont = love.graphics.newFont('flappy.ttf', 28)
  hugeFont = love.graphics.newFont('flappy.ttf', 56)
  love.graphics.setFont(flappyFont)

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })

  math.randomseed(os.time())

  gStateMachine = StateMachine {
    ['title'] = function() return TitleScreenState() end,
    ['play'] = function() return PlayState() end,
    ['end'] = function() return EndState() end,
    ['count'] = function() return CountState() end,
  }
  gStateMachine:change('title')

  sounds = {
    ['jump'] = love.audio.newSource('sounds/jump.wav', 'static'),
    ['explosion'] = love.audio.newSource('sounds/explosion.wav', 'static'),
    ['hurt'] = love.audio.newSource('sounds/hurt.wav', 'static'),
    ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
    ['music'] = love.audio.newSource('sounds/marios_way.mp3', 'static'),
    ['count'] = love.audio.newSource('sounds/count.wav', 'static')
  }

sounds['music']:setLooping(true)
sounds['music']:play()

  -- this keypressed table allows us to collect info if a button is pressed making it aceessable to other classes
  love.keyboard.keysPressed = {}

end

function love.resize(w, h)
  push:resize(w, h)
end


function love.keypressed(key)
  -- body...
  love.keyboard.keysPressed[key] = true
  if key == 'escape' then
    love.event.quit()
  end
end

-- it is needed to check if a specific button is pressed by user by other classes as table values cannot be called directly
function love.keyboard.wasPressed(key)

  if love.keyboard.keysPressed[key] then
    return true
  else
    return false
  end

end

-- the update function for the the entire module
function love.update(dt)

  -- PAUSING the Game Here
  if love.keyboard.wasPressed('p') then
    paused = true
  elseif love.keyboard.wasPressed('r') then
    paused = false
  end

  if not paused then
    background_scroll = (background_scroll + BACKGROUND_SCROLL_SPEED * dt) % LOOPING_POINT
    ground_scroll = (ground_scroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

    gStateMachine:update(dt)
  end
  love.keyboard.keysPressed = {}

end

-- Drawing the Graphic Elements
function love.draw()

  push:start()

  love.graphics.draw(background, - background_scroll, 0)

  gStateMachine:render()

  --[[  for k, pipePair in pairs(pipePairs) do
    pipePair:render()
  end]]
  if paused then
    love.graphics.setFont(hugeFont)
    love.graphics.printf('Pause', 0, 144-28, VIRTUAL_WIDTH, 'center')
    love.graphics.setFont(mediumFont)
    love.graphics.printf('Press [R] to resume', 0, 144+28, VIRTUAL_WIDTH, 'center')
  end

  love.graphics.draw(ground, - ground_scroll, VIRTUAL_HEIGHT - 16)


  --bird:render()

  push:finish()

end
