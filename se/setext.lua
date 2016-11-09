

local SText = Class{__includes=SObject,
  init = function(self, x, y, font, text)
    SObject.init(self, x,y)
    self.align = "left"
    self:setFont(font)
    self:setText(text or "")
  end
}

function SText:setMaxWidth(val)
  self.maxWidth = val
  self:setText(self.text)
  return self
end

function SText:setText(text)
  local font = self:getFont()
  self.text = text
  if self.text == nil then self.w = 0; return end
  if self.maxWidth then
    local _width, _wrapedtext = resource:getFont("fnt"):getWrap( self.text, self.maxWidth )
    self.w = self.maxWidth -- _width
    self.h = #_wrapedtext * font:getHeight() + #_wrapedtext * font:getLineHeight()
    print("#_wrapedtext",#_wrapedtext, "fh", font:getHeight() )
  else
    self.w = font:getWidth(text)
    self.h = font:getHeight()
  end
  return self
end

function SText:setColor(color)
  self.color = color
  return self
end

function SText:setFont(font)
  log.info("set font", font)
  self.font = font
  return self
end

function SText:getFont()
  if type(self.font) == "string" then
    return resource:getFont(self.font)
  else
    return self.font
  end
end


function SText:draw(x,y,r,sx,sy, tx, ty)
  if not self.hidden then
    local font = self:getFont()
    if font == nil then return end
    if self.color then love.graphics.setColor(self.color) end
    if self.maxWidth then
      if (self.align == "center") then
        love.graphics.printf(self.text, x, y, self.maxWidth, self.align, r, sx, sy, tx, ty)
      else
        love.graphics.printf(self.text, x, y, self.maxWidth, self.align, r, sx, sy, tx, ty)
      end
    else
      love.graphics.printf(self.text, x, y, 1280, self.align, r, sx, sy, tx, ty)
    end
    if self.color then love.graphics.setColor(255, 255, 255, 255) end
  end
end


return {
  SText = SText
}
