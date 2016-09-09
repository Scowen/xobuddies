local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )
local scale = 0.32

local loadingIcon, backBox, match, xoGrid, txtTurn, sceneGroup
local pulse = 35
local pulseScale = 1
local pulseSizeFlip = false
local pulseTimer
local circles = {}

local clientID, roomID

local p1, p2, p1wins, p2wins, turn

local gameListenTimer

local function onEventTap( event )  
    if event.target == backBox then
        composer.gotoScene( "menu", {effect = "fromLeft", time = 400} )
    end
    for i=0, 2 do
        for j=0, 2 do
            if event.target == circles[i][j][0] then
                sendMove( i, j ) 
            end
        end
    end
    return true
end

-- Called when the scene's view does not exist:
function scene:create( event )
    sceneGroup = self.view

    -- Changes these when testing is finished
    if event.params ~= null then
        clientID = event.params.clientID
        roomID = event.params.roomID
    else
        clientID = 1
        roomID = 1
    end

    local background = display.newImage( "images/game/background.png", 0, 0, true )
    sceneGroup:insert( background )
    background:scale( 2,2 )

    -- Add the header bar at the top.
    local header = display.newRect( 0, 0, display.contentWidth, 170 )
    header.anchorX = 0
    header.anchorY = 0
    -- Use 233/255 to get the Scalar vector colour using standard RGB values.
    header:setFillColor( 233/255, 223/255, 154/255 )
    sceneGroup:insert( header )

    -- Give the header bar a bottom border.
    local headerBorder = display.newRect( header.x, header.y + header.height, header.width, 9 )
    headerBorder.anchorX = 0
    headerBorder.anchorY = 0
    headerBorder:setFillColor( 216/255, 171/255, 101/255 )
    sceneGroup:insert( headerBorder )

    -- Add the back box.
    backBox = display.newRect( header.x, header.y, header.height, header.height )
    backBox.anchorX = 0
    backBox.anchorY = 0
    backBox:setFillColor( 243/255, 235/255, 183/255 )
    sceneGroup:insert( backBox )

    -- Add the back chevron to the back button.
    local chevron = display.newImage( "images/finding/chevron.png", backBox.x + (backBox.width / 2), backBox.y + (backBox.height / 2), true )
    sceneGroup:insert( chevron )

    -- Now for the scene specific elements.
    -- First the box that will hold the actual game.
    local gameBox = display.newRect( display.contentCenterX , header.y + header.height + 80, 900, 900 ) 
    gameBox.anchorY = 0
    gameBox:setFillColor( 90/255, 90/255, 90/255, 0.24 )
    sceneGroup:insert( gameBox )

    -- Next, is the grid to hold the points.
    xoGrid = display.newImage( "images/game/grid.png", gameBox.x , gameBox.y + (gameBox.height / 2), true )
    sceneGroup:insert( xoGrid )

    -- Draw the status box at the bottom.
    local statusBox = display.newRect( 0, gameBox.y + gameBox.height + 80, display.contentWidth, display.contentHeight - (gameBox.y + gameBox.height + 80) )
    statusBox.anchorX = 0
    statusBox.anchorY = 0
    statusBox:setFillColor( 233/255, 223/255, 154/255 )
    sceneGroup:insert( statusBox )

    -- Give the status box a top border.
    local statusBoxBorder = display.newRect( statusBox.x, statusBox.y, statusBox.width, 9 )
    statusBoxBorder.anchorX = 0
    statusBoxBorder.anchorY = 0
    statusBoxBorder:setFillColor( 216/255, 171/255, 101/255 )
    sceneGroup:insert( statusBoxBorder )

    -- Add some placeholder text for the status bar
    txtTurn = display.newText( "YOUR TURN", statusBox.width / 2, statusBox.y + (statusBox.height / 2), "Arial Rounded MT Bold", 140 )
    sceneGroup:insert( txtTurn )
    txtTurn:setFillColor( 61/255, 132/255, 182/255 )

    -- Set up the circle inputs.
    for i=0, 2 do
        circles[i] = {}
        for j=0, 2 do
            circles[i][j] = {}
            circles[i][j][0] = display.newCircle( (xoGrid.x - 250) + (250 * i), (xoGrid.y - 250) + (250 * j), 35 )
            circles[i][j][0]:setFillColor( 94/255, 179/255, 88/255 )
            sceneGroup:insert( circles[i][j][0] )
            circles[i][j][1] = 0
        end
    end

end

