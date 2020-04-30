
EndState = Class{__includes = BaseState}


function EndState:enter(param)
   self.f_score = param.score
end

function EndState:update(dt)
    -- go back to play if enter is pressed
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('title')
    end
end

function EndState:render()
  love.graphics.setFont(flappyFont)
  love.graphics.printf('SORRY! You lost!', 0, 64, VIRTUAL_WIDTH,'center')

  love.graphics.setFont(mediumFont)
  love.graphics.printf('Score: ' .. tostring(self.f_score), 0, 100, VIRTUAL_WIDTH, 'center')
  if self.f_score >= 5 and self.f_score < 10 then
    love.graphics.draw(TROPHY_B, VIRTUAL_WIDTH/2 - 64, 116)
  elseif self.f_score >= 10 and self.f_score <= 15 then
    love.graphics.draw(TROPHY_S, VIRTUAL_WIDTH/2 - 64, 116)
  elseif self.f_score >= 15 and self.f_score <= 20 then
    love.graphics.draw(TROPHY_G, VIRTUAL_WIDTH/2 - 64, 116)
  end

  love.graphics.printf('Press Enter to Play Again!', 0, 248, VIRTUAL_WIDTH, 'center')
end
