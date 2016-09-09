local composer = require( "composer" )
local scene = composer.newScene()

local loadingIcon, loadingIconTimer

local function onEventTap( event )
    if event.target == loadingIcon then
        composer.gotoScene( "menu", {effect = "crossFade", time = 400} )
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

    -- Display the loading icon.
    loadingIcon = display.newImage( "images/finding/loading.png", display.contentCenterX, display.contentCenterY + (display.contentCenterY / 4), true )
    sceneGroup:insert( loadingIcon )
end

local function rotateLoadingIcon( event )
    -- Rotate the loading icon to give the impression of something happening to the user.
    loadingIcon.rotation = loadingIcon.rotation + 6
    if loadingIcon.rotation >= 360 then loadingIcon.rotation = 0 end
end

function scene:show( event )
   
    local phase = event.phase
    
    if "did" == phase then
        if loadingIconTimer == null then
            -- Start to rotate the loading icon.
            loadingIconTimer = timer.performWithDelay( 1, rotateLoadingIcon, 0 )
        else
            timer.resume( loadingIconTimer ) 
        end

        -- TEMP: Just to get to the game screen via nav for now.
        loadingIcon:addEventListener( "tap", onEventTap )
    end
   
end

function scene:hide( event )
   
    local phase = event.phase
   
    if "will" == phase then
        -- If the loadingIconTimer source is valid.
        if loadingIconTimer then 
            timer.pause(loadingIconTimer) 
        end

        -- Determine if the user is logged in already and if they need to register etc.
    end
   
    -- TEMP: Just to get to the game screen via nav for now.
    loadingIcon:removeEventListener( "tap", loadingIcon )
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