local M = {}
local composer = require "composer"
function M.new(instance)
    if not instance then return false end

    local scene = composer.getScene( composer.getSceneName( "current" ) )

    local x, y = instance.x, instance.y
    local parent = instance.parent
    instance:removeSelf()

    local sheet =
    {
        frames = {
            
        },
        sheetContentWidth = 128,
        sheetContentHeight = 32
    }
    for i = 1, 8 do
        sheet.frames[i] = {
            x = 0 + (16 * (i-1)),
            y = 0,
            width = 16,
            height = 32
        }
    end
    local sheet = graphics.newImageSheet("res/objects/fire.png", sheet)
    local sequence = {
        {
            name = "idle",
            frames = {1},
            -- count = 10,
            -- time = 500,
            -- loopDirection = "forward",
            loopCount = 0
        },
        {
            name = "active",
            frames = {2, 3, 4, 5},
            time = 200,
            loopDirection = "forward",
            loopCount = 1
        },
        {
            name = "fire",
            frames = {6, 7, 8},
            time = 200,
            loopDirection = "forward",
            loopCount = 0
        },
        {
            name = "fire_off",
            frames = {8, 7, 6, 5, 1},
            time = 200,
            loopDirection = "forward",
            loopCount = 1
        }
    }

    instance = display.newSprite(parent, sheet, sequence)
    instance.x, instance.y = x, y
    instance.fireCollider = display.newRect(parent, instance.x, instance.y, instance.width/2, instance.height/2)
    instance.fireCollider.anchorY = 1
    instance.fireCollider.alpha = 0.01
    instance.fireCollider.bodyActive = false
    local fireCollider = instance.fireCollider
   
    function fireCollider:collision(event)
        local phase = event.phase
        local other = event.other

        if phase == "began" then
            if other.name == "hero" then
                if instance.isActive then
                    other:die()
                end
            end
        end
    end

    function instance:collision(event)
        local phase = event.phase
        local other = event.other

        if phase == "began" then
            if other.name == "hero" then
                if not instance.isActive then
                    instance:setSequence("active")
                    instance:play()
                    instance.isActive = true
                    timer.performWithDelay(500, function()
                        physics.addBody(fireCollider, "static", { isSensor = true })
                        fireCollider:addEventListener("collision")
                        if scene.lightSystem then 
                            fireCollider.lightId = scene.lightSystem:addLight(fireCollider, 50)
                        end
                        instance:setSequence("fire")
                        instance:play()
                        timer.performWithDelay(1000, function()
                            fireCollider:removeEventListener("collision")
                            instance:setSequence("fire_off")
                            instance:play()
                            instance.isActive = false
                            if scene.lightSystem then 
                                scene.lightSystem:removeLight(fireCollider.lightId)
                            end
                        end, 1)
                    end, 1)
                end
            end
        end
    end

    physics.addBody(instance, "static", {box = {x = 0, y = 0 + instance.height/4, halfWidth = instance.width/2, halfHeight = instance.height/4}})

    instance.type = "fire"

    instance:addEventListener("collision")
    return instance
end

return M