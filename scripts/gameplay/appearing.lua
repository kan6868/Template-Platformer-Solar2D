local M = {}

function M.new(instance, options)
    local options = options or {}

    local group = display.newGroup()
    local x, y = instance.x, instance.y

    local sheet =
    {
        frames = {
            
        },
        sheetContentWidth = 672,
        sheetContentHeight = 96
    }
    for i = 1, 6 do
        sheet.frames[i] = {
            x = 0 + (96 * (i-1)),
            y = 0,
            width = 96,
            height = 96
        }
    end
    group.sheet = graphics.newImageSheet("res/effects/Appearing.png", sheet)
    local sequence = {
        {
            name = "appearing",
            frames = {1, 2, 3, 4, 5, 6},
            time = 300,
            loopDirection = "forward",
            loopCount = 1
        }
    }
    group.effect = display.newSprite(group, group.sheet, sequence)
    group.effect.x, group.effect.y = x, y
    
    group.effect.sprite = function (event)
        if event.phase == "ended" then
            transition.to(group.effect, {time = 100, onComplete = function (obj)
                obj:removeSelf()
                obj:removeEventListener("sprite", obj.sprite)
                instance:active()
            end})
        end
    end
    function group:active()
        
        group.effect:addEventListener( "sprite", group.effect.sprite )
        group.effect:play()
    end
   
    function group:finalize()

    end

    group:addEventListener("finalize")
    return group
end

return M