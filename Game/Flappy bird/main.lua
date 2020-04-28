
push = require "push"
Class = require 'class'
require 'Bird'

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

local LOOPING_POINT = 413

local bird = Bird()

function love.load()
  -- body...
  love.graphics.setDefaultFilter('nearest', 'nearest')

  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = true,
    vsync = true
  })

  -- this keypressed table allows us to collect info if a button is pressed making it aceessable to other classes
  love.keyboard.keysPressed = {}

end

function love.resize(w, h)
  -- body...
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


function love.update(dt)
   background_scroll = (background_scroll + BACKGROUND_SCROLL_SPEED * dt) % LOOPING_POINT
   ground_scroll = (ground_scroll + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH

   bird:update(dt)
   love.keyboard.keysPressed = {}


end

function love.draw()

  push:start()

  love.graphics.draw(background, -background_scroll, 0)
  love.graphics.draw(ground, -ground_scroll, VIRTUAL_HEIGHT-16)


  bird:render()

  push:finish()

end
