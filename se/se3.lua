
local ROOT = (...):gsub('[^.]*$', '')

SObject =          require(ROOT .. "seobject").SObject
SGroup =           require(ROOT .. "seobject").SGroup
SCanvas =          require(ROOT .. "seobject").SCanvas

SText =            require(ROOT .. "setext").SText
STextObject =      require(ROOT .. "setext").STextObject

SMouseObject =     require(ROOT .. "seobject").SMouseObject
SKeyboardObject =  require(ROOT .. "seobject").SKeyboardObject

SSprite =          require(ROOT .. "sesprite").SSprite
SAnimationSprite = require(ROOT .. "sesprite").SAnimationSprite

SButton =          require(ROOT .. "sebutton").SButton
SSpriteButton =    require(ROOT .. "sebutton").SSpriteButton
SEmptyButton  =    require(ROOT .. "sebutton").SEmptyButton
