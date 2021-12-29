local M = {}

function M.new()

    local background = display.newGroup()
    local debugRatio = 1
    local listTiled = {
        "res/background/Blue.png",
        "res/background/Brown.png",
        "res/background/Gray.png",
        "res/background/Green.png",
        "res/background/Pink.png",
        "res/background/Purple.png",
        "res/background/Yellow.png"
    }
    local edge = 64 * debugRatio

    background.items = nil

    function background:init()

        if self.items == nil then self.items = {} end
        local items = self.items
        self.cols = math.ceil((_GB.h * debugRatio)/edge) + 4
        self.rows = math.ceil((_GB.w* debugRatio)/edge) + 4
        local img = listTiled[math.random(#listTiled)]
        local x, y = (_GB.ox * debugRatio) - edge*2, (_GB.oy * debugRatio) - edge*2
        for c = 1, self.cols do
            for r = 1, self.rows do
                local i = #items + 1
                self.items[i] = display.newImageRect(self, img, edge, edge)
                self.items[i].x, self.items[i].y = x, y
                self.items[i].anchorX, self.items[i].anchorY = 0, 0
                x = x + edge
            end
            x = (_GB.ox * debugRatio) - edge*2
            y = y + edge
        end

        local function getRndValue()
            while true do
                local valX = math.random(-1, 1)
                local valY = math.random(-1, 1)
                if valX ~= 0 or valY ~= 0 then
                    return valX * debugRatio, valY * debugRatio 
                end
            end
        end
        -- create direction
        self.dirX, self.dirY = getRndValue() 

        self.padding = 1 * debugRatio
        self:active()
    end

    background.enterFrame = function ()
        if background.items == nil then print("item null") return false end
        local items = background.items

        for i = 1, #items do
            if items[i].x ~= nil and items[i].y ~= nil  then
                local top, left = (_GB.oy * debugRatio) - edge*2, (_GB.ox * debugRatio) - edge*2
                local bottom = top + (edge * background.cols)
                local right = left + (edge * background.rows)
                left, right = math.floor(left), math.floor(right)
                -- print(top, left, right, bottom)
                items[i].x, items[i].y = items[i].x + (background.dirX * 1) , items[i].y + (background.dirY * 0.5)

                if background.dirX == -1 * debugRatio then
                    if items[i].x <= left then
                        items[i].x = right - background.padding
                    end
                elseif background.dirX == 1 * debugRatio then
                    if items[i].x + edge >= ( right ) then
                        items[i].x = left - background.padding
                    end    
                end

                if background.dirY == -1 * debugRatio then
                    if items[i].y <= top then
                        items[i].y = bottom - background.padding
                    end
                elseif background.dirY == 1 * debugRatio then
                    if items[i].y >= bottom then
                        items[i].y = top + background.padding
                    end
                end
            end
        end
    end

    function background:finalize()
        enterframe_remove(background.enterFrame)
        -- self:addEventListener("touch", self.touch)
    end
    function background:active()
        enterframe_add(background.enterFrame)
    end
    function background:destroy()
        background:finalize()
        for i = 1, #background.items do
            table.remove(background.items, i)
        end
        background.items = nil
        background:removeSelf()
        background = nil
    end


    background:finalize()

    background:init()

    -- Runtime:addEventListener("enterFrame", background)
    return background
end

return M