RabbitItem = require("app.scenes.RabbitItem")
local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

--local bg = display.newSprite("background.jpg")
function MainScene:ctor()
    self.xCount = 8 --矩阵宽
    self.yCount = 8 --矩阵高
    self.gap = 0 --矩阵间距
    self.score = 0 --得分
    self.path = cc.FileUtils:getInstance():fullPathForFilename("count.txt")
    --定位矩阵左下角xy坐标
    self.matrixLBX = (display.width-0.25*RabbitItem.getWidth()*self.xCount-(self.yCount-1)*self.gap)/2
    self.matrixLBY = (display.height-0.25*RabbitItem.getWidth()*self.yCount-(self.yCount-1)*self.gap)/2-30
    self:initMatrix()
    self:initScore()
end
--初始化矩阵
function MainScene:initMatrix()
    math.newrandomseed(os.time())--????????????????随机种子
    self.matrix = {}
    self.actives = {}
    for y=1,self.yCount do
        for x=1,self.xCount do
            -- if 1==y and 2 ==x then
            --     self:createAndDropRabbit(x,y,self.matrix[1].rabbitIndex)
            -- else
            self:createAndDropRabbit(x,y)
            -- end
        end
    end
end
--创建并落下对象
function MainScene:createAndDropRabbit(x,y,rabbitIndex)
    local newRabbit = RabbitItem.new(x,y,rabbitIndex) 
    local endPosition = self:positionOfRabbit(x,y) --兔子掉落后坐标
    local startPosition = cc.p(endPosition.x,endPosition.y+display.height/2) --兔子掉落前坐标
    newRabbit:setPosition(startPosition)
    local speed = startPosition.y/(2*display.height) --兔子掉落速度
    newRabbit:runAction(cc.MoveTo:create(speed,endPosition)) --图像从上落下
    self.matrix[(y-1)*self.xCount+x] = newRabbit --将兔子加入矩阵数组
    newRabbit:setScaleX(0.25) --设置图片大小
    newRabbit:setScaleY(0.25)
    self:addChild(newRabbit)
    --设置点击监听
    newRabbit:addNodeEventListener(cc.NODE_TOUCH_EVENT,function(event)
        if newRabbit.isActive then
            self:removeActivedRabbits()--消除高亮区域
            self:showScore() --计分
            self:dropRabbits()--新方块下落
            emitter = cc.ParticleExplosion:create()
                :addTo(self)
                :setPosition(endPosition)
        else
            self:inactive()--取消高亮，选定新区域
            self:activeNeighbor(newRabbit)--高亮周围相同方块
            --self:showActivesScore()--计算高亮区域分数
        end
    end)
    newRabbit:setTouchEnabled(true)
end 
--定位图片坐标
function MainScene:positionOfRabbit(x,y)
    local px = self.matrixLBX + (0.25*RabbitItem.getWidth() + self.gap)*(x-1)+0.25*RabbitItem.getWidth()/2
    local py = self.matrixLBY + (0.25*RabbitItem.getWidth() + self.gap)*(y-1)+0.25*RabbitItem.getWidth()/2
    return cc.p(px,py)
end
--取消高亮区域************************************************有问题
function MainScene:inactive()
    for _,rabbit in pairs(self.actives)do
        if rabbit then
            rabbit:setActive(false)
            print("取消高亮")
        end 
        self.actives = {}--清空内容
    end
