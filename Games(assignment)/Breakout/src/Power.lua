Power = Class()

function Power:init(x,y,trigger)
  self.x = x
  self.y = y
  self.side = 16
  self.dy = 20
  self.trigger = trigger == true and true or false
  self.type = math.random(1,3)
end

function Power:hit(target)
  -- first, check to see if the left edge of either is farther to the right
      -- than the right edge of the other
      if self.x > target.x + target.width or target.x > self.x + self.side then
          return false
      end

      -- then check to see if the bottom edge of either is higher than the top
      -- edge of the other
      if self.y > target.y + target.height or target.y > self.y + self.side then
          return false
      end

      -- if the above aren't true, they're overlapping
      return true
  end

  function Power:update(dt)
    if self.trigger then
      self.y = self.y + self.dy * dt
    end

  end

  function Power:render()
    love.graphics.draw(gTextures['main'], gFrames['powers'][self.type],
        self.x, self.y)
end
