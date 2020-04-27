--[[
    GD50 2018
    Pong Remake

    pong-0
"The Day-0 Update"
-- Main Program --
Author: Colton Ogden
cogden@cs50.harvard.edu
Originally programmed by Atari in 1972. Features two
paddles, controlled by players, with the goal of getting
the ball past your opponent's edge. First to 10 points wins.
This version is built to more closely resemble the NES than
the original Pong machines or the Atari 2600 in terms of
resolution, though in widescreen (16:9) so it looks nicer on
modern systems.
]]
push = require "push"
Class = require 'class'
require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

servingPlayer=1

-- speed at which we will move our paddle; multiplied by dt in update
PADDLE_SPEED = 200



--[[
Runs when the game first starts up, only once; used to initialize the game.

function love.load()
--[[love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
})
 push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
     fullscreen = false,
     resizable = false,
     vsync = true
 })
end]]

function love.load()
  -- use nearest-neighbor filtering on upscaling and downscaling to prevent blurring of text
  -- and graphics; try removing this function to see the difference!
  love.graphics.setDefaultFilter('nearest', 'nearest')

  smallFont = love.graphics.newFont('font.ttf', 8)
  love.graphics.setFont(smallFont)

  scoreFont = love.graphics.newFont('font.ttf', 32)

  math.randomseed(os.time())


  -- initialize our virtual resolution, which will be rendered within our
  -- actual window no matter its dimensions; replaces our love.window.setMode call
  -- from the last example
  push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
    fullscreen = false,
    resizable = false,
    vsync = true
  })


  -- initialize score variables, used for rendering on the screen and keeping
  -- track of the winner
  player1Score = 0
  player2Score = 0
  --[[
    -- paddle positions on the Y axis (they can only move up or down)
    player1Y = 30
    player2Y = VIRTUAL_HEIGHT - 50

    -- velocity and position variables for our ball when play starts
    ballX = VIRTUAL_WIDTH / 2 - 2
    ballY = VIRTUAL_HEIGHT / 2 - 2

    -- math.random returns a random value between the left and right number
    ballDX = math.random(2) == 1 and 100 or -100
    ballDY = math.random(-50, 50)
]]

  -- initialize our player paddles; make them global so that they can be
  -- detected by other functions and modules
  player1 = Paddle(10, 30, 5, 20)
  player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT - 30, 5, 20)

  -- place a ball in the middle of the screen
  ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
  gameState = 'start'
end

