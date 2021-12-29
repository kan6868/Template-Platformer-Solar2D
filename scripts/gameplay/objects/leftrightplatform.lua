local M = {}

function M.new(instance)

    
    physics.addBody(instance, "kinematic", {bounce = 0})
    local size = 16
    print("left right")
    instance.minX = instance.x
    instance.maxX = instance.minX + instance.distance

    instance.isMove = true
    instance.isFixedRotation = true
    instance.time = instance.time or 3
    instance.velocity = instance.distance/instance.time
    -- instance.friction = 0.4
    -- print("Velocity "..instance.velocity)

    instance.enterFrame = function ()
        instance.vx, instance.vy = instance:getLinearVelocity()
        -- print(instance.vx, instance.vy)
        if instance.isMove then 
            if instance.x < instance.maxX then
                instance:setLinearVelocity(instance.velocity, 0)
            else
                instance.isMove = false
            end
        else
            if instance.x > instance.minX then
                instance:setLinearVelocity(-instance.velocity, 0)
            else
                instance.isMove = true
            end
        end
    end
    function instance:finalize()
        enterframe_remove(instance.enterFrame)
    end
    instance:addEventListener("finalize")
    -- instance.move()
    enterframe_add(instance.enterFrame)
    instance.name = "flyplatform"
    instance.direction = "left2right"
    instance.type = "ground"
end

return M