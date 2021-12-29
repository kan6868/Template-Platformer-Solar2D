math.randomseed(os.time())
display.setStatusBar(display.HiddenStatusBar)

system.activate( "multitouch" )

-- The default magnification sampling filter applied whenever an image is loaded by Corona.
-- Use "nearest" with a small content size to get a retro-pixel look
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "linear")
display.setDefault( "isImageSheetSampledInsideFrame", true )

require "scripts.service.global_functions"
-- Global table for systemwide objects and config
_GB = {}
_GB.timers = {}
_GB.enterframe_listeners = {}

-- Load all game libraries
_GB.audio = audio
_GB.composer = require('composer')


_GB.cx, _GB.cy      = display.contentCenterX, display.contentCenterY
_GB.w, _GB.h        = display.safeActualContentWidth, display.safeActualContentHeight
_GB.cw, _GB.ch      = display.contentWidth, display.contentHeight
_GB.ox, _GB.oy      = display.safeScreenOriginX, display.safeScreenOriginY

_GB.top             = _GB.oy
_GB.bottom          = _GB.top + _GB.h
_GB.left            = _GB.ox
_GB.right           = _GB.left + _GB.w

_GB.aspectRatio     = display.pixelHeight / display.pixelWidth

_GB.font = {"res/fonts/04B_03__.TTF"}


_GB.composer.recycleOnSceneChange = true

local isAndroid = false
-- Initialize keys for advertisement and leaderboard services
local platform = system.getInfo('platform')

if platform == "android" then
    isAndroid = true
end

-- Removes bottom bar on Android
if isAndroid then
    if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
      native.setProperty( "androidSystemUiVisibility", "lowProfile" )
    else
      native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
    end
  end

_GB.composer.gotoScene("scenes.start")