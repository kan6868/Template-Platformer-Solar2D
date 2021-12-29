-- camera control

local M = {}
local tiled     = require ("scripts.libs.ponytiled")
local composer  = require ("composer")
local json      = require ("json")
local cx, cy, ox, oy = display.contentCenterX, display.contentCenterY, display.safeScreenOriginX, display.safeScreenOriginY
--"maps/" .. self.map .. ".json"
function M.new( data, assetPath, options)

  if not data or not assetPath then
    print("ERROR: Has the parameter missing")
    return false 
  end

  local options   = options or {}
  local x         = options.x or cx
  local y         = options.y or cy
  local scale     = options.scale or 1

  local mapData = json.decodeFile(system.pathForFile(data, system.ResourceDirectory))
  local map = tiled.new(mapData, assetPath)

  map:centerAnchor()
  map:toBack()
  
  map.x, map.y = ox, oy
  map.isFollow = true
  map.targetObj = nil

  function map:setTargetObj(obj)
    map.targetObj = obj
  end
  function map:center()
    -- centers the world on screen
    self.x, self.y = cx, cy
  end

  function map:reset()
    -- places the world on screen at 0,0
    self.x, self.y = 0,0
  end
  function map:getXYOffset()
    
    if not self.targetObj.camera then
      return false, false 
    end

    local x, y = self.targetObj.camera:localToContent(0,0)
    x, y = cx - x, cy - y
    return x, y
  end
  local function lerp(x1, x2, time)
    return x1 + time * (x2 - x1)
  end

  map.enterFrame = function (event)
    local offsetX, offsetY = map:getXYOffset()
    if not offsetX or not offsetY then
      print("hero is not found")
      return false
    end

    if map.x ~= map.x + offsetX then
      map.x = lerp(map.x, map.x + offsetX, 0.025)
    end
    if map.y ~= map.y + offsetY then
      map.y = lerp(map.y, map.y + offsetY, 0.05)
    end
    map:boundsCheck()
  end
  
  function map:pointScale(scale, object)
      local ox, oy, nx, ny
      if object then
          ox, oy = object:localToContent(0,0)
          self.xScale, self.yScale = scale, scale
          nx, ny = object:localToContent(0,0)
      else
          ox, oy = self:localToContent(0,0)
          self.xScale, self.yScale = scale, scale
          nx, ny = self:localToContent(0,0)
      end
      self:translate(ox-nx, oy-ny)
  end

  function map:finalize()
    Runtime:removeEventListener("enterFrame", self)
  end

  map:addEventListener("finalize")
  
  Runtime:addEventListener("enterFrame", map)

  return map
end

return M