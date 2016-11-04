
local SObject = Class{
  init = function(self, x, y)
    self.x = x or 0
    self.y = y or 0
    self.r = 0
    self.sx = 1
    self.sy = 1
    self.parent = nil
    self.w = 0
    self.h = 0
    self.childs = {}
    self.pivot = {0.5, 0.5}
  end
}

function SObject:refresh() if self.parent then self.parent:refresh() end end
function SObject:setX(val) self.x = val; self:refresh() end
function SObject:setY(val) self.y = val; self:refresh() end
function SObject:setR(val) self.r = val; self:refresh() end
function SObject:setW(val) self.w = val; self:refresh() end
function SObject:setH(val) self.h = val; self:refresh() end
function SObject:setSX(val) self.sx = val; self:refresh() end
function SObject:setSY(val) self.sy = val; self:refresh() end

function SObject:getDrawW() self.sx = val; self:refresh() end
function SObject:getDrawS() self.sy = val; self:refresh() end
function SObject:getDrawX() self.sx = val; self:refresh() end
function SObject:getDrawY() self.sy = val; self:refresh() end


function SObject:draw() lume.chain(self.childs):filter(function(c) return not c.off and c.draw end):each(function(c) c.draw() end) end
function SObject:update(dt) lume.chain(self.childs):filter(function(c) return not c.off and c.update end):each(function(c) c.update(dt) end) end

local SSprite = Class{__includes=SObject,
  init = function(self, img, x, y)
    SObject.init(self, x, y)
    self:setImg(img)
  end
}

function SSprite:refresh()
  self.w,self.h = resource:getDimension()
  SObject.refresh(self)
end

function SSprite:setImg(img) self.img = img; self:refresh() end

function SSprite:draw(x,y,r,sx,sy)
  local _x,_y,_r,_sx,_sy = x or 0 + self.x,y or 0 + self.y,r or 0 + self.r,sx or 1 * self.sx,sy or 1 * self.sy
  love.graphics.draw(self:getImg(), _x, _y, _r, _sx, _sy)
  SObject.draw(self, _x, _y, _r, _sx, _sy)
end
