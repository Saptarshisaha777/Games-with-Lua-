Brick = Class()

powerblock = {}

function Brick:init(x, y, power)
  self.tier = math.random(0, 3)
  self.color = math.random(1, 5)

  self.x = x
  self.y = y
  self.width = 32
  self.height = 16

  self.inPlay = true
  self.hasPower = power

  self.psystem = love.graphics.newParticleSystem(gTextures['particle'], 64)
  self.psystem:setParticleLifetime(0.5, 1)
  self.psystem:setLinearAcceleration(-15, 0, 15, 80)
  self.psystem:setEmissionArea('normal', 10, 10)

end

paletteColors = {
  -- blue
  [1] = {
    ['r'] = 0.4,
    ['g'] = 0.6,
    ['b'] = 1
  },
  -- green
  [2] = {
    ['r'] = 0.42,
    ['g'] = 0.75,
    ['b'] = 0.18
  },
  -- red
  [3] = {
    ['r'] = 0.85,
    ['g'] = 0.34,
    ['b'] = 0.39
  },
  -- purple
  [4] = {
    ['r'] = 0.84,
    ['g'] = 0.48,
    ['b'] = 0.73
  },
  -- gold
  [5] = {
    ['r'] = 0.98,
    ['g'] = 0.95,
    ['b'] = 0.21
  }
}

function Brick:hit()

  self.psystem:setColors(
    paletteColors[self.color].r,
    paletteColors[self.color].g,
    paletteColors[self.color].b,
    55 * (self.tier + 1),
    paletteColors[self.color].r,
    paletteColors[self.color].g,
    paletteColors[self.color].b,
    0
  )
  self.psystem:emit(64)

  gSounds['brick-hit-2']:stop()
  gSounds['brick-hit-2']:play()

  if self.tier > 0 then
    if self.color == 1 then
      self.tier = self.tier - 1
      self.color = 5
    else
      self.color = self.color - 1
    end
  else
    if self.color == 1 then
      self.inPlay = false
      -- Condition for triggering the power class
      if self.hasPower then
        table.insert(powerblock, Power(self.x, self.y, self.hasPower))
      end
    else
      self.color = self.color - 1
    end
  end
end

function Brick:getPowerblock()
  return powerblock
end
function Brick:update(dt)
  self.psystem:update(dt)
  --[[for k, power in pairs(powerblock) do
    if power:hit(self.paddle) then
      if power.type == 1 and self.paddle.size < 5 then
        self.paddle.size = self.paddle.size + 1
      end
    end
    if power.y > VIRTUAL_HEIGHT then
      table.remove(powerblock, k)
    end
    power:update(dt)
  end]]

end


function Brick:render()
  if self.inPlay then
    love.graphics.draw(gTextures['main'],
      -- multiply color by 4 (-1) to get our color offset, then add tier to that
      -- to draw the correct tier and color brick onto the screen
      gFrames['bricks'][1 + ((self.color - 1) * 4) + self.tier],
    self.x, self.y)
    --love.graphics.draw(gTextures['main'],gFrames['bricks'][1],self.x,self.y)
  end
  for k, power in pairs(powerblock) do
    if power.trigger then
      power:render()
    end
  end
end

-- the particle render function
function Brick:renderParticles()
  love.graphics.draw(self.psystem, self.x + 16, self.y + 8)
end
