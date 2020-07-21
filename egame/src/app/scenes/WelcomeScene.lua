local MainScene = require"app.scenes.MainScene"
local WelcomeScene = class("WelcomeScene", function()
    return display.newScene("WelcomeScene")
end)

function WelcomeScene:ctor()
    local count = 1
    local s_button = display.newSprite("start_button.png")
        :addTo(self)
        :setScaleX(0.1)
        :setScaleY(0.1)
        :setPosition(display.cx,display.cy)
    local emitter = cc.ParticleMeteor:create()
        :addTo(self)
        :setTexture(s_button:getTexture())
        
    s_button:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        print("ok")
        local mainScene = MainScene.new()
        emitter:runAction(cc.BezierTo:create(3,{
            cc.p(display.left,display.top),
            cc.p(640,960),
            cc.p(320,320)
        }))
        s_button:runAction(cc.BezierTo:create(3,{
            cc.p(display.left,display.top),
            cc.p(640,960),
            cc.p(320,320)
        }))
        if count == 2 then
            display.replaceScene(mainScene)   
        end
        count = count + 1
    end)
    s_button:setTouchEnabled(true)
    local title = display.newTTFLabel({
        text = "Eliminate Rabbits",
        font = "Brush Script MT",
        size = 64,
        color = cc.c3b(300,300,300),
        --align = cc.TEXT_ALIGNMENT_CENTER
    })
    title:addTo(self)
        :setPosition(display.cx,display.cy+100)

end


return WelcomeScene