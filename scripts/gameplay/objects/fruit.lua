local M = {}
local composer = require "composer"
function M.new(instance)

    physics.addBody(instance, "static", {radius = 8, isSensor = true})
    local scene = composer.getScene( composer.getSceneName( "current" ) )
    local sheet =
    {
        frames = {
            
        },
        sheetContentWidth = 192+32,
        sheetContentHeight = 32
    }
    for i = 1, 7 do
        sheet.frames[i] = 
        {
            x = 1 + (32 * (i-1)),
            y = 1,
            width = 32,
            height = 32
        }
    end

    local imgsheet = graphics.newImageSheet("res/effects/Collected.png", sheet)

    local sequence = {
        {
            name = "collected",
            frames = {1, 2, 3, 4, 5, 6, 7},
            time = 300,
            loopDirection = "forward",
            loopCount = 1
        },
        {
            name = "hide",
            frames = {7}
        }
    }



    instance.collision = function (event)
        local phase = event.phase
     
        scene.questlog:collect(instance.name)
        instance:collectedEffect()
        instance:destroy()
    end
    
    function instance:finalize()
        self:removeEventListener("collision")
    end

    function instance:destroy()
        self:finalize()
        self:removeSelf()
        self = nil
    end

    function instance:collectedEffect()
        instance.effect = display.newSprite(instance.parent, imgsheet, sequence)
        instance.effect.x, instance.effect.y = instance.x, instance.y
        instance.effect:setSequence("collected")
        instance.effect:play()
    end
    instance:addEventListener("finalize")
    instance:addEventListener("collision")

    return instance
end
return M