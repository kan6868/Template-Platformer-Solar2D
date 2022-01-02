local M = {}

local composer = _GB.composer
local utils = require "scripts.libs.utils"

local function createString(quest)
    local strEnd = ""
    if quest.amount > 1 then
        strEnd = "s"   
    end
    return "  "..quest.quest.." "..quest.amount.." "..quest.name..strEnd
end
local function getIconQuest(type, name)
    if type == "fruit" then
        if name == "cherrie" then
            name = "cherry"
        end
        return "res/objects/fruits/"..name..".png"
    end
    return "Nil"
end

function M.new(world)
    if world == nil then  return false end
    local scene = composer.getScene( composer.getSceneName( "current" ) )
    local level = scene.level

    local group = display.newGroup()
    
    group.quest = {}
    group.data = utils.loadTable("res/data/quest.json", system.ResourceDirectory)

    local dataQuest
    for i = 1, #group.data do

        if group.data[i].level == tostring(level) then
            dataQuest = group.data[i].quest
        end 
    end
    group.isComplete = false

    function group:init()
        local width = 100
        local height = 20
        local paddingBottom = 16
        local paddingTop = 30
        local iconWidth = 8
        local frameIcon = 12
        local txtSize = 8
        local radiusFrame = 1
        group.offsetTransition = width * 2 + frameIcon/2
        local x, y = (_GB.ox + width/2) , _GB.oy +  paddingTop
        if not dataQuest then return false end
        for i = 1, #dataQuest do
            group.quest[i] = display.newGroup()
            local q = group.quest[i]
            q.quest = dataQuest[i].quest
            q.type = dataQuest[i].type
            q.amount = dataQuest[i].amount
            q.name = dataQuest[i].name
            q.id = i
            q.isShow = true
            q.anchorX = 0
            q.anchorY = 0    
            
            q.pnl = display.newRect(q, x, y, width, height)
            q.pnl:setFillColor(0, 0, 0, .4)
            q.pnl.strokeWidth = 1
            q.pnl:setStrokeColor(1)
            
            q.frameIcon = display.newRoundedRect(q, q.pnl.x + q.pnl.width/2,  q.pnl.y - q.pnl.height/2, frameIcon, frameIcon, radiusFrame)
            q.frameIcon:setFillColor(188/255, 53/255, 85/255, 1)
            q.frameIcon.alpha = 1
            q.frameIcon.strokeWidth = 1

            q.frameIcon:setStrokeColor(1)
            q.icon = display.newImageRect(q, getIconQuest(q.type, q.name), iconWidth*2, iconWidth*2)
            q.icon.x = q.frameIcon.x
            q.icon.y = q.frameIcon.y

            q.title = display.newText(q, createString(dataQuest[i]), q.pnl.x - q.pnl.width/2, q.pnl.y, _GB.font[1], txtSize)
            q.title.anchorX = 0
            q.title.anchorY = 0.5
            
            function q:update()
                self.title.text = createString(self)
            end

            function q:collect()
                if self.amount > 0 then
                    self.amount = self.amount - 1
                end
            end


            y = y + height + paddingBottom
            group:insert(q)
        end
    end
    function group:checkQuestComplete( name )
        if group.quest == nil then return false end
        for i = 1, #group.quest do
            local q = group.quest[i]
            if q.name == name and q.amount == 0 then return true end
        end
        return false
    end

    function group:checkAllQuestComplete()
        if group.quest == nil then return false end
        local result = true
        for i = 1, #group.quest do
            local q = group.quest[i]
            if q.amount > 0 then result = false end
        end
        return result
    end

    function group:pauseTransition(_obj, delay)
        transition.pause(_obj)
        transition.to(self, {time = delay, onComplete = function ()
            transition.resume(_obj)
        end})
    end

    function group:hide(delay, pos)
        if group.quest == nil then  return false end
        local pos = pos or -1
        transition.to(self, { tag = "quest", time = delay, onComplete = function ()
            if pos == -1 then
  
                for i = 1, #group.quest do
                    local q = group.quest[i]
                    if q.isShow then
                    transition.to(q, { tag = "quest"..q.id,time = 100, x = q.x - group.offsetTransition , onComplete = function (obj)
                       obj.isShow = false
                    end})
                    else
                        --double effect
                    end
                end
            else

                local q = group.quest[pos]
                q.isShow = true
                transition.to(q, {tag = "quest"..q.id, time = 100, x = q.x - group.offsetTransition, onComplete = function (obj)
                    obj.isShow = false
                end})
            end
        end})
    end
    function group:show(delay, pos)

        if group.quest == nil then  return false end
        local pos = pos or -1
  
        local delay = delay or 500
        transition.to(self, { tag = "quest", time = delay, onComplete = function ()
            if pos == -1 then
                for i = 1, #group.quest do
                    local q = group.quest[i]
                    if not q.isShow then
                        -- if q.x >= (_GB.ox + 50) + group.offsetTransition then
                        --     return false
                        -- end
                        q.isShow = true
                        transition.to(q, { tag = "quest"..q.id, time = 100, x = q.x + group.offsetTransition, onComplete = function (obj)
             
                            group:hide(2000, nil)
                        end})
                    end
                end
            else
                local q = group.quest[pos]
                if not q.isShow then
                
                transition.to(q, {tag = "quest"..q.id, time = 100, x = q.x + group.offsetTransition, onComplete = function (obj)
                    q.isShow = true
                    group:hide(2000, obj.id)
                end})
                end 
            end    
        end})
        
    end


    function group:update()
        for i = 1, #self.quest do
            self.quest[i]:update()
        end
    end

    function group:collect(name)

        for i = 1, #self.quest do

            if self.quest[i].name == name then
                self.quest[i]:collect()


                self.quest[i]:update()
                group:show(0,self.quest[i].id)
        
            end
        end
    end

    group:init()
    
    return group
end

return M