local M = {}

function M.new(props)
    local props = props or {}
    local img = props.img or "res/gui/Buttons/Restart.png"
    local w = props.w or 32
    local h = props.h or 32
    local x = props.x or display.contentCenterX
    local y = props.y or display.contentCenterY
    local anchorX, anchorY = props.anchorX or 0, props.anchorY or 0
    local a1 = props.a1 or 1
    local a2 = props.a2 or .7
    local onTouch = props.onTouch

    local button = display.newImageRect(img, w, h)
    button.x, button.y = x, y
    button.anchorX, button.anchorY = anchorX, anchorY
    button.alpha = a1
    button.onTouch = onTouch

    function button:disable()
        button.isDisable = true
    end

    function button:restart()
        button.isDisable = false
    end

    button.touch = function (event)
        if ( event.phase == "began" ) then
          if not button.isDisable then
            button.xScale = .9
            button.yScale = .9
            button.alpha = a2
          end
            -- Set touch focus
            display.getCurrentStage():setFocus( button, event.id )
            button.isFocus = true
        
        elseif ( button.isFocus ) then
            if ( event.phase == "moved" ) then
    
            elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
              if not button.isDisable then
                button.xScale = 1
                button.yScale = 1
                button.alpha = a1
                button.onTouch()
              end
                -- Reset touch focus
                display.getCurrentStage():setFocus( button, nil )
                button.isFocus = nil
            end
        end
        return true
    end

    function button:active()
        button:restart()
        button:addEventListener("touch", button.touch)
    end

    function button:finalize()
        button:removeEventListener("touch", button.touch)
    end

    button:addEventListener("finalize")
    button:disable()

    return button
end

return M