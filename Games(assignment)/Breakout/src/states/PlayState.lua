PlayState = Class{__includes = BaseState}

function PlayState:init()
  self.paddle = Paddle()
  -- self.ball =
end

function PlayState:update(dt)
  self.paddle:update(dt)
end

function PlayState:render()
  self.paddle:render()
end
