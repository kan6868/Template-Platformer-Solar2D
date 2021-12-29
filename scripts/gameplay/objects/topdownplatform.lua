local M = {}

function M.new(instance)

    physics.addBody(instance, "kinematic", {bounce = 0})
    local size = 16

    -- function instance.move()
    --     instance.onMove = function (obj)
    --         transition.to(instance, {time = 2000, y = instance.y + instance.distance * -1, onComplete = instance.move})    
    --     end
    --     transition.to(instance, {time = 2000, y = instance.y + instance.distance, onComplete = instance.onMove})    
    -- end

    -- if instance.name == "topdown" then
        instance.minY = instance.y
        instance.maxY = instance.minY - instance.distance
    -- elseif instance.name == "leftright" then
    --     instance.move()
    -- end
    instance.isMove = false

    instance.isFixedRotation = true
    instance.time = instance.time or 3
    instance.velocity = instance.distance/instance.time

    instance.enterFrame = function ()
        if instance.isMove then 
            if instance.y > instance.maxY then
                instance:setLinearVelocity(0, -instance.velocity)
            else
                instance.isMove = false
            end
        else
            if instance.y < instance.minY then
                instance:setLinearVelocity(0, instance.velocity)
            else
                instance.isMove = true
            end
        end
    end
    instance.collision = function (event)
   
        local phase = event.phase
        local other = event.other
        local target = event.target
        if phase == "began" then
            if other.name == "hero" then
                print("onPlatform")
                if not other.isDie then
                    target.isGrounded = true
                    -- target.isMove = true
                end
                -- if target.y > target.maxY then
                --     target.y = target.y - 1
                -- end
            end
        elseif phase == "ended" then
            if other.name == "hero" then
                print("outPlatform")
                if not other.isDie then
                    target.isGrounded = false
                    -- target.isMove = false
                end
                -- if target.y > target.maxY then
                --     target.y = target.y - 1
                -- end
            end
        end
    end

    -- instance:move()

    function instance:finalize()
        self:removeEventListener("collision", instance.collision)
        enterframe_remove(instance.enterFrame)
    end

    instance:addEventListener("finalize")

    instance:addEventListener("collision", instance.collision)
    enterframe_add(instance.enterFrame)
    instance.name = "flyplatform"
    instance.direction = "down2top"
    instance.type = "ground"
end

return M