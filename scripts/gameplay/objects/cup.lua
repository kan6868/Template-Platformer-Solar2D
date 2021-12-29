local M = {}

function M.new(instance)
    
    local x, y = instance.x, instance.y
    local parent = instance.parent
    instance:removeSelf()
    local scene = _GB.composer.getScene( _GB.composer.getSceneName( "current" ) )
    local sheet =
    {
        frames = {
            
        },
        sheetContentWidth = 512,
        sheetContentHeight = 64
    }
    for i = 1, 8 do
        sheet.frames[i] = {
            x = 1 + (64 * (i-1)),
            y = 1,
            width = 64,
            height = 64
        }
    end

    local imgsheet = graphics.newImageSheet("res/objects/End.png", sheet)
    local sequence = {
        {
            name = "finish",
            frames = {1, 2, 3, 4, 5, 6, 7, 8},
            time = 400,
            loopDirection = "forward",
            loopCount = 1
        },
        {
            name = "idle",
            frames = {8}
        }
    }

    instance = display.newSprite(parent, imgsheet, sequence)
    instance.x, instance.y = x, y
    instance:setSequence("idle")
    instance:play()
    
    physics.addBody(instance, "static", {box = {halfWidth = instance.width/3, halfHeight = 2, x = 0, y = -instance.height/5}, isSensor = true})

    
    function instance:finalize()
        self:removeEventListener("collision")
    end
    function instance:bounce()
        instance:setSequence("finish")
        instance:play()
    end
    function instance:destroy()
        -- self:finalize()
        self:removeSelf()
        self = nil
    end

    -- instance:addEventListener("finalize")
    -- instance:addEventListener("collision")

    instance.name = "finish"
    return instance
end

return M
