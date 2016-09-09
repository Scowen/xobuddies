local composer = require( "composer" )
local scene = composer.newScene()

local btnFindMatch, btnVsBuddy, btnLiveMatches, btnLeaderboard

local function onEventTap( event )
    local options =
    {
        effect = "fromTop",
        time = 400,
    }
    
    if event.target == btnFindMatch then
        composer.gotoScene( "findmatch", options )
    end
    if event.target == btnVsBuddy then
        composer.gotoScene( "vsbuddy", options )
    end
    if event.target == btnLiveMatches then
        composer.gotoScene( "livematches", options )
    end
    if event.target == btnLeaderboard then
        composer.gotoScene( "leaderboard", options )
    end
    return true
end

-- Called when the scene's view does not exist:
function scene:create( event )
    local sceneGroup = self.view

    local background = display.newImage( "images/menu/background.png", 0, 0, true )
    sceneGroup:insert( background )
    background:scale( 2, 2 )
   
    -- Import the logo, this will only be displayed on the main menu.
    local logo = display.newImage( "images/menu/logo.png", display.contentCenterX, display.pixelHeight / 11, true )
    logo.anchorY = 0
    sceneGroup:insert( logo )

    -- Import the buttons.
    local btnPosY = logo.y + logo.height + 200 -- Where on the Y Axis the buttons should be placed.
    local btnGap = 200       -- The Gap in pixels between the buttons.
    btnFindMatch = display.newImage( "images/menu/findmatch.png", display.contentCenterX, btnPosY + ( btnGap * 0 ), true )
    sceneGroup:insert( btnFindMatch )

    btnVsBuddy = display.newImage( "images/menu/vsbuddy.png", display.contentCenterX, btnPosY + ( btnGap * 1 ), true )
    sceneGroup:insert( btnVsBuddy )

    btnLiveMatches = display.newImage( "images/menu/livematches.png", display.contentCenterX, btnPosY + ( btnGap * 2 ), true )
    sceneGroup:insert( btnLiveMatches )

    btnLeaderboard = display.newImage( "images/menu/leaderboard.png", display.contentCenterX, btnPosY + ( btnGap * 3 ), true )
    sceneGroup:insert( btnLeaderboard )

    -- Display the current user's username.
    local txtUsername = display.newText( "Username", display.contentCenterX, btnPosY + ( btnGap * 3.86 ), "Arial Rounded MT Bold", 72 )
    sceneGroup:insert( txtUsername )
    txtUsername:setFillColor( 0, 0, 0 )
    -- And finally, display their rating.
    local txtRating = display.newText( "1337", display.contentCenterX, btnPosY + ( btnGap * 4.36 ), "Arial Rounded MT Bold", 68 )
    sceneGroup:insert( txtRating )
    txtRating:setFillColor( 1, 1, 1 )
end

function scene:show( event )
   
    local phase = event.phase
   
    if "did" == phase then
        btnFindMatch:addEventListener( "tap", onEventTap )
        btnVsBuddy:addEventListener( "tap", onEventTap )
        btnLiveMatches:addEventListener( "tap", onEventTap )
        btnLeaderboard:addEventListener( "tap", onEventTap )
    end
   
end

function scene:hide( event )
   
    local phase = event.phase
   
    if "will" == phase then
        btnFindMatch:removeEventListener( "tap", btnFindMatch )
        btnVsBuddy:removeEventListener( "tap", btnVsBuddy )
        btnLiveMatches:removeEventListener( "tap", btnLiveMatches )
        btnLeaderboard:removeEventListener( "tap", btnLeaderboard )
    end
   
end

function scene:destroy( event )
    print "MENU: Destroy Scene"
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene