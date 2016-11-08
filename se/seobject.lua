

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
function SObject:setPivot(val, y)
  if type(val) == "number" then self.pivot = {val, y} else self.pivot = val end
  self:refresh()
end

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



local SSprite = Class{__includes=SObject,
  init = function(self, img, x, y)
    SObject.init(self, x, y)
    self:setImg(img)
  end
}

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
end



local SButton = Class{__includes={SObject, SMouseObject},
  init = function(self, x, y, states)
    SObject.init(self, x, y)
    self.states = states
    if not self.states.release then error("Release state not set") end
    if not self.states.over then self.states.over = self.states.release end
    if not self.states.press then self.states.press = self.states.over end
    if not self.states.disable then self.states.disable = self.states.release end
    if not self.states.disablePress then self.states.disablePress = self.states.disable end
    self.w, self.h = self.states.release.w,self.states.release.h
    for k,v in pairs(self.states) do self:add(v) end
    self:state("release")
  end
}

function SButton:setPivot(x,y)
  SObject.setPivot(self, x,y)
  for _,v in pairs(self.states) do v:setPivot(x,y) end
end

function SButton:state(state)
  for k,v in pairs(self.states) do
    v.off = true
  end
  self.states[state].off =false
end

function SButton:over()
  if self.disable then
    self:state("disable")
  else
    self:state("over")
  end
end

function SButton:press()
  if self.disable then
    self:state("disablePress")
  else
    self:state("press")
  end
end

function SButton:release()
  if self.disable then
    self:state("disable")
  else
    self:state("release")
  end
end

function SButton:click()
  log.info("Click!")
end

return {
  SObject = SObject,
  SSprite = SSprite,
  SButton = SButton
}
