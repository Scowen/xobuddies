local composer = require( "composer" )
local scene = composer.newScene()
local json = require( "json" )

local loadingIcon, backBox, txtFindingMatch, findMatchTimer, match, networkRequestTimer
local clientID
local roomID

local function onEventTap( event )   
    if event.target == backBox then
        composer.gotoScene( "menu", {effect = "fromLeft", time = 400} )
    end
    return true
end

-- Called when the scene's view does not exist:
function scene:create( event )
    local sceneGroup = self.view

    findMatch = null
    findMatchTimer = null
    networkRequestTimer = null
    match = 0
    clientID = 0
    roomID = 0

    local path = system.pathForFile( "xobclientid.txt", system.DocumentsDirectory )

    local file = io.open( path, "r" )
    if file then
        local savedData = file:read( "*a" )

        io.close( file )
        file = nil

        if not savedData then
            clientID = tonumber(savedData)
            print ( "Client ID found. " .. clientID )
        end
    end

    local background = display.newImage( "images/finding/background.png", 0, 0, true )
    sceneGroup:insert( background )
    background:scale( 2, 2 )

    -- Add the header bar at the top.
    local header = display.newRect( 0, 0, display.contentWidth, 170 )
    header.anchorX = 0
    header.anchorY = 0
    -- Use 233/255 to get the Scalar vector colour using standard RGB values.
    header:setFillColor( 233/255, 223/255, 154/255 )
    sceneGroup:insert( header )

    -- Give the header bar a bottom border.
    local headerBorder = display.newRect( header.x, header.y + header.height, header.width, 7 )
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

    -- Display the current user's username.
    txtFindingMatch = display.newText( "FINDING MATCH", display.contentCenterX, display.contentCenterY - 300, "Arial Rounded MT Bold", 72 )
    sceneGroup:insert( txtFindingMatch )
    txtFindingMatch:setFillColor( 0, 0, 0 )

    -- Display the loading icon.
    loadingIcon = display.newImage( "images/finding/loading.png", display.contentCenterX, display.contentCenterY, true )
    sceneGroup:insert( loadingIcon )
end

local function findMatch( event )
    -- Rotate the loading icon to give the impression of something happening to the user.
    loadingIcon.rotation = loadingIcon.rotation + 6
    if loadingIcon.rotation >= 360 then loadingIcon.rotation = 0 end
end

local function networkListener( event )
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

            local full = false

            if decoded.user then
                clientID = tonumber(decoded.user)
            end
            if decoded.room then
                roomID = tonumber(decoded.room)
            end
            if decoded.full then
                full = decoded.full
            end

            print "Client ID received, saving Client ID to device"
            -- Save the client ID to the device for future use.
            local saveData = tostring(clientID)

            local path = system.pathForFile( "xobclientid.txt", system.DocumentsDirectory )

            local file = io.open( path, "w" )
            file:write( saveData )

            io.close( file )
            file = nil

            if clientID > 0 and roomID > 0 and full == true then
                -- Now advance to game window.
                print "Game found, advancing to game window"
                timer.pause(findMatchTimer)
                timer.pause(networkRequestTimer) 
                composer.gotoScene( "game", {effect = "fromTop", time = 400, params = { clientID = clientID, roomID = roomID } } )
            end

            print "Game not ready, waiting for player to join room"
        end
    end
end

local function networkRequest( event )
    -- Send a request to the server, the networkListener function will handle the response.
    -- Nosco Systems is the company I work for, I am allowed to host a sub domain containing my server software.
    network.request( "http://xobuddies.noscosystems.com/find.php?user=" .. clientID, "GET", networkListener )
end

function scene:show( event )
   
    local phase = event.phase
   
    if "did" == phase then
        -- If the timer is already running, then resume.
        if findMatchTimer == null then
            -- Start to find a match.
            findMatchTimer = timer.performWithDelay( 1, findMatch, 0 )
        else
            timer.resume( findMatchTimer ) 
        end

        -- Every 5 seconds, the client needs to send a ping request to the server, asking if anyone is available to play against.
        -- This can be achieved using the performWithDelay command.
        if networkRequestTimer == null then
            -- Start to find a match.
            networkRequestTimer = timer.performWithDelay( 5000, networkRequest, 0 )
        else
            timer.resume( networkRequestTimer ) 
        end

        -- Go to the game window.
        -- composer.gotoScene( "game", {effect = "fromRight", time = 400} )

        -- Add event listeners.
        backBox:addEventListener( "tap", onEventTap )
        -- TEMP: Just to get to the game screen via nav for now.
        loadingIcon:addEventListener( "tap", onEventTap )
    end
   
end

function scene:hide( event )
   
    local phase = event.phase
   
    if "will" == phase then
        -- If the findMatchTimer source is valid.
        if findMatchTimer then 
            timer.pause(findMatchTimer) 
        end

        if networkRequestTimer then 
            timer.pause(networkRequestTimer) 
        end
        
        -- Remove event listeners.
        backBox:removeEventListener( "tap", backBox )
        -- TEMP: Just to get to the game screen via nav for now.
        loadingIcon:removeEventListener( "tap", loadingIcon )
    end
   
end

function scene:destroy( event )
    print "FIND: Destroy Scene"
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene