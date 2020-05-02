PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  self.ball = Ball(math.random(7))

  -- give ball random starting velocity
  self.ball.dx = 200 --math.random(-200, 200)
  self.ball.dy = -60 --math.random(-50, - 60)

  -- give ball position in the center
  self.ball.x = VIRTUAL_WIDTH / 2 - 4
  self.ball.y = VIRTUAL_HEIGHT - 42

  self.bricks = LevelMaker.createMap()
end

function PlayState:update(dt)
  if self.paused then
      if love.keyboard.wasPressed('space') then
          self.paused = false
          gSounds['pause']:play()
      else
          return
      end
  elseif love.keyboard.wasPressed('space') then
      self.paused = true
      gSounds['pause']:play()
      return
  end

  self.paddle:update(dt)
  self.ball:update(dt)

  if self.ball:collides(self.paddle) then

    self.ball.y = self.paddle.y - 8
    self.ball.dy = -self.ball.dy

    --[[if self.ball.x >= self.paddle.x  and self.ball.x <= self.paddle.x + self.paddle.width  then
        self.ball.dx = -self.ball.dx
        --self.ball.x = self.ball.x >= self.paddle.x and self.ball.x - 8 or self.ball.x + 8
      end]]

      -- if we hit the paddle on its left side while moving left...
      if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
          self.ball.dx = -50 + -(8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))

          -- else if we hit the paddle on its right side while moving right...
      elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
          self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
      end


    gSounds['paddle-hit']:play()
  end

  for k,brick in pairs(self.bricks) do

    if brick.inPlay and self.ball:collides(brick) then
      brick:hit()

      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then

          -- flip x velocity and reset position outside of brick
          self.ball.dx = -self.ball.dx
          self.ball.x = brick.x - 8

      -- right edge; only check if we're moving left
      elseif self.ball.x + 6 > brick.x + brick.width and self.ball.dx < 0 then

          -- flip x velocity and reset position outside of brick
          self.ball.dx = -self.ball.dx
          self.ball.x = brick.x + 32

      -- top edge if no X collisions, always check
      elseif self.ball.y < brick.y then

          -- flip y velocity and reset position outside of brick
          self.ball.dy = -self.ball.dy
          self.ball.y = brick.y - 8

      -- bottom edge if no X collisions or top collision, last possibility
      else

          -- flip y velocity and reset position outside of brick
          self.ball.dy = -self.ball.dy
          self.ball.y = brick.y + 16
      end

      -- slightly scale the y velocity to speed up the game
      self.ball.dy = self.ball.dy * 1.02

      -- only allow colliding with one brick, for corners
      break
  end
end


  if love.keyboard.wasPressed('escape') then
    gStateMachine:change('start')
  end
end

function PlayState:render()

  for k, brick in pairs(self.bricks) do
      brick:render()
  end

  self.paddle:render()
  self.ball:render()
  if self.paused then
      love.graphics.setFont(gFonts['large'])
      love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end
