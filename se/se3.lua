
local ROOT = (...):gsub('[^.]*$', '')

SObject =         require(ROOT .. "seobject").SObject

SText =         require(ROOT .. "setext").SText

SMouseObject =    require(ROOT .. "seobject").SMouseObject
SKeyboardObject = require(ROOT .. "seobject").SKeyboardObject

SSprite =          require(ROOT .. "sesprite").SSprite
SAnimationSprite = require(ROOT .. "sesprite").SAnimationSprite

SButton =       require(ROOT .. "sebutton").SButton
SSpriteButton = require(ROOT .. "sebutton").SSpriteButton
SEmptyButton  = require(ROOT .. "sebutton").SEmptyButton
