-- Luke Scowen
-- 11045221
-- XO Buddies Final Project

display.setStatusBar( display.HiddenStatusBar )
native.setProperty( "androidSystemUiVisibility", "immersive" )

-- Include some libs.
local composer = require "composer"

-- Go to the first scene.
composer.gotoScene( "menu", {effect = "fade", time = 400} )