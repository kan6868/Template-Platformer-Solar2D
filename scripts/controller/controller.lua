local button = require "scripts.interface.button"
local M = {}

local composer = _GB.composer
local GB = _GB
function M.new(instance)

    -- Get current scene and parent group
    local group = composer.getScene( composer.getSceneName( "current" ) ).view.frontGroup

    print("create controller")

    local sheet =
    {
        frames = {
            
        },
        sheetContentWidth = 128,
        sheetContentHeight = 144
    }
    for i = 1, 3 do
        sheet.frames[i] = {
            x = 0,
            y = 0 + (48 * (i-1)),
            width = 128,
            height = 48
        }
    end

    local btnArrowSheet = graphics.newImageSheet("res/gui/Buttons/button_arrow.png", sheet)
    
    local sequence = {
        {
            name = "idle",
            frames = {1},
            loopCount = 1
        },
        {
            name = "left",
            frames = {2},
            loopCount = 1
        },
        {
            name = "right",
            frames = {3},
            loopCount = 1
        }
    }
    instance.btnArrow = display.newSprite(group, btnArrowSheet, sequence)
    instance.btnArrow.x, instance.btnArrow.y = GB.ox + 96, GB.bottom - 32
    
    instance.btnArrow.onTouch = function (event)
        local target = event.target
        if ( event.phase == "began" ) then

            if event.x < target.x then
                instance.leftDir = -1
                instance.rightDir = 0
                target:setSequence("left")
                target:play()
            else
                instance.rightDir = 1
                instance.leftDir = 0
                target:setSequence("right")
                target:play()
            end 

           -- Set touch focus
           display.getCurrentStage():setFocus( target, event.id)
           target.isFocus = true
          elseif ( target.isFocus ) then
              if ( event.phase == "moved" ) then

                if event.x < target.x then

                    instance.leftDir = -1
                    instance.rightDir = 0

                    target:setSequence("left")
                    target:play()
                else

                    instance.rightDir = 1
                    instance.leftDir = 0

                    target:setSequence("right")
                    target:play()
                end 

              elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
                instance.leftDir = 0
                instance.rightDir = 0
                target:setSequence("idle")
                target:play()
                  -- Reset touch focus
                  display.getCurrentStage():setFocus( target, nil )
                  target.isFocus = nil
              end
          end
          return true
    end

    instance.btnJump = require "scripts.interface.button".new({
        w = 48,
        h = 48,
        x = GB.right - 64,
        y = GB.bottom - 64,
        a = .5,
        img = "res/gui/Buttons/button_jump.png",
        onTouch=function ()
                    instance:jump()
                end
    })

    instance.btnJump.alpha = 1

    function instance.btnArrow:finalize()
        self:removeEventListener("touch", instance.btnArrow.onTouch)
    end

    instance.btnArrow:addEventListener("finalize") 
    instance.btnArrow:addEventListener("touch", instance.btnArrow.onTouch)
    instance.btnJump:active()
end

return M