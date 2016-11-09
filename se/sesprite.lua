

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


return {
  SSprite = SSprite
}
