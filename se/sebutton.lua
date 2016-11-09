

local SButtonEngine = Class{}

function SButtonEngine:state(state) end

function SButtonEngine:over()
  if self.disable then
    self:state("disable")
  else
    self:state("over")
  end
end

function SButtonEngine:press()
  if self.disable then
    self:state("disablePress")
  else
    self:state("press")
  end
end

function SButtonEngine:release()
  if self.disable then
    self:state("disable")
  else
    self:state("release")
  end
end

function SButtonEngine:click()
  if self.event then
    if type(event) == "function" then self.event(self)
    elseif type(event) == "string" then Signal.emit("click", event)
    end
  end
end

-- Button with SubClasses
local SButton = Class{__includes={SObject, SButtonEngine, SMouseObject, SKeyboardObject},
  init = function(self, x, y, states, event)
    SObject.init(self, x, y)
    self.states = states
    self.event = event
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

-- Button With Sprite
local SSpriteButton = Class{__includes={SSprite, SButtonEngine, SKeyboardObject, SMouseObject},
  init = function(self, x,y, states, event, font, text)
    self.states = states
    self.event = event

    if not self.states.release then error("Release state not set") end
    if not self.states.over then self.states.over = self.states.release end
    if not self.states.press then self.states.press = self.states.over end
    if not self.states.disable then self.states.disable = self.states.release end
    if not self.states.disablePress then self.states.disablePress = self.states.disable end
    SSprite.init(self, self.states.release, x, y)
    self:setFont(font)
    self:setTextStyle(text)
    self:state("release")
  end
}

function SSpriteButton:setTextStyle(text)
  self.texts = text
  if type(self.texts) == "string" then
    self.texts = {release={dx=0, dy=0, color=nil}}
    self.text=text
  end
  if not self.texts.over then self.texts.over = self.texts.release end
  if not self.texts.press then self.texts.press = self.texts.over end
  if not self.texts.disable then self.texts.disable = self.texts.release end
  if not self.texts.disablePress then self.texts.disablePress = self.texts.disable end
  self:state("release")
end

function SSpriteButton:setText(text)
  self.text = text
  if not self.__text then return end
  self.__text:setText(self.text)
end

function SSpriteButton:getText(text)
  return self.text
end

function SSpriteButton:stateTexts(text)
  if text.text then
    self:setText(text.text)
  else
    self:setText(self.text)
  end
  if text.dx then self.__text:setX(text.dx) else self.__text:setX(0) end
  if text.dy then self.__text:setY(text.dy) else self.__text:setY(0) end
  if text.color then self.__text:setColor(text.color) else self.__text:setColor(nil) end
end

function SSpriteButton:setFont(font)
  if not font then return end
  if not self.__text then
    self.__text = self:add(SText(0,0, font, self.text or ""))
    self.__text:setMaxWidth(self.w)
    self.__text.align = "center"
  else
    self.__text:setFont(font)
  end
end

function SSpriteButton:state(state)
  self.__current = self.states[state]
  self.__current_text = self.texts[state]
  self:setImg(self.__current)
  self:stateTexts(self.__current_text)
end


local SEmptyButton = Class{__includes={SObject, SButtonEngine, SKeyboardObject}}

return {
  SButton = SButton,
  SSpriteButton = SSpriteButton,
  SEmptyButton = SEmptyButton
}
