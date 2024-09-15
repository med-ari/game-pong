push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

PADDLE_SPEED = 200

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = false,
        vsync = 1
    })
    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    player1Score = 0
    player2Score = 0


    math.randomseed(os.time())

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)

    bola = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = "start"
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if gameState == "start" then
            gameState = "play"
        else
            gameState = "start"
            bola:reset()
        end
    end
end

function love.update(dt)
    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == "play" then
        bola:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.draw()
    push:apply('start')

    love.graphics.clear(30 / 255, 30 / 255, 46 / 255, 255 / 255)

    love.graphics.setColor(180 / 255, 190 / 255, 254 / 255)
    love.graphics.setFont(smallFont)

    -- ball starts moving in play state and reset default position in start state
    if gameState == 'start' then
        love.graphics.printf('Hello Start State!', 0, 20, VIRTUAL_WIDTH, 'center')
    else
        love.graphics.printf('Hello Play State!', 0, 20, VIRTUAL_WIDTH, 'center')
    end

    -- Score points
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 8)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 8)

    -- Paddles
    love.graphics.setColor(249 / 255, 226 / 255, 175 / 255)
    player1:render()
    player2:render()

    -- Ball
    love.graphics.setColor(243 / 255, 139 / 255, 168 / 255)
    bola:render()

    push:apply('end')
end
