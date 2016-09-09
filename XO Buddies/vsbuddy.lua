local composer = require( "composer" )
local scene = composer.newScene()

local backBox, inputSearch, btnSearch

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

    local txtVsBuddy = display.newText( "vs. BUDDY!", header.width / 2, header.y + (header.height / 2), "Arial Rounded MT Bold", 72 )
    sceneGroup:insert( txtVsBuddy )
    txtVsBuddy:setFillColor( 0, 0, 0 )

    -- Add a text box input with the arial rounded MT font.
    inputSearch = native.newTextField( display.contentWidth / 2, header.y + header.height + 140 + (header.height / 8), display.contentWidth - (display.contentWidth / 8), display.contentHeight / 12 )
    inputSearch.placeholder = "Enter a Username..."
    inputSearch.isEditable = true
    inputSearch.font = native.newFont( "Arial Rounded MT Bold", 24, 18 )
    inputSearch.hasBackground = false
    sceneGroup:insert( inputSearch )

    -- Add a go button.
    btnSearch = display.newRect( display.contentWidth / 2, inputSearch.y + inputSearch.height + (inputSearch.height / 3), display.contentWidth - (display.contentWidth / 8), display.contentHeight / 12 )
    btnSearch:setFillColor( 233/255, 223/255, 153/255 )
    btnSearch.strokeWidth = 10
    btnSearch:setStrokeColor( 216/255, 171/255, 101/255 )
    sceneGroup:insert( btnSearch )

    local btnSearchText = display.newText( "PLAY!", btnSearch.x, btnSearch.y, "Arial Rounded MT Bold", 72 )
    btnSearchText:setFillColor( 0, 0, 0 )
    sceneGroup:insert( btnSearchText )

    -- Init a keyboard.
    native.setKeyboardFocus( inputSearch )
end

function scene:show( event )
   
    local phase = event.phase
   
    if "did" == phase then
        -- Make sure the text field is on screen.
        inputSearch.x = display.contentWidth / 2

        -- Make the search field focused upon show.
        native.setKeyboardFocus( inputSearch )

        -- When the go button is pressed, search for the user with the username given.

        -- With the user, send a push notification to start the game.

        -- Move to the game screen.

        -- Add event listeners.
        backBox:addEventListener( "tap", onEventTap )
    end
   
end

function scene:hide( event )
   
    local phase = event.phase
   
    if "will" == phase then
        -- Disable the keyboard.
        native.setKeyboardFocus( nil )

        -- Move the text field off screen as it is a persitent little bugger.
        inputSearch.x = -1000
        
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