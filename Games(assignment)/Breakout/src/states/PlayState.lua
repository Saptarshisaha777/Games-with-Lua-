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
    self.ball.dy = -self.ball.dy

    if self.ball.x >= self.paddle.x  and self.ball.x <= self.paddle.x + self.paddle.width  then
        self.ball.dx = -self.ball.dx
        --self.ball.x = self.ball.x >= self.paddle.x and self.ball.x - 8 or self.ball.x + 8
      end


    gSounds['paddle-hit']:play()
  end

  if love.keyboard.wasPressed('escape') then
    gStateMachine:change('start')
  end
end

function PlayState:render()
  self.paddle:render()
  self.ball:render()
  if self.paused then
      love.graphics.setFont(gFonts['large'])
      love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end
