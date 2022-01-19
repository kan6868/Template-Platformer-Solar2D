local M = {}
local composer = require "composer"
function M.new(instance)
    local scene = composer.getScene( composer.getSceneName( "current" ) )

    physics.addBody( instance, "static", {isSensor = true})

    function instance:collision(event)
        local phase = event.phase
        local other = event.other

        if phase == "began" then
            if other.name == "hero" then
                if instance.name == "zoom" then
                    scene.world:pointScale(0.85, other, true, 1000)
                    print("zoom is enabled")
                end
            end
        end

    end
    
    instance.alpha = 0.01

    instance:addEventListener("collision")
    
    return instance
end

return M