--[[function love.keypressed(key)
  if key == 'escape' then
    love.event.quit()
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'play'
    else
      gameState = 'start'
  --[[ballX = VIRTUAL_WIDTH / 2 - 2
      ballY = VIRTUAL_HEIGHT / 2 - 2


      ballDX = math.random(2) == 1 and 100 or - 100
      ballDY = math.random(-50, 50)
      ]

      ball:reset()

    end
  end
end
]]

function love.keypressed(key)
  -- body...
  if key == 'escape' then
    love.event.quit()
    -- if we press enter during either the start or serve phase, it should
    -- transition to the next appropriate state
  elseif key == 'enter' or key == 'return' then
    if gameState == 'start' then
      gameState = 'serve'
    elseif gameState == 'serve' then
      gameState = 'play'
    end
  end
end


function love.update(dt)
  if gameState == 'serve' then
    -- before switching to play, initialize ball's velocity based
    -- on player who last scored
    ball.dy = math.random(-50, 50)
    if servingPlayer == 1 then
      ball.dx = math.random(140, 200)
    else
      ball.dx = -math.random(140, 200)
    end
  elseif gameState == 'play' then
    -- detect ball collision with paddles, reversing dx if true and
    -- slightly increasing it, then altering the dy based on the position of collision
    if ball:collides(player1) then
      ball.dx = -ball.dx * 1.03
      ball.x = player1.x + 5

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end
    if ball:collides(player2) then
      ball.dx = -ball.dx * 1.03
      ball.x = player2.x - 4

      -- keep velocity going in the same direction, but randomize it
      if ball.dy < 0 then
        ball.dy = -math.random(10, 150)
      else
        ball.dy = math.random(10, 150)
      end
    end

    -- detect upper and lower screen boundary collision and reverse if collided
    if ball.y <= 0 then
      ball.y = 0
      ball.dy = -ball.dy
    end

    -- -4 to account for the ball's size
    if ball.y >= VIRTUAL_HEIGHT - 4 then
      ball.y = VIRTUAL_HEIGHT - 4
      ball.dy = -ball.dy
    end
  end

  -- if we reach the left or right edge of the screen,
  -- go back to start and update the score
  if ball.x < 0 then
    servingPlayer = 1
    player2Score = player2Score + 1
    ball:reset()
    gameState = 'serve'
  end

  if ball.x > VIRTUAL_WIDTH then
    servingPlayer = 2
    player1Score = player1Score + 1
    ball:reset()
    gameState = 'serve'
  end

  -- player 1 movement
  if love.keyboard.isDown('w') then
    player1.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('s') then
    player1.dy = PADDLE_SPEED
  else
    player1.dy = 0
  end

  --[[ player 2 movement
  if love.keyboard.isDown('up') then
    player2.dy = -PADDLE_SPEED
  elseif love.keyboard.isDown('down') then
    player2.dy = PADDLE_SPEED
  else
    player2.dy = 0
  end]]

  ---- player 2 A.I.
  if gameState == 'play' then
    if ball.dx > 0 then
      --body...
      if player2.y+2 < ball.y then
        --body...
        player2.dy = PADDLE_SPEED
      elseif player2.y-2 > ball.y then
        player2.dy = -PADDLE_SPEED
      else
        player2.dy = 0

      end

    end
    end

  -- update our ball based on its DX and DY only if we're in play state;
  -- scale the velocity by dt so movement is framerate-independent
  if gameState == 'play' then
    ball:update(dt)
  end

  player1:update(dt)
  --if  ball.y ~= player2.y  then
    player2:update(dt)
  --end

end

--[[
Called after update by LÖVE2D, used to draw anything to the screen, updated or otherwise.
]]
function love.draw()
  -- begin rendering at virtual resolution
  push:apply('start')

  -- clear the screen with a specific color; in this case, a color similar
  -- to some versions of the original Pong
  love.graphics.clear(0, 0, 0, 255)

  love.graphics.setFont(smallFont)

  displayScore()

  if gameState == 'start' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'serve' then
    love.graphics.setFont(smallFont)
    love.graphics.printf('Player ' .. tostring(servingPlayer) .. "'s serve!",
    0, 10, VIRTUAL_WIDTH, 'center')
    love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
  elseif gameState == 'play' then
    -- no UI messages to display in play
  end


  -- render first paddle (left side)
  --love.graphics.rectangle('fill', 10, player1Y, 5, 20)
  player1:render()

  -- render second paddle (right side)
  --love.graphics.rectangle('fill', VIRTUAL_WIDTH - 10, player2Y, 5, 20)
  player2:render()
  -- render ball (center)
  --love.graphics.rectangle('fill', ballX, ballY, 4, 4)
  ball:render()

  -- new function just to demonstrate how to see FPS in LÖVE2D
  displayFPS()

  -- end rendering at virtual resolution
  push:apply('end')
end

--[[
  Renders the current FPS.
]]
function displayFPS()
  -- simple FPS display across all states
  love.graphics.setFont(smallFont)
  love.graphics.setColor(0, 255, 0, 255)
  love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
end


function displayScore()
  -- draw score on the left and right center of the screen
  -- need to switch font to draw before actually printing
  love.graphics.setFont(scoreFont)
  love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50,
  VIRTUAL_HEIGHT / 3)
  love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30,
  VIRTUAL_HEIGHT / 3)
end
