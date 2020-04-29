
CountState = Class{__includes = BaseState}

function CountState:init()
  self.count = 3
  self.timer = 0
end

function CountState:update(dt)
  self.timer = self.timer + dt
  if self.timer > 1 then
    self.count = self.count - 1
    CountState:render()
    if self.count == -1 then
      gStateMachine:change('play')
    end
    self.timer = 0
  end

end

function CountState:render()
  love.graphics.setFont(hugeFont)
  love.graphics.printf(tostring(self.count), 0, 100, VIRTUAL_WIDTH, 'center')
end
