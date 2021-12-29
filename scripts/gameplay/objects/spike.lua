local M = {}

function M.new(instance)
    

    function instance:init()
        local boxOptions = {halfWidth = self.width/2, halfHeight = self.height/4, x = 0, y = self.height/4}
        physics.addBody(self, "static", {box = boxOptions, isSensor = true})
    end

    instance:init()
    
    instance.name = "spike"
    instance.type = "trap"
end

return M