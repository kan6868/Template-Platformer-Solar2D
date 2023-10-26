local background = require "scripts.interface.background"
local world      = require "scripts.gameplay.world"
local hero       = require "scripts.gameplay.player"
local questlog   = require "scripts.gameplay.quest"
local button     = require "scripts.interface.button"
local light      = require "scripts.libs.light"
-- local pixelWorld    = require "scripts.libs.pixelWorld"

local physics    = require "physics"

local scene      = _GB.composer.newScene()

local btnRestart
local player, lightSystem
-- create()
function scene:create(event)
    local sceneGroup = self.view
    local params = event.params or {}

    physics.start()
    physics.setGravity(0, 32)
    physics.setDrawMode("normal")

    sceneGroup.backGroup = display.newGroup()
    sceneGroup:insert(sceneGroup.backGroup)

    sceneGroup.mainGroup = display.newGroup()
    sceneGroup:insert(sceneGroup.mainGroup)

    sceneGroup.frontGroup = display.newGroup()
    sceneGroup:insert(sceneGroup.frontGroup)

    background = background.new()
    sceneGroup.backGroup:insert(background)

    local backGroup, mainGroup, frontGroup = sceneGroup.backGroup, sceneGroup.mainGroup, sceneGroup.frontGroup

    -- load world
    self.level = params.level
    print("lode map " .. "level_" .. self.level)
    local pathData = "res/maps/" .. "level_" .. self.level .. ".json"
    local pathImg = "res/maps"

    self.world = world.new(pathData, pathImg, {})
    self.world.extensions = "scripts.gameplay.objects."
    mainGroup:insert(self.world)

    lightSystem = light.new(0.35)
    lightSystem.x, lightSystem.y = _GB.cx, _GB.cy
    self.lightSystem = lightSystem

    mainGroup:insert(lightSystem)


    if self.world:listTypes("fruit") then
        self.world:extend("fruit")
    end

    if self.world:listTypes("cup") then
        self.world:extend("cup")
    end

    if self.world:listTypes("spike") then
        self.world:extend("spike")
    end

    if self.world:listTypes("flyplatform") then
        self.world:extend("flyplatform")
    end

    if self.world:listTypes("jumpPoint") then
        self.world:extend("jumpPoint")
    end

    if self.world:listTypes("fallingPlatform") then
        self.world:extend("fallingPlatform")
    end

    if self.world:listTypes("fire") then
        self.world:extend("fire")
    end

    if self.world:listTypes("trigger") then
        self.world:extend("trigger")
    end



    self.questlog = questlog.new(self.world)

    sceneGroup.frontGroup:insert(self.questlog)
    self.questlog:hide(3000, -1)
    player = self.world:findObject("hero")

    player = hero.new(player, {})

    self.world:pointScale(1, player)
    self.world:setTargetObj(player)

    scene.restartGame = function()
        if self.level > 3 then
            self.level = 0
        end
        screenFadeIn(function()
            _GB.composer.gotoScene("scenes.refresh", { params = { level = self.level } })
        end)
    end

    btnRestart = button.new({
        x = _GB.right,
        y = _GB.top,
        anchorX = 1,
        onTouch = function()
            btnRestart:disable()
            scene.restartGame()
        end
    })

    frontGroup:insert(btnRestart)

    if self.level == 3 then
        player.lightId = lightSystem:addLight(player, 100)
    else
        lightSystem:setAmbient(1.0)
    end

    lightSystem:toFront()
end

local function enterFrame()
    if player.isFinish then
        enterframe_remove(enterFrame)
    end

    scene.world:centerObject("player")
    scene.world:boundsCheck()
end

-- show()
function scene:show(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        enterframe_add(enterFrame)
        screenFadeOut(function()
            btnRestart:active()
            player:show()
            self.world:pointScale(1, player)
        end)
    elseif (phase == "did") then

    end
end

-- hide()
function scene:hide(event)
    local sceneGroup = self.view
    local phase = event.phase

    if (phase == "will") then
        transition.cancelAll()
        enterframe_remove(enterFrame)
    elseif (phase == "did") then
        btnRestart:finalize()
        background:destroy()
        world:removeSelf()
        world = nil
    end
end

-- destroy()
function scene:destroy(event)
    local sceneGroup = self.view
end

-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener("create", scene)
scene:addEventListener("show", scene)
scene:addEventListener("hide", scene)
scene:addEventListener("destroy", scene)
-- -----------------------------------------------------------------------------------

return scene
