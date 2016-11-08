

Class = require("hump.class")
lume = require("lume")
log = require("log")
resource = require("resource")()


SSprite = require("se.seobject").SSprite

function love.load(arg)
  resource:load("asset/1.png", "1", true)

  s = SSprite("1", 100,100)
  s.r = (math.pi / 180) * 5
  s.sx, s.sy = 0.5, 0.5
  s2 = s:add(SSprite("1", 100,100))
  s2.pivot = {0.5,0.5}
  s2.sx, s2.sy = 3, 3
  --s2.debug = true
  s2.r = (math.pi / 180) * 5
  l = 0

  s3 = s2:add(SSprite("1", 100,100))

  --s2.sx, s2.sy = 2, 2
  s3.debug = true


end

function love.draw()
  s:__draw()
  --love.graphics.draw(img, 100, 100, l, 1, 1, 50, 50)
  love.graphics.line(100,0,100,500)
  love.graphics.line(0,100,500,100)
end

function love.update(dt)
  --s.r = s.r + dt * 3
  --s2.r = s2.r + dt * 3
end

function love.mousemoved(x, y, dx, dy, istouch)
  s:__mousemoved(x, y, dx, dy, istouch)
end