local function getMovesResult( event )
    if event.isError then
        print "CONNECTION ERROR"
    else
        print "CONNECTION SUCCESSFUL"
        -- Json decode the response to be readable as a table/array.
        local decoded, pos, msg = json.decode( event.response )
        if not decoded then
            print( "Decode failed at " .. tostring(pos) .. ": " .. tostring(msg) )
        else
            print "Decode of string complete"

            print "Updating grid with new moves"

            -- Get the results of the points.
            if decoded.p00 then circles[0][0][1] = tonumber(decoded.p00) end
            if decoded.p01 then circles[0][1][1] = tonumber(decoded.p01) end
            if decoded.p02 then circles[0][2][1] = tonumber(decoded.p02) end

            if decoded.p10 then circles[1][0][1] = tonumber(decoded.p10) end
            if decoded.p11 then circles[1][1][1] = tonumber(decoded.p11) end
            if decoded.p12 then circles[1][2][1] = tonumber(decoded.p12) end

            if decoded.p10 then circles[2][0][1] = tonumber(decoded.p20) end
            if decoded.p11 then circles[2][1][1] = tonumber(decoded.p21) end
            if decoded.p12 then circles[2][2][1] = tonumber(decoded.p22) end

            -- Update the grid according to the results.
            for i=0, 2 do
                for j=0, 2 do
                    local xPos = (xoGrid.x - 250) + (250 * i)
                    local yPos = (xoGrid.y - 250) + (250 * j)
                    local player = circles[i][j][1]
                    print ("X: " .. i .. " Y:" .. j .. " Player:" .. player)
                    circles[i][j][0].alpha = 0
                    if player == 0 then
                        circles[i][j][0] = display.newCircle( xPos, yPos, 35 )
                        circles[i][j][0]:setFillColor( 94/255, 179/255, 88/255 )
                        circles[i][j][0]:addEventListener( "tap", onEventTap )
                    elseif player == 1 then 
                        circles[i][j][0] = display.newText( "X", xPos, yPos, "Arial Rounded MT Bold", 140 )
                        circles[i][j][0]:setFillColor( 61/255, 132/255, 182/255 )
                    elseif player == 2 then
                        circles[i][j][0] = display.newText( "O", xPos, yPos, "Arial Rounded MT Bold", 140 )
                        circles[i][j][0]:setFillColor( 203/255, 75/255, 75/255 )
                    end
                    circles[i][j][0].alpha = 1
                    sceneGroup:insert( circles[i][j][0] )
                end
            end

            -- Flip the turn.
            if turn == 1 then turn = 2 else turn = 1 end

            -- Pause the timer.
            if gameListenTimer then 
                timer.pause(gameListenTimer) 
            end 

            -- Return to the game loop.
            startGameLoop()

        end
    end
end

local function gameListenResult( event )
    if event.isError then
        print "CONNECTION ERROR"
    else
        print "CONNECTION SUCCESSFUL"
        -- Json decode the response to be readable as a table/array.
        local decoded, pos, msg = json.decode( event.response )
        if not decoded then
            print( "Decode failed at " .. tostring(pos) .. ": " .. tostring(msg) )
        else
            print "Decode of string complete"

            local resultTurn
            if decoded.turn then resultTurn = tonumber(decoded.turn) end

            -- The turn returned from the request has changed, therefore the move has been completed.
            -- Update the grid and swap the turns around.
            if turn ~= resultTurn then 
                -- Get the moves and update the grid according to the response.
                network.request( "http://xobuddies.noscosystems.com/moves.php?room=" .. roomID, "GET", getMovesResult )
                -- Pause the timer.
                if gameListenTimer then 
                    timer.pause(gameListenTimer) 
                end 
            end
        end
    end
end

local function gameListen( event ) 
    network.request( "http://xobuddies.noscosystems.com/room.php?room=" .. roomID, "GET", gameListenResult )
end

function startGameLoop()
    -- Dependant on who's turn it is, perform the actions required.
    if ( ( p1 == clientID and turn == 1 ) or ( p2 == clientID and turn == 2) ) then
        -- Change the text to YOUR TURN if not already.
        txtTurn.text = "YOUR TURN"
        txtTurn:setFillColor( 61/255, 132/255, 182/255 )

        -- Allow the green dots to pulsate, meaning the player can make their turn.
        for i=0, 2 do
            for j=0, 2 do
                if circles[i][j][1] == 0 then
                    circles[i][j][0].alpha = 1
                end
            end
        end
    else 
        txtTurn.text = "THEIR TURN"
        txtTurn:setFillColor( 203/255, 75/255, 75/255 )

        -- Hide the green entry dots.
        for i=0, 2 do
            for j=0, 2 do
                if circles[i][j][1] == 0 then
                    circles[i][j][0].alpha = 0
                end
            end
        end

        -- Begin to listen for the other players move.
        if gameListenTimer == null then
            gameListenTimer = timer.performWithDelay( 3500, gameListen, 0 )
        else
            timer.resume( gameListenTimer ) 
        end
    end
end
 
local function updateGrid( x, y, player )
    local xPos = (xoGrid.x - 250) + (250 * x)
    local yPos = (xoGrid.y - 250) + (250 * y)
    circles[x][y][0].alpha = 0
    if player == 0 then
        circles[x][y][0] = display.newCircle( xPos, yPos, 35 )
        circles[i][j][0]:setFillColor( 94/255, 179/255, 88/255 )
        circles[i][j][0]:addEventListener( "tap", onEventTap )
    elseif player == 1 then 
        circles[x][y][0] = display.newText( "X", xPos, yPos, "Arial Rounded MT Bold", 140 )
        circles[x][y][0]:setFillColor( 61/255, 132/255, 182/255 )
    elseif player == 2 then
        circles[x][y][0] = display.newText( "O", xPos, yPos, "Arial Rounded MT Bold", 140 )
        circles[x][y][0]:setFillColor( 203/255, 75/255, 75/255 )
    end
    circles[x][y][0].alpha = 1
    sceneGroup:insert( circles[x][y][0] )
    -- Change the value of the grid pos to be the player.
    circles[x][y][1] = player

    if turn == 1 then turn = 2 else turn = 1 end

    -- Go back to the game loop.
    startGameLoop()
