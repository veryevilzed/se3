

local SSprite = Class{__includes={SObject},
  init = function(self, img, x, y)
    SObject.init(self, x, y)
    self:setImg(img)
  end
}

function SSprite:setImg(img)
  self.img = img
  if self.img == nil then
    self.w, self.h = 0,0
    return
  end

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
  if self.img == nil then return nil end
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
    if img == nil then return end
    if not quad then
      love.graphics.draw(img, x, y, r, sx, sy, tx, ty)
    else
      love.graphics.draw(img, quad, x, y, r, sx, sy, tx, ty)
    end
  end
end


local SAnimator = Class{
    init = function(self, sequence, delay)
      self.delay = delay or 0.08
      self:setSequence(sequence)
    end
}

function SAnimator:setSequence(sequence)
  self.sequence = lume.map(sequence, function(s)
    if type(s) == "string" then
      return {frame=s, delay=self.delay}
    else
      return s
    end
  end)
  print(inspect(self.sequence))
  self.index = 1
  self.__curent_frame = {frame=self.sequence[self.index].frame, delay=self.sequence[self.index].delay}
  self:setImg(self.__curent_frame.frame)
end

function SAnimator:nextFrame(d)
  if self.index < #self.sequence then
    self.index = self.index + 1
  else
    self.index = 1
  end

  self.__curent_frame = {frame=self.sequence[self.index].frame, delay=self.sequence[self.index].delay}
  self.__curent_frame.delay = self.__curent_frame.delay + d
  if self.__curent_frame.delay <=0 then
    return self:nextFrame(self.__curent_frame.delay)
  end

  self:setImg(self.__curent_frame.frame)
end

function SAnimator:update(dt)
  if self.__curent_frame and self.__curent_frame.delay then
    self.__curent_frame.delay = self.__curent_frame.delay - dt
    if self.__curent_frame.delay <=0 then self:nextFrame(self.__curent_frame.delay) end
  end
end

local SAnimationSprite = Class{__includes={SSprite, SAnimator, STextObject},
  init = function(self, sequence, x, y, delay)
    SSprite.init(self,nil, x,y)
    SAnimator.init(self,sequence,delay)
  end
}

local STextSprite = Class{__includes={ SSprite, STextObject },
  init = function(self, img, x, y, font, text)
    SSprite.init(self,img, x, y, font, text)
    if font then self:setFont(font) end
    if text then self:setText(text) end
  end
}

return {
  SSprite = SSprite,
  SAnimator = SAnimator,
  SAnimationSprite = SAnimationSprite
}
