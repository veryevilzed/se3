

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
  self:refresh();
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
  else
    self.w = font:getWidth(text)
    self.h = font:getHeight()
  end
  return self
end

function SText:setColor(color) self.color = color; return self:refresh() end

function SText:setFont(font)
  log.info("set font", font)
  self.font = font
  self:refresh();
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
  if not self.hidden or not self.text or self.text == "" then
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

local STextObject = Class{}

function STextObject:setFont(font)
  if not font then return end
  if not self.__text_object then
    self.__text_object = self:add(SText(0,0, font, self.__text_object_text or ""))
    self.__text_object:setMaxWidth(self.w)
    self.__text_object.align = "center"
  else
    self.__text_object:setFont(font)
  end
  return self
end

function STextObject:setTextColor(color)
  self.__text_object:setColor(color); return self
end
function STextObject:getText() return self.__text_object_text or "" end
function STextObject:setText(text)
  self.__text_object_text = text
  if not self.__text_object then return end
  self.__text_object:setText(self.__text_object_text)
  self.__text_object:setMaxWidth(self.w)
  return self
end

function STextObject:getTextObject()
  return self.__text_object
end

return {
  SText = SText,
  STextObject = STextObject
}