end
 
local function moveComplete( event )
    -- Handle the network request for when the move has completed.
    if event.isError then
        print "CONNECTION ERROR"
    else
        print "CONNECTION SUCCESSFUL"
        -- Json decode the response to be readable as a table/array.
        local decoded, pos, msg = json.decode( event.response )
        if not decoded then
            print( "Decode failed at " .. tostring(pos) .. ": " .. tostring(msg) )
        else
            print "Decode of string complete"

            local moveRoom, movePlayer, moveX, moveY
            local success = false

            if decoded.room then moveRoom = tonumber(decoded.room) end
            if decoded.player then movePlayer = tonumber(decoded.player) end
            if decoded.x then moveX = tonumber(decoded.x) end
            if decoded.y then moveY = tonumber(decoded.y) end
            if decoded.success then success = decoded.success end

            if success == true then
                print "Move Completed Successfully" 
                print ( moveRoom, movePlayer, moveX, moveY )
                -- updateGrid( moveX, moveY, player )
            else 
                local errorCode = "0"
                if decoded.error then errorCode = tonumber(decoded.error) end
                print ( "Move Incomplete, Error Code: " .. errorCode )
                updateGrid( moveX, moveY, 0 )
            end
        end
    end
end

function sendMove( x, y )
    print ("Pressed: " .. x .. "," .. y )

    -- First, check client side that it is infact the players turn.
    if ( ( p1 == clientID and turn == 1 ) or ( p2 == clientID and turn == 2) ) then
        local player = 0
        if p1 == clientID then player = 1 else player = 2 end
        -- If it is the players turn, send a request to the server regarding the room, x and y.
        network.request( "http://xobuddies.noscosystems.com/move.php?room=" .. roomID .. "&player=" .. player .. "&x=" .. x .. "&y=" .. y, "GET", moveComplete )
        
        updateGrid( x, y, player )
    end
end

local function pulsate( event )
    -- Make the green circles pulsate, or give the illusion of.
    if pulseSizeFlip == false then
        pulseScale = pulseScale - 0.025
        if pulseScale <= 0.8 then pulseSizeFlip = true end
    else 
        pulseScale = pulseScale + 0.025
        if pulseScale >= 1.2 then pulseSizeFlip = false end
    end
    for i=0, 2 do
        for j=0, 2 do
            if circles[i][j][1] == 0 then
                circles[i][j][0].xScale = pulseScale
                circles[i][j][0].yScale = pulseScale
            end
        end
    end
end

local function getRoomInformation( event )
    if event.isError then
        print "CONNECTION ERROR"
    else
        print "CONNECTION SUCCESSFUL"
        -- Json decode the response to be readable as a table/array.
        local decoded, pos, msg = json.decode( event.response )
        if not decoded then
            print( "Decode failed at " .. tostring(pos) .. ": " .. tostring(msg) )
        else
            print "Decode of string complete"

            if decoded.p1 then p1 = tonumber(decoded.p1) end
            if decoded.p2 then p2 = tonumber(decoded.p2) end
            if decoded.p1wins then p1wins = tonumber(decoded.p1wins) end
            if decoded.p2wins then p2wins = tonumber(decoded.p2wins) end
            if decoded.turn then turn = tonumber(decoded.turn) end

            print "Game information retrieved" 
            print ( p1, p2, p1wins, p2wins, turn )

            startGameLoop()
        end
    end
end

function scene:show( event )
   
    local phase = event.phase
   
    if "did" == phase then
        if pulseTimer == null then
            pulseTimer = timer.performWithDelay( 1, pulsate, 0 )
        else
            timer.resume( pulseTimer ) 
        end

        -- Get the rooms moves.
        network.request( "http://xobuddies.noscosystems.com/moves.php?room=" .. roomID, "GET", getMovesResult )

        -- Get the room information
        network.request( "http://xobuddies.noscosystems.com/room.php?room=" .. roomID, "GET", getRoomInformation )

        -- Add event listeners.
        for i=0, 2 do
            for j=0, 2 do
                circles[i][j][0]:addEventListener( "tap", onEventTap )
            end
        end
        backBox:addEventListener( "tap", onEventTap )
    end
   
end

function scene:hide( event )
   
    local phase = event.phase
   
    if "will" == phase then
        if pulseTimer then 
            timer.pause(pulseTimer) 
        end
        if gameListenTimer then 
            timer.pause(gameListenTimer) 
        end

        -- Remove event listeners.
        for i=0, 2 do
            for j=0, 2 do
                circles[i][j][0]:removeEventListener( "tap", onEventTap )
            end
        end
        backBox:removeEventListener( "tap", backBox )
    end
   
end

function scene:destroy( event )
    print( "( ( destroying scene 1's view ) )" )
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene