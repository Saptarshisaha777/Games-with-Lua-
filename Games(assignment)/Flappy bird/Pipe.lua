Pipe = Class{}

local PIPE_IMG = love.graphics.newImage('pipe.png')

PIPE_HEIGHT = 288
PIPE_WIDTH = 70

PIPE_SPEED = 60

function Pipe:init(orientation , y)
  self.x = VIRTUAL_WIDTH
  --self.y = love.math.random(VIRTUAL_HEIGHT/4,VIRTUAL_HEIGHT - VIRTUAL_HEIGHT/4 + 8)
  self.y = y
  self.width = PIPE_IMG:getWidth()
  self.height = PIPE_HEIGHT
  self.orientation = orientation

end

function Pipe:update(dt)
  --self.x = self.x + PIPE_SCROLL* dt
end

function Pipe:render()
    love.graphics.draw(PIPE_IMG, self.x,
        (self.orientation == 'top' and self.y + PIPE_HEIGHT or self.y),
        0, 1, self.orientation == 'top' and -1 or 1)
end
