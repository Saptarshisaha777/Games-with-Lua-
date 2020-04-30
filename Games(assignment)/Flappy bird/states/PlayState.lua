

PlayState = Class{__includes = BaseState}

PIPE_SPEED = 60
PIPE_WIDTH = 70
PIPE_HEIGHT = 288

BIRD_WIDTH = 38
BIRD_HEIGHT = 24

paused = false


function PlayState:init()
  self.bird = Bird()
  self.pipePairs = {}
  self.timer = 0

  self.score = 0

  -- initialize our last recorded Y value for a gap placement to base other gaps off of
  self.lastY = -PIPE_HEIGHT + math.random(80) + 20
end




function PlayState:update(dt)


    -- determining the spawn time of pipes
    self.timer = self.timer + dt

    -- inserting pipe elements in the pipes table( AT RANDOM LOCATION)
    if self.timer > math.random(2, 50) then

      local y = math.max(-PIPE_HEIGHT + 10, math.min(self.lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90 - PIPE_HEIGHT))
      --y = math.min(3 * VIRTUAL_HEIGHT/4, math.max(lastY + math.random(-20, 20), VIRTUAL_HEIGHT - 90))
      lastY = y
      table.insert(self.pipePairs, PipePair(y))
      self.timer = 0
    end


    for k, pPair in pairs(self.pipePairs) do
      -- updating the x value of each pipe
      pPair:update(dt)

      if not pPair.scored then
        if (pPair.x + PIPE_WIDTH) < (self.bird.x + BIRD_WIDTH / 2) then
          self.score = self.score + 1
          sounds['score']:play()
        end
        --pPair.scored = false
      end
      self.bird:scores(pPair)
    end

    --[[ for k, pPair in pairs(self.pipePairs) do
    if  pPair.scored then
      self.score = self.score + 1
      pPair.scored = false
    end
  end ]]

    for k, pPair in pairs(self.pipePairs) do
      -- Removing pipe elements in the pipes table
      if pPair.remove then
        table.remove(self.pipePairs, k)
      end

    end


    -- update bird based on gravity and input
    self.bird:update(dt)

    -- simple collision between bird and all pipes in pairs
    for k, pair in pairs(self.pipePairs) do
      for l, pipe in pairs(pair.pipes) do
        if self.bird:collides(pipe) then
          gStateMachine:change('end', {score = self.score})
        end
      end
    end

    --[[ reset if we get to the ground
    if self.bird.y > VIRTUAL_HEIGHT - 15 then
        gStateMachine:change('title')
    end]]

end

function PlayState:render()
  for k, pair in pairs(self.pipePairs) do
    pair:render()
  end

  love.graphics.setFont(flappyFont)
  love.graphics.print('Score: ' .. tostring(self.score), 8, 8)

  self.bird:render()

end
