-- pixel version of world

local M = {}

local centerX, centerY = display.contentCenterX, display.contentCenterY

function M.new(pixelScale)
  pixelScale = pixelScale or 3
--   print("Pixel world")
  local width = math.floor(display.actualContentWidth / pixelScale)
  local height = math.floor(display.actualContentHeight / pixelScale)
  display.setDefault( "magTextureFilter", "nearest" )

  local instance = display.newSnapshot(width, height)
  instance.xScale, instance.yScale = pixelScale, pixelScale
  instance:translate( width/2, height/2 ) 
--   local test = display.newRect(instance.group, display.contentCenterX, display.contentCenterY, display.actualContentWidth, display.actualContentHeight)
--   instance.anchorX = 0.25
  function instance:center()
    -- centers the world on screen
    instance.x, instance.y = centerX, centerY
  end

  function instance:reset()
    -- places the world on screen at 0,0
    instance.x, instance.y = display.actualContentWidth/2, display.actualContentHeight/2
  end

  function instance:centerObj(obj)
    -- moves the world, so the specified object is on screen
    if obj == nil then return false end

    -- easiest way to scroll a map based on a character
    -- find the difference between the hero and the display center
    -- and move the world to compensate
    local x, y = obj:localToContent(0,0)
    x, y = centerX - x, centerY - y
    self.x, self.y = self.x + x, self.y + y
  end

  local function enterFrame(event)
    instance.fill.effect = "filter.colorChannelOffset"
    instance.fill.effect.xTexels = 1.1
    instance.fill.effect.yTexels = 1.1
    
    instance:invalidate()
  end

  function instance:finalize()
    Runtime:removeEventListener("enterFrame", enterFrame)
  end

  Runtime:addEventListener("enterFrame", enterFrame)
--   instance:center()
  return instance
end

return M