end 
--高亮周围相同对象
function MainScene:activeNeighbor(rabbit)
    if false == rabbit.isActive then
        rabbit:setActive(true)
        table.insert(self.actives,rabbit)
    end
    --嵌套判断左边是否相同
    if rabbit.x-1 >=1 then
        local leftNeighbor = self.matrix[(rabbit.y-1)*self.xCount+rabbit.x-1]
        if(leftNeighbor.isActive == false) and (leftNeighbor.rabbitIndex == rabbit.rabbitIndex) then
            leftNeighbor:setActive(true)
            table.insert(self.actives,leftNeighbor)
            self:activeNeighbor(leftNeighbor)
        end
    end
    --判断右边
    if rabbit.x+1<=self.xCount then
        local rightNeighbor = self.matrix[(rabbit.y-1)*self.xCount+rabbit.x+1]
        if(rightNeighbor.isActive == false) and (rightNeighbor.rabbitIndex == rabbit.rabbitIndex) then
            rightNeighbor:setActive(true)
            table.insert(self.actives,rightNeighbor)
            self:activeNeighbor(rightNeighbor)
        end
    end
    --判断上面
    if rabbit.y+1<=self.yCount then
        local upNeighbor = self.matrix[rabbit.y*self.xCount+rabbit.x]
        if(upNeighbor.isActive == false) and (upNeighbor.rabbitIndex == rabbit.rabbitIndex) then
            upNeighbor:setActive(true)
            table.insert(self.actives,upNeighbor)
            self:activeNeighbor(upNeighbor)
        end
    end
    --判断下面
    if rabbit.y-1>=1 then
        local downNeighbor = self.matrix[(rabbit.y-2)*self.xCount+rabbit.x]
        if(downNeighbor.isActive == false) and (downNeighbor.rabbitIndex == rabbit.rabbitIndex) then
            downNeighbor:setActive(true)
            table.insert(self.actives,downNeighbor)
            self:activeNeighbor(downNeighbor)
        end
    end
end
--消除高亮兔子
function MainScene:removeActivedRabbits()

    for _,rabbit in ipairs(self.actives)do
        if rabbit then
            self.matrix[(rabbit.y-1)*self.xCount+rabbit.x] = nil
            self.score = self.score + 1
            self:recordScore(self.score)
            rabbit:removeFromParent()
            print("已经移除")
            
        end
    end
    self.actives = {}
end
--消除后，兔子掉落补全
function MainScene:dropRabbits()
    local emptyInfo = {}
    for x=1,self.xCount do
        local removedRabbits = 0
        local newY = 0
        for y=1,self.yCount do
            local temp = self.matrix[(y-1)*self.xCount+x]
            if temp == nil then
                removedRabbits = removedRabbits + 1
            else
                if removedRabbits>0 then
                    newY = y - removedRabbits
                    self.matrix[(newY-1)*self.xCount+x] = temp
                    temp.y = newY
                    self.matrix[(y-1)*self.xCount+x] = nil

                    local endPosition = self:positionOfRabbit(x,newY)
                    local speed = (temp:getPositionY()-endPosition.y)/display.height
                    temp:stopAllActions()
                    temp:runAction(cc.MoveTo:create(speed,endPosition))
                end
            end
        end
        emptyInfo[x] = removedRabbits
    end
    for x=1,self.yCount do
        for y=self.yCount-emptyInfo[x]+1,self.yCount do
            self:createAndDropRabbit(x,y)
        end
    end
end
--记分板
function MainScene:initScore()
    io.writefile(self.path,0,w)
    local scorePanel = display.newTTFLabel({
        text = "得分:",
        size = 50,
        font = "Marker Felt",
        color = cc.c3b(255,0,0)
    })
    scorePanel:setPosition(display.cx-50,display.cy+370)
        :addTo(self)
end
--显示分数
function MainScene:showScore()
    local score = tonumber(io.readfile(self.path))
    local scoreNumber = display.newTTFLabel({
        text = self.score,
        size = 25,
        font = "Marker Felt",
        color = cc.c3b(255,0,0)
    })
    scoreNumber:setPosition(display.cx+50,display.cy+365)
        :addTo(self)
        
end
--写入计分txt文件
function MainScene:recordScore(number)
    io.writefile(self.path,number,w)
end 

function MainScene:onEnter()
end

function MainScene:onExit()
end

return MainScene


--1 图层重叠，不知道在什么地方removeAllChildren
--2 粒子特效，没办法获取最后的精灵坐标
--3 等我action行动完之后，再接着下一步