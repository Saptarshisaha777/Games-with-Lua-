StartState = Class{__includes = BaseState}

local option_no = 0
local total_option = 2

function StartState:update(dt)


  if love.keyboard.wasPressed('up') then
    option_no = (option_no - 1) % total_option
    --option_no = option_no < 0 and -option_no or option_no
    gSounds['paddle-hit']:play()
  elseif love.keyboard.wasPressed('down') then
    option_no = (option_no + 1) % total_option
    gSounds['paddle-hit']:play()
  end

  if love.keyboard.wasPressed('escape') then
    love.event.quit()
  end


  if love.keyboard.wasPressed('enter') or love.keyboard.wasPressed('return') then
    gSounds['confirm']:play()

    if option_no == 0 then
        gStateMachine:change('play')
    end
end

  --[[if love.keyboard.wasPressed('up') or love.keyboard.wasPressed('down') then
      option_no = option_no == 1 and 2 or 1
      gSounds['paddle-hit']:play()
  end]]

end

function StartState:render(dt)

  love.graphics.setFont(gFonts['large'])
  love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3,
      VIRTUAL_WIDTH, 'center')

  -- instructions
  love.graphics.setFont(gFonts['medium'])

  -- if we're highlighting 1, render that option blue
  if option_no == 0 then
      love.graphics.setColor(0, 255, 255, 255)
  end

  love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70,
      VIRTUAL_WIDTH, 'center')

  -- reset the color
  love.graphics.setColor(255, 255, 255, 255)

  -- render option 2 blue if we're highlighting that one
  if option_no == 1 then
      love.graphics.setColor(0, 255, 255, 255)
  end
  love.graphics.printf("HIGH SCORES", 0, VIRTUAL_HEIGHT / 2 + 90,
      VIRTUAL_WIDTH, 'center')

  -- reset the color
  love.graphics.setColor(255, 255, 255, 255)



end
