local RabbitItem = class("RabbitItem",function(x,y,rabbitIndex)
    rabbitIndex = rabbitIndex or math.random(1,8)
    local sprite = display.newSprite("tu_"..rabbitIndex..".jpg")
    sprite.rabbitIndex = rabbitIndex
    sprite.x = x
    sprite.y = y
    sprite.isActive = false
    return sprite
end)

function RabbitItem:ctor()

end

function RabbitItem:setActive(active)
    self.isActive = active
    --如果是ji
    if active then
        self:setScaleX(0.2)
        self:setScaleY(0.2)
        self:setLocalZOrder(10)--设置层级，数字越大层级越高
    else 
        self:setScaleX(0.25)
        self:setScaleY(0.25)
    end
end

function RabbitItem:getWidth()
    g_RabbitWidth = 0
    if 0 == g_RabbitWidth then
        local sprite = display.newSprite("tu_1.jpg")
        g_RabbitWidth = sprite:getContentSize().width
    end 
    return g_RabbitWidth
end

return RabbitItem
