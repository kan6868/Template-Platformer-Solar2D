local M = {}

function M.new(instance)
    
    local name = instance.name
    physics.addBody(instance, "kinematic", {bounce = 0})
    instance.isMove = true
    instance.isFixedRotation = true
    instance.time = instance.time or 3
    instance.velocity = instance.distance/instance.time

    if name == "leftright" then
        instance.direction = "leftright"
        instance.minX = instance.x
        instance.maxX = instance.minX + instance.distance
        -- instance.friction = 0.4
        -- print("Velocity "..instance.velocity)
    elseif name == "topdown" then
        instance.direction = "topdown"
        instance.minY = instance.y
        instance.maxY = instance.minY - instance.distance
    end

    instance.enterFrame = function ()
        instance.vx, instance.vy = instance:getLinearVelocity()
        -- print(instance.vx, instance.vy)
        if instance.isMove then 
            if instance.direction == "leftright" then
                if instance.x < instance.maxX then
                    instance:setLinearVelocity(instance.velocity, 0)
                else
                    instance.isMove = false
                end
            elseif instance.direction == "topdown" then
                if instance.y > instance.maxY then
                    instance:setLinearVelocity(0, -instance.velocity)
                    
                else
                    instance.isMove = false
                end
            end
        else
            if instance.direction == "leftright" then
                if instance.x > instance.minX then
                    instance:setLinearVelocity(-instance.velocity, 0)
                else
                    instance.isMove = true
                end
            elseif instance.direction == "topdown" then
                if instance.y < instance.minY then
                    instance:setLinearVelocity(0, instance.velocity)
                else
                    instance.isMove = true
                end
            end
        end
    end

    function instance:finalize()
        enterframe_remove(instance.enterFrame)
    end

    instance:addEventListener("finalize")

    enterframe_add(instance.enterFrame)
    
    instance.name = "flyplatform"
    instance.type = "ground"

end

return M