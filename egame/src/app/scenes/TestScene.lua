local TestScene = class("TestScene", function()
    return display.newScene("TestScene")
end)

function TestScene:ctor()
    local sprite1 = display.newSprite("tu_1.jpg")
        :setPosition(display.cx,display.cy)
        :addTo(self)
end

return TestScene