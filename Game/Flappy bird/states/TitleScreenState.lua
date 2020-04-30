
TitleScreenState = Class{__includes = BaseState}

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
        gStateMachine:change('count')
    end
end

function TitleScreenState:render()
    love.graphics.setFont(flappyFont)
    love.graphics.printf('Fifty Bird', 0, 64, VIRTUAL_WIDTH, 'center')

    love.graphics.setFont(mediumFont)
    love.graphics.setColor(255, 0, 255, 255)
    love.graphics.printf('Press Enter', 0, 100, VIRTUAL_WIDTH, 'center')
    love.graphics.setColor(255, 255, 255, 255)
end
