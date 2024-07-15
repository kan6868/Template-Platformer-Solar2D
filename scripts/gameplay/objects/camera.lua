local M = {}

local min, max = math.min, math.max
local cx, cy = display.contentCenterX, display.contentCenterY
local aw, ah = display.actualContentWidth, display.actualContentHeight
function M.new(instance)
    local world = instance.parent.parent -- Get the map camera -> layer -> map
    local limitBounds = world:findObjectById(instance.limit)
    local focusObject = world:findObjectById(instance.focusObject)

    local camera = instance
    
    if limitBounds then
        limitBounds.isVisible = false
        
        camera.bounds = --limitBounds.contentBounds
        {
            xMin = limitBounds.x - limitBounds.contentWidth * .5,
            yMin = limitBounds.y - limitBounds.contentHeight *.5,
            xMax = limitBounds.x + limitBounds.contentWidth * .5,
            yMax = limitBounds.y + limitBounds.contentHeight *.5
        }
    end

    camera.camWidth = 320
    camera.camHeight = 480

    camera.offsetH = 0
    camera.offsetV = 0
    camera.smoothingSpd = 0

    camera.debugMargin = {}

    camera.margin_v = false
    camera.margin_h = false

    function camera:limit()
        local halfWidth = aw / 2 --+ self.offsetH
        local halfHeight = ah / 2 --+ self.offsetV

        if self.bounds.xMin > self.x - halfWidth then
            self.x = self.bounds.xMin + halfWidth
        end

        if self.bounds.xMax < self.x + halfWidth then
            self.x = self.bounds.xMax - halfWidth
        end

        if self.bounds.yMin > self.y - halfHeight then
            self.y = self.bounds.yMin + halfHeight 
        end

        if self.bounds.yMax < self.y + halfHeight then
            self.y = self.bounds.yMax - halfHeight 
        end

        if self.bounds.xMin >= self.x - halfWidth and
        self.bounds.xMax <= self.x + halfWidth then
            self.x = limitBounds.x
        end

        if self.bounds.yMin >= self.y - halfHeight and
        self.bounds.yMax <= self.y + halfHeight then
            self.y = limitBounds.y  
        end
    end

    function camera:setDragVerticle(bool)
        self.margin_v = bool        
    end

    function camera:setHorizontalVerticle(bool)
        self.margin_h = bool        
    end

    function camera:setDragMargin(bounds)
        local bounds = bounds or {}
        local top = bounds.top or .2
        local bottom = bounds.bottom or .2
        local left = bounds.left or .2
        local right = bounds.right or .2

        self.dragMargin = {
            top = top,
            right = right,
            bottom = bottom,
            left = left
        }
    end

    function camera:updateDragMargin()
        if not self.margin then
            self.margin = {}
        end

        self.margin.top = camera.camHeight / 2 * self.dragMargin.top
        self.margin.right = camera.camWidth  / 2 * self.dragMargin.right
        self.margin.bottom = camera.camHeight / 2 * self.dragMargin.bottom
        self.margin.left = camera.camWidth  / 2 * self.dragMargin.left
    end

    function camera:drawDragMargin()
        if not self.is_draw_margin then return false end
        if not self.isVisible then return false end

        if self.debugMargin.leftSide then
            self.debugMargin.leftSide:removeSelf()
            self.debugMargin.leftSide = nil
        end

        if self.debugMargin.rightSide then
            self.debugMargin.rightSide:removeSelf()
            self.debugMargin.rightSide = nil
        end


        if self.debugMargin.bottomSide then
            self.debugMargin.bottomSide:removeSelf()
            self.debugMargin.bottomSide = nil
        end

        if self.debugMargin.topSide then
            self.debugMargin.topSide:removeSelf()
            self.debugMargin.topSide = nil
        end

        if self.debugMargin.viewport then
            self.debugMargin.viewport:removeSelf()
            self.debugMargin.viewport = nil
        end

        local top = self.margin.top
        local right = self.margin.right
        local bottom = self.margin.bottom
        local left = self.margin.left

        if self.margin_h then
            self.debugMargin.leftSide = display.newLine(self.parent, self.x - left, self.y + bottom, self.x - left,
                self.y - top)
            self.debugMargin.leftSide.strokeWidth = 2

            self.debugMargin.rightSide = display.newLine(self.parent, self.x + right, self.y + bottom, self.x + right,
                self.y - top)
            self.debugMargin.rightSide.strokeWidth = 2
        end
        if self.margin_v then
            self.debugMargin.bottomSide = display.newLine(self.parent, self.x - left, self.y + bottom, self.x + right,
                self.y + bottom)
            self.debugMargin.bottomSide.strokeWidth = 2

            self.debugMargin.topSide = display.newLine(self.parent, self.x - left, self.y - top, self.x + right,
                self.y - top)
            self.debugMargin.topSide.strokeWidth = 2
        end

        -- self.debugMargin.viewport = display.newRect(self.parent, self.x, self.y, self.camWidth - 4, self.camHeight - 4)
        -- self.debugMargin.viewport:setFillColor(1, 1, 1, 0)
        -- self.debugMargin.viewport.strokeWidth = 4
    end

    function camera:moveFollowFocusObject()
        local moveX = self.x or 0 
        local moveY = self.y or 0

        if focusObject then
            moveX = focusObject.x or 0
            moveY = focusObject.y or 0
        end

        local smoothing = (camera.smoothingSpd == 0) and 1 or camera.smoothingSpd * ( 1 / display.fps)
  
        local smoothMoveX = moveX
        local smoothMoveY = moveY

        if self.margin_h then
            smoothMoveX = min(self.x, (moveX + self.margin.left))
            smoothMoveX = max(smoothMoveX, (moveX - self.margin.right))
        end

        if self.margin_v then
            smoothMoveY = min(self.y, (moveY + self.margin.top))
            smoothMoveY = max(smoothMoveY, (moveY - self.margin.bottom))
        end

        local deltaX = smoothMoveX - self.x
        local deltaY = smoothMoveY - self.y

        self.x = self.x + deltaX * smoothing
        self.y = self.y + deltaY * smoothing
    end

    local function update()
        if not camera then
            return false
        end
        camera:moveFollowFocusObject()
        
        if limitBounds then
            camera:limit()    
        end
        
        local objx, objy = world:localToContent(camera.x, camera.y)
        objx, objy = cx - objx, cy - objy
    
        world.x = world.x + objx + camera.offsetH * 1/60
        world.y = world.y + objy + camera.offsetV * 1/60
        
        camera:drawDragMargin()
    end

    camera:setDragMargin()
    camera:updateDragMargin()
    
    function camera:finalize()
        Runtime:removeEventListener("enterFrame", update)
    end

    Runtime:addEventListener("enterFrame", update)
    camera:addEventListener("finalize")
    return camera    
end

return M