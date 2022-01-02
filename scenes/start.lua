local background = require "scripts.interface.background"

local scene = _GB.composer.newScene()

local guiGroup
local title, btnStart

-- create()
function scene:create( event )
 
    local sceneGroup = self.view
    sceneGroup.background = display.newGroup()
    sceneGroup.gui = display.newGroup()
    -- sceneGroup.effect = display.newGroup()
    title = display.newImageRect(sceneGroup.gui, "res/screen/mainTitle.png", 215, 120)
    title.x, title.y = _GB.cx, _GB.cy - 50
    
    btnStart = display.newRect(sceneGroup.gui, _GB.cx, _GB.h * 0.7, 200, 40)
    btnStart.lbl = display.newText(sceneGroup.gui, "START", btnStart.x, btnStart.y, _GB.font[1], 20)
    btnStart.lbl:setFillColor(0)
    btnStart.lbl.alpha = 0
    btnStart.isDisable = false
    
    btnStart.touch = function (event)
      if ( event.phase == "began" ) then
        if not btnStart.isDisable then
          btnStart.xScale = .9
          btnStart.yScale = .9
          btnStart:setFillColor(.7, .7, .7)
          btnStart.lbl:setFillColor(1)
        end
          -- Set touch focus
          display.getCurrentStage():setFocus( btnStart )
          btnStart.isFocus = true
      
      elseif ( btnStart.isFocus ) then
          if ( event.phase == "moved" ) then
  
          elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
            if not btnStart.isDisable then
                
                btnStart.xScale = 1
                btnStart.yScale = 1
                btnStart:setFillColor(1, 1, 1)
                btnStart.lbl:setFillColor(0)
                btnStart.isDisable = true
                transition.to(btnStart.lbl, {time = 200, xScale = 0.03, yScale = 0.03, alpha = 0, transition = easing.inExpo, onComplete = function ()
                    screenFadeIn(function ()
                    
                        _GB.composer.gotoScene(
                            "scenes.game", {time = 500, params = {level = 0}}--"tutorial"}}
                        )
                        btnStart:removeEventListener("touch", btnStart.touch)
                    end)
                    transition.to(btnStart, {time = 500, x = - 200, transition = easing.inExpo})
                end})

            end
              -- Reset touch focus
              display.getCurrentStage():setFocus( nil )
              btnStart.isFocus = nil
          end
      end
      return true
    end
    background = background.new()
    
    sceneGroup.background:insert(background)
    sceneGroup:insert(sceneGroup.background)
    sceneGroup:insert(sceneGroup.gui)
end
 
 
-- show()
function scene:show( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
        screenFadeOut(function ()
            btnStart:addEventListener("touch", btnStart.touch)
        end)
        transition.from(btnStart, {time = 800, x = - 200, transition = easing.outExpo, onComplete = function (obj)
            obj.lbl.alpha = 1
            transition.from(obj.lbl, {time = 200, xScale = 0.03, yScale = 0.03, transition = easing.outExpo})
          end})
    elseif ( phase == "did" ) then

    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
    transition.cancelAll()
    elseif ( phase == "did" ) then
        background:destroy()

    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view

end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene