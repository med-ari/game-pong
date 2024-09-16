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
        resizable = true,
        vsync = 1
    })

    love.window.setTitle("Pongo")

    math.randomseed(os.time())

    smallFont = love.graphics.newFont("font.ttf", 8)
    scoreFont = love.graphics.newFont("font.ttf", 32)

    sound = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav', 'static'),
        ['score'] = love.audio.newSource('sounds/score.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav', 'static')
    }

    
    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 15, VIRTUAL_HEIGHT - 50, 5, 20)
    
    bola = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)
    
    player1Score = 0
    player2Score = 0

    winner = 0

    servingPlayer = math.random(1, 2)

    gameState = "start"
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if gameState == "start" then
            gameState = "serve"
        elseif gameState == "serve" then
            gameState = "play"
            bola:reset()
        elseif gameState == "done" then
            gameState = "serve"
            bola:reset()
            player1Score = 0
            player2Score = 0
        end
    end
end

function love.update(dt)
    
    if gameState == "serve" then
        bola.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            bola.dx = math.random(10, 100)
        else 
            bola.dx = -math.random(10, 100)
        end
    elseif gameState == "play" then
        if bola:collides(player1) then
            sound['paddle_hit']:play()
            bola.dx = -bola.dx * 1.03
            bola.x = bola.x + 5
            if bola.dy < 0 then
                bola.dy = -math.random(10, 150)
            else
                bola.dy = math.random(10, 150)
            end
        end
        
        if bola:collides(player2) then
            sound['paddle_hit']:play()
            bola.dx = -bola.dx * 1.03
            bola.x = bola.x - 5
            if bola.dy < 0 then
                bola.dy = -math.random(10, 150)
            else
                bola.dy = math.random(10, 150)
            end
        end
        
        if bola.y < 0 then
            sound['wall_hit']:play()
            bola.y = 0
            bola.dy = -bola.dy
        end
        
        if bola.y > VIRTUAL_HEIGHT then
            sound['wall_hit']:play()
            bola.y = VIRTUAL_HEIGHT
            bola.dy = -bola.dy
        end
        
        if bola.x < 0 then
            sound['score']:play()
            servingPlayer = 2
            player2Score = player2Score  + 1
            if player2Score == 2 then
                winner = 2
                gameState = "done"
            else
                bola:reset()
                gameState = "serve"
            end
        end
        
        if bola.x > VIRTUAL_WIDTH then
            sound['score']:play()
            servingPlayer = 2
            player1Score = player1Score  + 1
            if player1Score == 2 then
                winner = 1
                gameState = "done"
            else
                bola:reset()
                gameState = "serve"
            end
        end
        
        bola:update(dt)
    end
    
    -- if gameState == "play" then
    -- end
    
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

    if bola.dx > 0 and bola.x > VIRTUAL_WIDTH / 2 + 70 then
      if bola.y > player2.y + 20 then
        player2.dy = PADDLE_SPEED
      elseif bola.y < player2.y then
        player2.dy = -PADDLE_SPEED
      end
    end

    player1:update(dt)
    player2:update(dt)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(180 / 255, 190 / 255, 254 / 255)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 60, 10)
end

function love.resize(width, height)
  push:resize(width, height)
end

function love.draw()
    push:apply('start')

    love.graphics.clear(30 / 255, 30 / 255, 46 / 255, 255 / 255)

    love.graphics.setColor(180 / 255, 190 / 255, 254 / 255)
    love.graphics.setFont(smallFont)

    displayFPS()

    -- ball starts moving in play state and reset default position in start state
    if gameState == 'start' then
        love.graphics.printf('Press Enter to Begin', 0, 10, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.printf('Player ' .. tostring(servingPlayer) .. ' Serves', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Play', 0, 20, VIRTUAL_WIDTH, 'center')
    -- elseif gameState == "play" then
        
    elseif gameState == "done" then
        love.graphics.printf('Player ' .. tostring(winner) .. ' Wins', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to Start a New Game', 0, 20, VIRTUAL_WIDTH, 'center')
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
