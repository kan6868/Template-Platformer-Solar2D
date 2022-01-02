local M = {}

function M.new(instance)

    -- local instance = display.newinstance()
    if not instance then return false end
    local x, y = instance.x, instance.y
    local parent = instance.parent
    instance:removeSelf()

    local sheet =
    {
        frames = {
            
        },
        sheetContentWidth = 252,
        sheetContentHeight = 18
    }
    for i = 1, 14 do
        sheet.frames[i] = {
            x = 1 + (18 * (i-1)),
            y = 1,
            width = 18,
            height = 18
        }
    end
    local sheet = graphics.newImageSheet("res/maps/jump_point.png", sheet)
    local sequence = {
        {
            name = "idle",
            start = 1,
            count = 10,
            time = 500,
            -- loopDirection = "forward",
            loopCount = 0
        },
        {
            name = "active",
            frames = {11, 12, 13, 14},
            time = 200,
            loopDirection = "forward",
            loopCount = 1
        }
    }
    instance = display.newSprite(parent, sheet, sequence)
    instance.x, instance.y = x, y

    physics.addBody(instance, "static", {radius = 9, isSensor = true})
    -- instance.gravityScale = 0

    function instance:collision(event)
        local phase = event.phase
        local target = event.target
        local other = event.other
        if phase == "began" then
            if other.name == "hero" then
                instance:active(other)
            end
        end
    end

    function instance:sprite(event)
        if event.phase == "ended" then
            if instance.sequence == "active" then
                instance:removeSelf()
                instance:removeEventListener("sprite")
            end
        end
    end

    function instance:active(target)
        target:setLinearVelocity(0, 0)
        target:applyLinearImpulse(0, -8, self.x, self.y)
        target:chargeSequence("double jump")
        target.canDoubleJump = false

        instance:setSequence("active")
        instance:play()
    end
   
    function instance:finalize()
        instance:removeEventListener("sprite")
        instance:removeEventListener("collision")
    end
    instance:setSequence("idle")
    instance:play()

    instance:addEventListener( "sprite")
    instance:addEventListener( "collision")
    instance:addEventListener("finalize")

    return instance
end

return M