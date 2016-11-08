

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

function SObject:add(child) lume.push(self.childs, child); return child end

function SObject:fromPolar(r,u) return r * math.cos(u), r * math.sin(u) end
function SObject:toPolar(x,y)
  local r = math.sqrt(y*y + x*x)
  if x > 0 and y >= 0 then return r, math.atan(y/x)
  elseif x > 0 and y < 0 then return r, math.atan(y/x) + 2 * math.pi
  elseif x < 0 then return r, math.atan(y/x) + math.pi
  elseif x == 0 and y > 0 then return r, math.pi / 2
  elseif x == 0 and y < 0 then return r, (3 * math.pi) / 2
  else return r, 0 end
end

function SObject:getPointAfterRotation(x, y, r) return self:fromPolar(math.sqrt(y*y + x*x), r) end

function SObject:transform(x, y, r, sx, sy, tx, ty)
  local _r,_u = self:toPolar(self.x * sx, self.y * sy)
  local dx,dy =  self:fromPolar(_r, _u + r)
  return (dx + x),
         (dy + y),
          r + self.r
end

function SObject:toRad(grad) return (math.pi / 180.0) * grad end
function SObject:draw(x,y,r,sx,sy, tx, ty) end
function SObject:__draw(x, y, r, sx, sy)
  if not x then x = 0 end
  if not y then y = 0 end
  if not r then r = 0 end
  if not sx then sx = 1 end
  if not sy then sy = 1 end
  x,y,r = self:transform(x,y,r, sx, sy)
  sx = sx * self.sx
  sy = sy * self.sy
  r = r + self.r
  if self.draw then
    self:draw(x, y, r, sx, sy, (self.w * self.pivot[1]) , (self.h * self.pivot[2]))
  end
  lume.chain(self.childs):filter(function(c) return not c.off and c.draw end):each(function(c) c:__draw(x,y,r, sx, sy) end)
end

function SObject:getDimensions() return w,h end

function SObject:mousemoved(mx, my, dx, dy, istouch)
end

function SObject:transformMouse(mx, my)
  local _r,_u = self:toPolar(mx * self.sx, my * self.sy)
  local dx,dy =  self:fromPolar(_r, _u + self.r)
  return dx,dy
end

function SObject:__mousemoved(mx, my, dx, dy, istouch, x, y, r, sx, sy)
  if not x then x = 0 end
  if not y then y = 0 end
  if not r then r = 0 end
  if not sx then sx = 1 end
  if not sy then sy = 1 end
  x,y,r = self:transform(x, y, r, sx, sy) -- текущая система координат
  sx = sx * self.sx
  sy = sy * self.sy
  r = r + self.r
  local _r,_u = self:toPolar((mx - x) / sx, (my - y) / sy)
  if self.mousemoved then
    self:mousemoved(self:fromPolar(_r, _u - r))
  end

  lume.chain(self.childs)
    :filter(function(c) return not c.off and c.mousemoved and not c.eventoff end)
    :each(function(c) c:__mousemoved(mx,my,dx,dy,istouch,x,y,r,sx,sy) end)
  return mx,my
  end

-- function SObject:mousepressed(x, y, button, istouch) lume.chain(self.childs):filter(function(c) return not c.off and c.mousepressed and not c.eventoff end):each(function(c) c:mousepressed(x,y,button,istouch) end) end
-- function SObject:mousereleased(x, y, button, istouch) lume.chain(self.childs):filter(function(c) return not c.off and c.mousereleased and not c.eventoff end):each(function(c) c:mousereleased(x,y,button,istouch) end) end

function SObject:keypressed(key, scancode, isrepeat) lume.chain(self.childs):filter(function(c) return not c.off and c.keypressed and not c.eventoff end):each(function(c) c:keypressed(key, scancode, isrepeat) end) end
function SObject:keyreleased(key) lume.chain(self.childs):filter(function(c) return not c.off and c.keyreleased and not c.eventoff end):each(function(c) c:keyreleased(key) end) end

function SObject:update(dt) lume.chain(self.childs):filter(function(c) return not c.off and c.update end):each(function(c) c:update(dt) end) end
function SObject:refresh() if self.parent and self.parent.refresh then self.parent:refresh() end end
function SObject:setX(val) self.x = val; self:refresh() end
function SObject:setY(val) self.y = val; self:refresh() end
function SObject:setR(val) self.r = val; self:refresh() end
function SObject:setW(val) self.w = val; self:refresh() end
function SObject:setH(val) self.h = val; self:refresh() end
function SObject:setSX(val) self.sx = val; self:refresh() end
function SObject:setSY(val) self.sy = val; self:refresh() end


local SMouseObject = Class{
  init = function(self)
    self.released = false;
  end
}



local SSprite = Class{__includes=SObject,
  init = function(self, img, x, y)
    SObject.init(self, x, y)
    self:setImg(img)
  end
}

function SSprite:mousemoved(x,y)
  if self.debug then
    log.info("x=", x, "y=", y)
  end
end


function SSprite:setImg(img)
  self.img = img
  if type(self.img) == "string" then
      local txt, quad, rect, _, offset = resource:get(self.img)
      if not quad then
        self.w, self.h = txt:getDimensions()
      else
        self.w, self.h = rect[3], rect[4]
      end
  else
    self.w, self.h = self.img:getDimensions()
  end
end

function SSprite:getImg()
  if type(self.img) == "string" then
    local txt, quad, rect, _, offset = resource:get(self.img)
    return txt, quad
  else
    return self.img, nil
  end
end


function SSprite:draw(x,y,r,sx,sy, tx, ty)
  if not self.hidden then
    local img, quad = self:getImg()
    if not quad then
      love.graphics.draw(img, x, y, r, sx, sy, tx, ty)
    else
      love.graphics.draw(img, quad, x, y, r, sx, sy, tx, ty)
    end
  end

  --DEBUG
end

function SSprite:__draw(x, y, r, sx, sy)
  SObject.__draw(self, x, y, r, sx, sy)
  if not x then x = 0 end
  if not y then y = 0 end
  if not r then r = 0 end
  if not sx then sx = 1 end
  if not sy then sy = 1 end

  -- x1,y1 = self:__mousemoved(-50, -50, x,y,r,sx,sy)
  -- x2,y2 = self:__mousemoved(50, -50, x,y,r,sx,sy)
  -- x3,y3 = self:__mousemoved(50, 50, x,y,r,sx,sy)
  -- x4,y4 = self:__mousemoved(-50, 50, x,y,r,sx,sy)
  -- log.info(x1, y1, ";", x2, y2, ";", x3,y3, ";", x4,y4, ";", x1,y1)
  -- love.graphics.line(x1, y1, x2, y2, x3,y3,x4,y4,x1,y1)
end

return {
  SObject = SObject,
  SSprite = SSprite
}
