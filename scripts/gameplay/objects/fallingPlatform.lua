local M = {}
local json = require "json"

local function getEmitterData(path)
    local filePath = system.pathForFile( path )
    local f = io.open( filePath, "r" )
    local emitterData = f:read( "*a" )
    f:close()
    return emitterData
end

function M.new(instance)
    
    local x, y = instance.x, instance.y
    local parent = instance.parent
    instance:removeSelf()
    local offTimer
    local scene = _GB.composer.getScene( _GB.composer.getSceneName( "current" ) )
    local sheet =
    {
        frames = {
            
        },
        sheetContentWidth = 128,
        sheetContentHeight = 10
    }
    for i = 1, 4 do
        sheet.frames[i] = {
            x = 1 + (32 * (i-1)),
            y = 1,
            width = 32,
            height = 10
        }
    end

    local imgsheet = graphics.newImageSheet("res/objects/falling_platform.png", sheet)
    local sequence = {
        {
            name = "on",
            frames = {1, 2, 3, 4},
            time = 200,
            loopDirection = "forward",
            loopCount = 0
        },
        {
            name = "off",
            frames = {1}
        }
    }

    instance = display.newSprite(parent, imgsheet, sequence)
    instance.x, instance.y = x, y
    local emitterParams = json.decode( getEmitterData("res/particles/falling_platform.json") )

    instance.dust = display.newEmitter( emitterParams )
    instance.dust.x, instance.dust.y = instance.x, instance.y
    parent:insert( instance.dust)
    instance.dust:toBack()
    instance:setSequence("on")
    instance:play()
    
    physics.addBody(instance, "static")

    local function Shaky()
        instance.shadkyLoop = function()
            transition.to(instance, {tag = "shaky", time = 500, y = instance.y - 5, onComplete = Shaky})
        end
        transition.to(instance, {tag = "shaky", time = 500, y = instance.y + 5, onComplete = instance.shadkyLoop})
    end


    function instance:collision(event)
        local phase = event.phase
        local target = event.target
        local other = event.other

        if phase == "began" then
            if other.name == "hero" then
                if not instance.isOff then
                    instance.isOff = true
                    instance.dust:stop()

                    transition.cancel("shaky")
                    offTimer = timer.performWithDelay(250, function()
                        instance:setSequence("off")
                        instance:play()
                
                        timer.cancel(offTimer)
                        instance.bodyType = "dynamic"
                        transition.to(instance, {alpha = 0, onComplete = function()
                
                        end})
                    end, 1)
                end
            end
        end
    end

    function instance:finalize()
        instance:removeEventListener("collision")
    end

    function instance:destroy()
        self:removeSelf()
        self = nil
    end

    instance:addEventListener("finalize")
    instance:addEventListener("collision")
    Shaky()
    instance.name = "falling_platform"
    instance.type = "ground"
    return instance
end

return M
