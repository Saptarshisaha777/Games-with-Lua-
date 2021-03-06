PlayState = Class{__includes = BaseState}

local powerblock ={}
local healthInc = false

function PlayState:enter(params)
  self.paddle = params.paddle
  self.bricks = params.bricks
  self.health = params.health
  self.score = params.score
  self.ball = params.ball
  self.highScores = params.highScores
  self.level = params.level

  -- give ball random starting velocity
  self.ball.dx = math.random(-200, 200)
  self.ball.dy = math.random(-50, - 60)
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
    -- raise ball above paddle in case it goes below it, then reverse dy
    self.ball.y = self.paddle.y - 8
    self.ball.dy = -self.ball.dy

    --
    -- tweak angle of bounce based on where it hits the paddle
    --

    -- if we hit the paddle on its left side while moving left...
    if self.ball.x < self.paddle.x + (self.paddle.width / 2) and self.paddle.dx < 0 then
      self.ball.dx = -50 + - (8 * (self.paddle.x + self.paddle.width / 2 - self.ball.x))

      -- else if we hit the paddle on its right side while moving right...
    elseif self.ball.x > self.paddle.x + (self.paddle.width / 2) and self.paddle.dx > 0 then
      self.ball.dx = 50 + (8 * math.abs(self.paddle.x + self.paddle.width / 2 - self.ball.x))
    end

    gSounds['paddle-hit']:play()
  end

  -- detect collision across all bricks with the ball
  for k, brick in pairs(self.bricks) do

    -- only check collision if we're in play
    if brick.inPlay and self.ball:collides(brick) then

      -- add to score
      self.score = self.score + (brick.tier * 200 + brick.color * 25)

      -- trigger the brick's hit function, which removes it from play
      brick:hit()

      -- go to our victory screen if there are no more bricks left
      if self:checkVictory() then
        gSounds['victory']:play()

        -- resetting the power table and the paddle attributes
        for k, power in pairs(powerblock) do
          table.remove(powerblock,k)
        end
        self.paddle.size = 2
        self.paddle.width = 64
        self.paddle.height = 16

        gStateMachine:change('victory', {
          level = self.level,
          paddle = self.paddle,
          health = self.health,
          score = self.score,
          ball = self.ball,
          highScores = self.highScores
        })
      end

      --
      -- collision code for bricks
      --
      -- we check to see if the opposite side of our velocity is outside of the brick;
      -- if it is, we trigger a collision on that side. else we're within the X + width of
      -- the brick and should check to see if the top or bottom edge is outside of the brick,
      -- colliding on the top or bottom accordingly
      --

      -- left edge; only check if we're moving right, and offset the check by a couple of pixels
      -- so that flush corner hits register as Y flips, not X flips
      if self.ball.x + 2 < brick.x and self.ball.dx > 0 then

        -- flip x velocity and reset position outside of brick
        self.ball.dx = -self.ball.dx
        self.ball.x = brick.x - 8

        -- right edge; only check if we're moving left, , and offset the check by a couple of pixels
        -- so that flush corner hits register as Y flips, not X flips
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

  -- if ball goes below bounds, revert to serve state and decrease health
  if self.ball.y >= VIRTUAL_HEIGHT then
    self.health = self.health - 1
    gSounds['hurt']:play()

    if self.health == 0 then
      gStateMachine:change('game-over', {
        score = self.score,
        highScores = self.highScores
      })
    else
      for k, power in pairs(powerblock) do
        table.remove(powerblock,k)
      end
      self.paddle.size = 2
      self.paddle.width = 64
      self.paddle.height = 16
      gStateMachine:change('serve', {
        paddle = self.paddle,
        bricks = self.bricks,
        health = self.health,
        score = self.score,
        level = self.level,
        highScores = self.highScores
      })
    end
  end

  -- for rendering particle systems
  for k, brick in pairs(self.bricks) do
    brick:update(dt)
    powerblock = brick:getPowerblock()
  end

  for k, power in pairs(powerblock) do
    if power:hit(self.paddle) then
      gSounds['confirm']:stop()
      gSounds['confirm']:play()
      if power.type == 1 and self.paddle.size < 4 then
        self.paddle.size = self.paddle.size + 1
        self.paddle.width = self.paddle.width + 32
      elseif power.type == 2 and self.paddle.size > 1 then
        self.paddle.size = self.paddle.size - 1
        self.paddle.width = self.paddle.width - 32
      end
      table.remove(powerblock, k)
    end
    if power.y > VIRTUAL_HEIGHT then
      table.remove(powerblock, k)
    end
    power:update(dt)
  end

-- increase health depending on the score
  if self.score > 20000 and not healthInc and self.health < 3 then
    self.health = self.health + 1
    gSounds['recover']:play()
    healthInc = true
  end



  if love.keyboard.wasPressed('escape') then
    gStateMachine:change('serve', {
      paddle = self.paddle,
      bricks = self.bricks,
      health = self.health,
      score = self.score
    })
  end
end


function PlayState:render()

  for k, brick in pairs(self.bricks) do
    brick:render()
  end

  -- render all particle systems
  for k, brick in pairs(self.bricks) do
    brick:renderParticles()
  end

  self.paddle:render()
  self.ball:render()

  renderScore(self.score)
  renderHealth(self.health)
  if self.paused then
    love.graphics.setFont(gFonts['large'])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 16, VIRTUAL_WIDTH, 'center')
  end
end


function PlayState:checkVictory()
  for k, brick in pairs(self.bricks) do
    if brick.inPlay then
      return false
    end  end

  return true
end
