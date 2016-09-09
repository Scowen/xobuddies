local composer = require( "composer" )
local scene = composer.newScene()

local backBox

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
    match = 0

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

    local txtLiveMatches = display.newText( "LIVE MATCHES", header.width / 2, header.y + (header.height / 2), "Arial Rounded MT Bold", 72 )
    sceneGroup:insert( txtLiveMatches )
    txtLiveMatches:setFillColor( 0, 0, 0 )

    -- Add the box that will support the games.

end

function scene:show( event )
   
    local phase = event.phase
   
    if "did" == phase then
        -- Get all the games being played by the user.

        -- Add each game to the scrollable window.

        -- Touch and drag listeners required for scrolling.

        -- Tap listeners required to select a match.

        -- Add event listeners.
        backBox:addEventListener( "tap", onEventTap )
    end
   
end

function scene:hide( event )
   
    local phase = event.phase
   
    if "will" == phase then
        
        -- Remove event listeners.
        backBox:removeEventListener( "tap", backBox )
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