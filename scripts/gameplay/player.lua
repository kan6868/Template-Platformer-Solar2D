local M = {}

local composer = _GB.composer

M.left = -1
M.right = 1

local function getPoint(directionX, directionY, obj)
    local offsetX, offsetY = obj.width * obj.anchorX, obj.height * obj.anchorY
    local valX, valY = obj.x, obj.y

    if directionX == "left" then
        valX = valX - offsetX / 2
    elseif directionX == "right" then
        valX = valX + offsetX / 2
    elseif directionX == "middle" then

    end

    if directionY == "bottom" then
        valY = valY + offsetY / 2
    elseif directionY == "top" then
        valY = valY - offsetY / 2
    end
    return valX, valY
end
function M.new(instance, options)
    -- Get current scene and parent group
    local scene = composer.getScene(composer.getSceneName("current"))

    local x, y = instance.x, instance.y
    display.remove(instance)

    local options   = options or {}
    local name      = options.name or "mask_dude"

    local sheet     = require("res.characters.scripts." .. name)

    -- load frame animation
    local heroSheet = graphics.newImageSheet(sheet:getImagePath(), sheet:getSheet())
    local sequences = sheet:getSquence()


    instance = display.newSprite(scene.world, heroSheet, sequences)
    instance.x, instance.y = x, y
    instance.alpha = 0
    instance.originalHeight = instance.height
    instance.originalWidth = instance.width

    instance.name = "hero"
    instance.state = "none"

    instance.isGrounded = false
    instance.isJumping = true
    instance.canDoubleJump = false
    instance.canWallJump = false
    instance.canFallJump = true
    instance.isWall = false
    instance.jumpKey = false
    instance.isFinish = false
    instance.isOnPlatformDown = false
    instance.jumpPressed = false

    instance.speed = 120
    instance.speedOnAir = 10
    instance.forceJump = -6
    instance.forcePushJump = 10

    instance.dir = 0
    instance.leftDir = 0
    instance.rightDir = 0

    instance.camera = display.newRect(instance.parent, instance.x, instance.y, instance.width, instance.height)
    local checkWall = display.newCircle(instance.parent, instance.x - instance.width / 2 + 5, instance.y, 5)
    local checkGround = display.newCircle(instance.parent, instance.x, instance.y + instance.height / 2 - 5, 5)
    instance.camera.alpha = 0

    checkWall.alpha = 0
    checkGround.alpha = 0

    instance.enterFrame = function(event)
        if not instance.isDie and instance.state ~= "hit" then
            instance.vx, instance.vy = instance:getLinearVelocity()
            instance.dir = instance.leftDir + instance.rightDir

            local vx, vy = instance.vx, instance.vy

            local dir = instance.dir
            local state = instance.state
            -- Following
            checkWall.x, checkWall.y = instance.x + (instance.originalWidth / 2) * instance.xScale - 5 * instance.xScale,
                instance.y
            checkGround.x, checkGround.y = instance.x, instance.y + instance.originalHeight / 2 - 5
            instance.camera.x, instance.camera.y = instance.x, instance.y

            if state ~= "idle" then
                if dir == 0 and not instance.isJumping then
                    instance:setLinearVelocity(0, vy)
                    instance:chargeSequence("idle")
                end

                if (instance.isGrounded or state == "run") and instance.dir == 0 and vy == 0 then
                    instance:setLinearVelocity(0, 0)
                    instance:chargeSequence("idle")
                end

                if state == "fall" and vy == 0 and instance.isJumping then
                    instance.isJumping = false
                    instance.isGrounded = true
                    instance:chargeSequence("idle")
                end
            end

            if state ~= "run" then
                if dir ~= 0 then
                    if state == "idle" then
                        instance:applyForce(instance.speed * dir, nil, instance.x, instance.y)
                        instance:chargeSequence("run")
                    elseif instance.isJumping then
                        instance:applyForce(instance.speedOnAir * dir, nil, instance.x, instance.y)
                    end
                    if math.abs(vx) >= 100 then
                        instance:setLinearVelocity(100 * instance.dir, vy)
                    end
                end
            end
            if state == "run" then
                if instance.prevDir and instance.dir ~= 0 then
                    if instance.dir ~= instance.prevDir then
                        instance:setLinearVelocity(0, 0)
                        instance:applyForce(instance.speed * dir, 0)
                    end
                end
            end

            instance:flip(dir)

            if instance.isJumping then
                if vy > 0 and state ~= "fall" and not instance.isOnPlatformDown then
                    if instance.isFinish then
                        instance:hide()
                    else
                        instance:chargeSequence("fall")
                    end
                end
            end
        end
    end

    function instance:flip(direction)
        if direction ~= 0 then
            self.xScale = direction
            instance.prevDir = direction
        end
    end

    function instance:chargeSequence(state)
        instance:setSequence(state)
        instance.state = state
        instance:play()
    end

    function instance:hide()
        local effect = require "scripts.gameplay.desappearing"
        self:finalize()
        self.alpha = 0
        self.desappearing = effect.new(self, {})
        self.parent:insert(self.desappearing)
        self.desappearing:active()
        if self.lightId then
            scene.lightSystem:removeLight(self.lightId)
        end
    end

    function instance:show()
        local effect = require "scripts.gameplay.appearing"
        self.appearing = effect.new(self, {})
        self.parent:insert(self.appearing)
        self.appearing:active()
    end

    function instance:hurt()

    end

    function instance:move()

    end

    function instance:jump()
        if self.isGrounded and ((not self.isJumping) or (self.isJumping and self.isOnPlatformDown)) then
            self.isJumping = true
            self:chargeSequence("jump")
            self.canDoubleJump = true
            self:applyLinearImpulse(0, self.forceJump, self.x, self.y)
        else
            if (self.canDoubleJump) and self.isJumping and self.state ~= "double jump" then
                self.canDoubleJump = false
                self.canFallJump = false
                self:chargeSequence("double jump")
                self:setLinearVelocity(0, 0)
                self:applyLinearImpulse(0, self.forceJump, self.x, self.y)
                -- instance:effectDust("assets/particle/dust_jump.json")
            end
        end

        if (self.state == "fall" and self.canFallJump and self.isJumping) then
            -- print("jump")
            self.canDoubleJump = false
            self.canFallJump = false
            self:chargeSequence("double jump")
            self:setLinearVelocity(0, 0)
            self:applyLinearImpulse(0, self.forceJump, self.x, self.y)
        end

        -- self:effectDust("assets/particle/dust_jump.json")
    end

    function instance:die()
        if self.state ~= "hit" then
            -- self.isFixedRotation = false

            self:finalize()
            self:chargeSequence("hit")
            scene.world.isFollow = false
            self:setLinearVelocity(instance.vx, 0)
            self.isDie = true
            self.isSensor = true
            -- self.isFixedRotation = false
            self:applyLinearImpulse(-3 * self.xScale, self.forceJump, self.x, self.y)
            -- self:applyAngularImpulse(-100)
        end
    end

    function instance:pause()
        self.paused = true
    end

    function instance:resume()
        self.paused = false
    end

    function instance:preCollision(event)
        local other = event.other

        if other.type == "flyplatform" then
            -- self.isOnPlatformDown = true
        end
    end

    function instance:postCollision(event)
        local other = event.other

        if other.name == "flyplatform" then
            if other.direction == "leftright" then
                if self.dir == 0 and not self.isJumping then
                    local pX, pY = getPoint("none", "bottom", self)
                    if pY <= (other.y - other.height / 2) then
                        self:setLinearVelocity(other.vx, self.vy)
                    end
                end
            elseif other.direction == "topdown" then
                if self.dir == 0 and not instance.jumpPressed then
                    instance.isGrounded = true
                    instance.isJumping = false

                    if other.vy > 0 then
                        self:setLinearVelocity(0, other.vy * 2)
                    else
                        self:setLinearVelocity(0, other.vy * 1.2)
                    end
                else

                end
            end
        end
    end

    local function checkGroundCollision(event)
        local other = event.other
        local target = event.target
        local phase = event.phase
        if phase == "began" and not instance.isDie then
            if other.type == "ground" then
                if instance.isWall then
                    instance.isWall = false
                end

                instance:setLinearVelocity(0, 0)
                instance:chargeSequence("idle")
                instance.isJumping = false
                instance.isGrounded = true
                instance.canFallJump = true
            end

            if other.name == "finish" and instance.state == "fall" then
                local isQuestComplete = scene.questlog:checkAllQuestComplete()
                if isQuestComplete then
                    local lvl = scene.level
                    print("Go to next level")
                    if lvl == "tutorial" then
                        scene.level = 1
                    else
                        scene.level = scene.level + 1
                    end


                    instance:setLinearVelocity(0, 0)
                    instance.isFinish = true
                    instance.isJumping = true
                    instance:chargeSequence("jump")
                    instance:applyLinearImpulse(0, instance.forceJump, instance.x, instance.y)
                    other:bounce()
                end
            end

            if other.name == "spike" then
                instance:die()
                timer.performWithDelay(1000, function()
                    scene.restartGame()
                end)
            end
        elseif phase == "ended" and not instance.isDie then
            if other.name == "flyplatform" and other.direction == "topdown" then
                instance.isOnPlatformDown = false
            end
        end
    end
    local function checkWallCollision(event)
        local other = event.other
        local target = event.target
        local phase = event.phase
        if phase == "began" then
            if other.type == "ground" --[[and instance.vy > 0]] then --and not instance.isGround and instance.vy > 0 then
                instance.isWall = true
            end
        elseif phase == "ended" then
            if other.type == "ground" --[[and instance.vy < 0]] then
                instance.isWall = false
            end
        end
    end

    function instance:addController()
        require "scripts.controller.controller".new(self)
    end

    local function key(event)
        if (event.keyName == "a" or event.keyName == "left") then
            if event.phase == "down" then
                instance.leftDir = -1
            elseif event.phase == "up" then
                instance.leftDir = 0
            end
        elseif (event.keyName == "d" or event.keyName == "right") then
            if event.phase == "down" then
                instance.rightDir = 1
            elseif event.phase == "up" then
                instance.rightDir = 0
            end
        elseif (event.keyName == "w" or event.keyName == "up") then
            if event.phase == "down" then
                instance.jumpPressed = true
                instance:jump()
            elseif event.phase == "up" then
                instance.jumpPressed = false
            end
        elseif (event.keyName == "p") then
            if event.phase == "down" then
                physics.setDrawMode("hybrid")
            elseif event.phase == "up" then
                physics.setDrawMode("normal")
            end
        elseif (event.keyName == "space") then
            if event.phase == "down" then
                print(
                    "State : " .. instance.state .. "\n" ..
                    "VelocityX : " .. instance.vx .. "\n" ..
                    "VelocityY : " .. instance.vy .. "\n" ..
                    "Direction : " .. instance.dir .. "\n" ..
                    "isGrounded : " .. tostring(instance.isGrounded) .. "\n" ..
                    "isWall : " .. tostring(instance.isWall) .. "\n" ..
                    "isJumping : " .. tostring(instance.isJumping) .. "\n" ..
                    "canFallJump : " .. tostring(instance.canFallJump)
                )
            elseif event.phase == "up" then

            end
        end

        -- IMPORTANT! Return false to indicate that this app is NOT overriding the received key
        -- This lets the operating system execute its default handling of the key
        return false
    end

    function instance:active()
        physics.addBody(instance, "dynamic",
            { box = { halfWidth = 8, halfHeight = 10, x = 0, y = 0 }, friction = .4, density = 1.5 })
        instance.isFixedRotation = true
        instance.anchorY = 0.66
        instance.alpha = 1


        physics.addBody(checkWall, "dynamic", {
            box = { halfWidth = 1, halfHeight = instance.height / 4 },
            isSensor = true
        })
        physics.addBody(checkGround, "dynamic", { box = { halfWidth = 8 * .9, halfHeight = 0.1 } })
        checkGround.isFixedRotation = true

        instance:chargeSequence("fall")

        instance:addEventListener("preCollision")
        instance:addEventListener("postCollision")
        -- instance:addEventListener("collision")
        checkWall:addEventListener("collision", checkWallCollision)
        checkGround:addEventListener("collision", checkGroundCollision)
        Runtime:addEventListener("key", key)
        Runtime:addEventListener("enterFrame", instance)
    end

    function instance:destroy()
        -- instance:removeSelf()
        -- instance = nil
    end

    function instance:finalize()
        -- On remove, cleanup instance, or call directly for non-visual
        instance:removeEventListener("preCollision")
        -- instance:removeEventListener("collision")
        instance:removeEventListener("postCollision")
        Runtime:removeEventListener("key", key)
        Runtime:removeEventListener("enterFrame", instance)
    end

    function checkWall:finalize()
        checkWall:removeEventListener("collision", checkWallCollision)
    end

    function checkGround:finalize()
        checkGround:removeEventListener("collision", checkGroundCollision)
    end

    -- instance:addController()
    instance:addEventListener("finalize")
    checkGround:addEventListener("finalize")
    checkWall:addEventListener("finalize")

    instance:addController()

    return instance
end

return M
