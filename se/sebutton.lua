

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
  init = function(self, x,y, states, event)
    self.states = states
    self.event = event
    if not self.states.release then error("Release state not set") end
    if not self.states.over then self.states.over = self.states.release end
    if not self.states.press then self.states.press = self.states.over end
    if not self.states.disable then self.states.disable = self.states.release end
    if not self.states.disablePress then self.states.disablePress = self.states.disable end
    SSprite.init(self, self.states.release, x, y)
    self:state("release")
  end
}


function SSpriteButton:state(state)
  self.__current = self.states[state]
  self:setImg(self.__current)
end

return {
  SButton = SButton,
  SSpriteButton = SSpriteButton
}
