

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


function SObject:transformMouse(mx, my, x, y, r, sx, sy)
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
  return x,y,r,sx,sy,self:fromPolar(_r, _u - r)
end



function SObject:__mousemoved(mx, my, dx, dy, istouch, x, y, r, sx, sy, used)
  local x,y,r,sx,sy, mx1, my1 = self:transformMouse(mx, my, x, y, r, sx, sy)
  if self.mousemoved then used = self:mousemoved(mx1, my1, istouch, used) end
  lume.chain(self.childs)
    :filter(function(c) return not c.off and c.__mousemoved and not c.eventoff end)
    :each(function(c) used = c:__mousemoved(mx,my,dx,dy,istouch,x,y,r,sx,sy, used) end)
  return used
end

function SObject:__mousepressed(mx, my, button, istouch, x, y, r, sx, sy, used)
  local x,y,r,sx,sy, mx1, my1 = self:transformMouse(mx, my, x, y, r, sx, sy)
  if self.mousepressed then used = self:mousepressed(mx1, my1, button, istouch, used) end
  lume.chain(self.childs)
    :filter(function(c) return not c.off and c.__mousepressed and not c.eventoff end)
    :each(function(c) used = c:__mousepressed(mx, my, button, istouch, x, y, r, sx, sy, used) end)
  return used
end

function SObject:__mousereleased(mx, my, button, istouch, x, y, r, sx, sy, used)
  local x,y,r,sx,sy, mx1, my1 = self:transformMouse(mx, my, x, y, r, sx, sy)
  if self.mousereleased then used = self:mousereleased(mx1, my1, button, istouch, used) end
  lume.chain(self.childs)
    :filter(function(c) return not c.off and c.__mousereleased and not c.eventoff end)
    :each(function(c) c:__mousereleased(mx, my, button, istouch, x, y, r, sx, sy, used) end)
end


function SObject:__keypressed(key, scancode, isrepeat, used)
  if self.keypressed then used = self:keypressed(key, scancode, isrepeat, used) end
  lume.chain(self.childs)
    :filter(function(c) return not c.off and c.__keypressed and not c.eventoff end)
    :each(function(c) used = c:__keypressed(key, scancode, isrepeat, used) end)
end

function SObject:__keyreleased(key, used)
  if self.keyreleased then used = self:keyreleased(key, used) end
  lume.chain(self.childs)
    :filter(function(c) return not c.off and c.__keyreleased and not c.eventoff end)
    :each(function(c) used = c:__keyreleased(key, used) end)
  end

function SObject:__update(dt)
  if self.update then self:update(dt) end
  lume.chain(self.childs)
    :filter(function(c) return not c.off and c.__update end)
    :each(function(c) c:__update(dt) end)
end
function SObject:refresh() if self.parent and self.parent.refresh then self.parent:refresh() end end
function SObject:setX(val) self.x = val; self:refresh(); return self end
function SObject:setY(val) self.y = val; self:refresh(); return self end
function SObject:setR(val) self.r = val; self:refresh(); return self end
function SObject:setW(val) self.w = val; self:refresh(); return self end
function SObject:setH(val) self.h = val; self:refresh(); return self end
function SObject:setSX(val) self.sx = val; self:refresh(); return self end
function SObject:setSY(val) self.sy = val; self:refresh(); return self end
function SObject:setPivot(val, y)
  if type(val) == "number" then self.pivot = {val, y} else self.pivot = val end
  self:refresh()
  return self
end

local SGroup = Class{__includes=SObject,
  init = function(self, x,y, items)
    SObject.init(self,x,y)
    if items then lume.each(items, function(i) self:add(i) end) end
  end
}

local SMouseObject = Class{}
function SMouseObject:getCollider()
  if self.collider then return self.collider end
  return {0, 0, self.w, self.h}
end

function SMouseObject:getBox()
  return {-self.w * self.pivot[1],
          -self.h * self.pivot[2],
          self.w-self.w * self.pivot[1],
          self.h-self.h * self.pivot[2]}
end

function SMouseObject:inBox(x,y)
  local box = self:getBox()
  return x >= box[1] and y >= box[2] and x < box[3] and y < box[4]
end

function SMouseObject:mousepressed(x,y, button, istouch, used)
  if self.__over and not self.__pressed and not used then
    self.__pressed = true
    if self.press then self:press(x,y) end
    used = true
  end
  return used
end

function SMouseObject:mousereleased(x,y, button, istouch, used)
  if self.__over and self.__pressed and not used then
    self.__pressed = false
    if self.over then self:over(x,y) end
    if self.click and not self.disabled  and self:inBox(x,y) then self:click() end
    used = true
  end
  return used
end

function SMouseObject:mousemoved(x,y, istouch, used)
  if self:inBox(x,y) then
    if not self.__over then
      self.__over = true
      if self.over then self:over(x,y) end
      used = true
    end
  else
    if self.__over or used then
      self.__over = false
      self.__pressed = false
      if self.release then self:release(x,y) end
    end
  end
  return used
end

local SKeyboardObject = Class{}

function SKeyboardObject:keypressed(key, scancode, isrepeat, used)
  if not self.keys or not lume.any(self.keys, function(k) return k == key end) then
    return used
  end
  if not isrepeat then
    if self.press then self:press() end
    if self.down then self:down(key, scancode) end
    if self.clickByDown and not used and self.click then self:click(); end
    used = true
  end
  self.__keydown = true
  return used
end


function SKeyboardObject:keyreleased(key, used)
  if not self.keys or not lume.any(self.keys, function(k) return k == key end) then
    return used
  end
  if self.release then self:release() end
  if self.up then self:up(key) end
  if not self.clickByDown and not used and self.click and self.__keydown then
    self.__keydown = false
    self:click()
    used = true
  end
  return used
end



return {
  SObject = SObject,
  SGroup = SGroup,
  SMouseObject = SMouseObject,
  SKeyboardObject = SKeyboardObject
}
